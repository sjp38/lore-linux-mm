Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1096F6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 16:20:47 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b11so3165654itj.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 13:20:47 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id v124si1935517ith.4.2017.12.19.13.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 13:20:45 -0800 (PST)
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface for
 freeing rcu structures
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219214158.353032f0@redhat.com>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <75f514a6-8121-7d5f-4b6a-7e68d8f226a8@oracle.com>
Date: Tue, 19 Dec 2017 13:20:43 -0800
MIME-Version: 1.0
In-Reply-To: <20171219214158.353032f0@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org



On 12/19/2017 12:41 PM, Jesper Dangaard Brouer wrote:
> On Tue, 19 Dec 2017 09:52:27 -0800 rao.shoaib@oracle.com wrote:
>
>> +/* Main RCU function that is called to free RCU structures */
>> +static void
>> +__rcu_bulk_free(struct rcu_head *head, rcu_callback_t func, int cpu, bool lazy)
>> +{
>> +	unsigned long offset;
>> +	void *ptr;
>> +	struct rcu_bulk_free *rbf;
>> +	struct rcu_bulk_free_container *rbfc = NULL;
>> +
>> +	rbf = this_cpu_ptr(&cpu_rbf);
>> +
>> +	if (unlikely(!rbf->rbf_init)) {
>> +		spin_lock_init(&rbf->rbf_lock);
>> +		rbf->rbf_cpu = smp_processor_id();
>> +		rbf->rbf_init = true;
>> +	}
>> +
>> +	/* hold lock to protect against other cpu's */
>> +	spin_lock_bh(&rbf->rbf_lock);
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

As Paul has pointed out the lock is a per-cpu lock, the only reason for 
another CPU to access this lock is if the rcu callbacks run on a 
different CPU and there is nothing the code can do to avoid that but 
that should be rare anyways.

>
>
> If I had to implement this: I would choose to do the optimization in
> __rcu_process_callbacks() create small on-call-stack ptr-array for
> kfree_bulk().  I would only optimize the case that call kfree()
> directly.  In the while(list) loop I would defer calling
> __rcu_reclaim() for __is_kfree_rcu_offset(head->func), and instead add
> them to the ptr-array (and flush if the array is full in loop, and
> kfree_bulk flush after loop).
This is exactly what the current code is doing. It accumulates only the 
calls made to
__kfree_rcu(head, offset) ==> kfree_call_rcu() ==> __bulk_free_rcu

__kfree_rcu has a check to make sure that an offset is being passed.

When a function pointer is passed the caller has to call 
call_rcu/call_rcu_sched

Accumulating early avoids the individual cost of calling __call_rcu

Perhaps I do not understand your point.

Shoaib
>
> The real advantage of kfree_bulk() comes from amortizing the per kfree
> (behind-the-scenes) sync cost.  There is an additional benefit, because
> objects comes from RCU and will hit a slower path in SLUB.   The SLUB
> allocator is very fast for objects that gets recycled quickly (short
> lifetime), non-locked (cpu-local) double-cmpxchg.  But slower for
> longer-lived/more-outstanding objects, as this hits a slower code-path,
> fully locked (cross-cpu) double-cmpxchg.
>
>> +
>> +	rbfc = rbf->rbf_container;
>> +
>> +	if (rbfc == NULL) {
>> +		if (rbf->rbf_cached_container == NULL) {
>> +			rbf->rbf_container =
>> +			    kmalloc(sizeof(struct rcu_bulk_free_container),
>> +			    GFP_ATOMIC);
>> +			rbf->rbf_container->rbfc_rbf = rbf;
>> +		} else {
>> +			rbf->rbf_container = rbf->rbf_cached_container;
>> +			rbf->rbf_container->rbfc_rbf = rbf;
>> +			cmpxchg(&rbf->rbf_cached_container,
>> +			    rbf->rbf_cached_container, NULL);
>> +		}
>> +
>> +		if (unlikely(rbf->rbf_container == NULL)) {
>> +
>> +			/* Memory allocation failed maintain a list */
>> +
>> +			head->func = (void *)func;
>> +			head->next = rbf->rbf_list_head;
>> +			rbf->rbf_list_head = head;
>> +			rbf->rbf_list_size++;
>> +			if (rbf->rbf_list_size == RCU_MAX_ACCUMULATE_SIZE)
>> +				__rcu_bulk_schedule_list(rbf);
>> +
>> +			goto done;
>> +		}
>> +
>> +		rbfc = rbf->rbf_container;
>> +		rbfc->rbfc_entries = 0;
>> +
>> +		if (rbf->rbf_list_head != NULL)
>> +			__rcu_bulk_schedule_list(rbf);
>> +	}
>> +
>> +	offset = (unsigned long)func;
>> +	ptr = (void *)head - offset;
>> +
>> +	rbfc->rbfc_data[rbfc->rbfc_entries++] = ptr;
>> +	if (rbfc->rbfc_entries == RCU_MAX_ACCUMULATE_SIZE) {
>> +
>> +		WRITE_ONCE(rbf->rbf_container, NULL);
>> +		spin_unlock_bh(&rbf->rbf_lock);
>> +		call_rcu(&rbfc->rbfc_rcu, __rcu_bulk_free_impl);
>> +		return;
>> +	}
>> +
>> +done:
>> +	if (!rbf->rbf_monitor) {
>> +
>> +		call_rcu(&rbf->rbf_rcu, __rcu_bulk_free_monitor);
>> +		rbf->rbf_monitor = true;
>> +	}
>> +
>> +	spin_unlock_bh(&rbf->rbf_lock);
>> +}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
