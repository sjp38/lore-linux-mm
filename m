Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA6A6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:56:24 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id v3so15550180qtb.19
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:56:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i39si1611167qtb.101.2017.12.19.12.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 12:56:23 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBJKsT84036063
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:56:22 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ey63rvmcw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:56:21 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Dec 2017 15:56:20 -0500
Date: Tue, 19 Dec 2017 12:56:29 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Reply-To: paulmck@linux.vnet.ibm.com
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219214158.353032f0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219214158.353032f0@redhat.com>
Message-Id: <20171219205629.GH7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: rao.shoaib@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 19, 2017 at 09:41:58PM +0100, Jesper Dangaard Brouer wrote:
> 
> On Tue, 19 Dec 2017 09:52:27 -0800 rao.shoaib@oracle.com wrote:
> 
> > +/* Main RCU function that is called to free RCU structures */
> > +static void
> > +__rcu_bulk_free(struct rcu_head *head, rcu_callback_t func, int cpu, bool lazy)
> > +{
> > +	unsigned long offset;
> > +	void *ptr;
> > +	struct rcu_bulk_free *rbf;
> > +	struct rcu_bulk_free_container *rbfc = NULL;
> > +
> > +	rbf = this_cpu_ptr(&cpu_rbf);
> > +
> > +	if (unlikely(!rbf->rbf_init)) {
> > +		spin_lock_init(&rbf->rbf_lock);
> > +		rbf->rbf_cpu = smp_processor_id();
> > +		rbf->rbf_init = true;
> > +	}
> > +
> > +	/* hold lock to protect against other cpu's */
> > +	spin_lock_bh(&rbf->rbf_lock);
> 
> I'm not sure this will be faster.  Having to take a cross CPU lock here
> (+ BH-disable) could cause scaling issues.   Hopefully this lock will
> not be used intensively by other CPUs, right?
> 
> 
> The current cost of __call_rcu() is a local_irq_save/restore (which is
> quite expensive, but doesn't cause cross CPU chatter).
> 
> Later in __rcu_process_callbacks() we have a local_irq_save/restore for
> the entire list, plus a per object cost doing local_bh_disable/enable.
> And for each object we call __rcu_reclaim(), which in some cases
> directly call kfree().

Isn't this lock in a per-CPU object?  It -might- go cross-CPU in response
to CPU-hotplug operations, but that should be rare.

							Thanx, Paul

> If I had to implement this: I would choose to do the optimization in
> __rcu_process_callbacks() create small on-call-stack ptr-array for
> kfree_bulk().  I would only optimize the case that call kfree()
> directly.  In the while(list) loop I would defer calling
> __rcu_reclaim() for __is_kfree_rcu_offset(head->func), and instead add
> them to the ptr-array (and flush if the array is full in loop, and
> kfree_bulk flush after loop).
> 
> The real advantage of kfree_bulk() comes from amortizing the per kfree
> (behind-the-scenes) sync cost.  There is an additional benefit, because
> objects comes from RCU and will hit a slower path in SLUB.   The SLUB
> allocator is very fast for objects that gets recycled quickly (short
> lifetime), non-locked (cpu-local) double-cmpxchg.  But slower for
> longer-lived/more-outstanding objects, as this hits a slower code-path,
> fully locked (cross-cpu) double-cmpxchg.  
> 
> > +
> > +	rbfc = rbf->rbf_container;
> > +
> > +	if (rbfc == NULL) {
> > +		if (rbf->rbf_cached_container == NULL) {
> > +			rbf->rbf_container =
> > +			    kmalloc(sizeof(struct rcu_bulk_free_container),
> > +			    GFP_ATOMIC);
> > +			rbf->rbf_container->rbfc_rbf = rbf;
> > +		} else {
> > +			rbf->rbf_container = rbf->rbf_cached_container;
> > +			rbf->rbf_container->rbfc_rbf = rbf;
> > +			cmpxchg(&rbf->rbf_cached_container,
> > +			    rbf->rbf_cached_container, NULL);
> > +		}
> > +
> > +		if (unlikely(rbf->rbf_container == NULL)) {
> > +
> > +			/* Memory allocation failed maintain a list */
> > +
> > +			head->func = (void *)func;
> > +			head->next = rbf->rbf_list_head;
> > +			rbf->rbf_list_head = head;
> > +			rbf->rbf_list_size++;
> > +			if (rbf->rbf_list_size == RCU_MAX_ACCUMULATE_SIZE)
> > +				__rcu_bulk_schedule_list(rbf);
> > +
> > +			goto done;
> > +		}
> > +
> > +		rbfc = rbf->rbf_container;
> > +		rbfc->rbfc_entries = 0;
> > +
> > +		if (rbf->rbf_list_head != NULL)
> > +			__rcu_bulk_schedule_list(rbf);
> > +	}
> > +
> > +	offset = (unsigned long)func;
> > +	ptr = (void *)head - offset;
> > +
> > +	rbfc->rbfc_data[rbfc->rbfc_entries++] = ptr;
> > +	if (rbfc->rbfc_entries == RCU_MAX_ACCUMULATE_SIZE) {
> > +
> > +		WRITE_ONCE(rbf->rbf_container, NULL);
> > +		spin_unlock_bh(&rbf->rbf_lock);
> > +		call_rcu(&rbfc->rbfc_rcu, __rcu_bulk_free_impl);
> > +		return;
> > +	}
> > +
> > +done:
> > +	if (!rbf->rbf_monitor) {
> > +
> > +		call_rcu(&rbf->rbf_rcu, __rcu_bulk_free_monitor);
> > +		rbf->rbf_monitor = true;
> > +	}
> > +
> > +	spin_unlock_bh(&rbf->rbf_lock);
> > +}
> 
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
