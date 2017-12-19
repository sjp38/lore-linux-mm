Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5FD26B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:42:05 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id f13so8771604oib.20
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:42:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 92si2215350otm.541.2017.12.19.12.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 12:42:04 -0800 (PST)
Date: Tue, 19 Dec 2017 21:41:58 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171219214158.353032f0@redhat.com>
In-Reply-To: <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
References: <rao.shoaib@oracle.com>
	<1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, brouer@redhat.com


On Tue, 19 Dec 2017 09:52:27 -0800 rao.shoaib@oracle.com wrote:

> +/* Main RCU function that is called to free RCU structures */
> +static void
> +__rcu_bulk_free(struct rcu_head *head, rcu_callback_t func, int cpu, bool lazy)
> +{
> +	unsigned long offset;
> +	void *ptr;
> +	struct rcu_bulk_free *rbf;
> +	struct rcu_bulk_free_container *rbfc = NULL;
> +
> +	rbf = this_cpu_ptr(&cpu_rbf);
> +
> +	if (unlikely(!rbf->rbf_init)) {
> +		spin_lock_init(&rbf->rbf_lock);
> +		rbf->rbf_cpu = smp_processor_id();
> +		rbf->rbf_init = true;
> +	}
> +
> +	/* hold lock to protect against other cpu's */
> +	spin_lock_bh(&rbf->rbf_lock);

I'm not sure this will be faster.  Having to take a cross CPU lock here
(+ BH-disable) could cause scaling issues.   Hopefully this lock will
not be used intensively by other CPUs, right?


The current cost of __call_rcu() is a local_irq_save/restore (which is
quite expensive, but doesn't cause cross CPU chatter).

Later in __rcu_process_callbacks() we have a local_irq_save/restore for
the entire list, plus a per object cost doing local_bh_disable/enable.
And for each object we call __rcu_reclaim(), which in some cases
directly call kfree().


If I had to implement this: I would choose to do the optimization in
__rcu_process_callbacks() create small on-call-stack ptr-array for
kfree_bulk().  I would only optimize the case that call kfree()
directly.  In the while(list) loop I would defer calling
__rcu_reclaim() for __is_kfree_rcu_offset(head->func), and instead add
them to the ptr-array (and flush if the array is full in loop, and
kfree_bulk flush after loop).

The real advantage of kfree_bulk() comes from amortizing the per kfree
(behind-the-scenes) sync cost.  There is an additional benefit, because
objects comes from RCU and will hit a slower path in SLUB.   The SLUB
allocator is very fast for objects that gets recycled quickly (short
lifetime), non-locked (cpu-local) double-cmpxchg.  But slower for
longer-lived/more-outstanding objects, as this hits a slower code-path,
fully locked (cross-cpu) double-cmpxchg.  

> +
> +	rbfc = rbf->rbf_container;
> +
> +	if (rbfc == NULL) {
> +		if (rbf->rbf_cached_container == NULL) {
> +			rbf->rbf_container =
> +			    kmalloc(sizeof(struct rcu_bulk_free_container),
> +			    GFP_ATOMIC);
> +			rbf->rbf_container->rbfc_rbf = rbf;
> +		} else {
> +			rbf->rbf_container = rbf->rbf_cached_container;
> +			rbf->rbf_container->rbfc_rbf = rbf;
> +			cmpxchg(&rbf->rbf_cached_container,
> +			    rbf->rbf_cached_container, NULL);
> +		}
> +
> +		if (unlikely(rbf->rbf_container == NULL)) {
> +
> +			/* Memory allocation failed maintain a list */
> +
> +			head->func = (void *)func;
> +			head->next = rbf->rbf_list_head;
> +			rbf->rbf_list_head = head;
> +			rbf->rbf_list_size++;
> +			if (rbf->rbf_list_size == RCU_MAX_ACCUMULATE_SIZE)
> +				__rcu_bulk_schedule_list(rbf);
> +
> +			goto done;
> +		}
> +
> +		rbfc = rbf->rbf_container;
> +		rbfc->rbfc_entries = 0;
> +
> +		if (rbf->rbf_list_head != NULL)
> +			__rcu_bulk_schedule_list(rbf);
> +	}
> +
> +	offset = (unsigned long)func;
> +	ptr = (void *)head - offset;
> +
> +	rbfc->rbfc_data[rbfc->rbfc_entries++] = ptr;
> +	if (rbfc->rbfc_entries == RCU_MAX_ACCUMULATE_SIZE) {
> +
> +		WRITE_ONCE(rbf->rbf_container, NULL);
> +		spin_unlock_bh(&rbf->rbf_lock);
> +		call_rcu(&rbfc->rbfc_rcu, __rcu_bulk_free_impl);
> +		return;
> +	}
> +
> +done:
> +	if (!rbf->rbf_monitor) {
> +
> +		call_rcu(&rbf->rbf_rcu, __rcu_bulk_free_monitor);
> +		rbf->rbf_monitor = true;
> +	}
> +
> +	spin_unlock_bh(&rbf->rbf_lock);
> +}


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
