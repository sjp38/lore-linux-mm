Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18CC56B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 18:25:39 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r6so3428227itr.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:25:39 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c38si2105445itd.151.2017.12.19.15.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 15:25:37 -0800 (PST)
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface for
 freeing rcu structures
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219214158.353032f0@redhat.com>
 <20171219221206.GA22696@bombadil.infradead.org>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <cd6e5aa9-5d0a-850b-38fc-9b6f8c2c0312@oracle.com>
Date: Tue, 19 Dec 2017 15:25:19 -0800
MIME-Version: 1.0
In-Reply-To: <20171219221206.GA22696@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org



On 12/19/2017 02:12 PM, Matthew Wilcox wrote:
> On Tue, Dec 19, 2017 at 09:41:58PM +0100, Jesper Dangaard Brouer wrote:
>> If I had to implement this: I would choose to do the optimization in
>> __rcu_process_callbacks() create small on-call-stack ptr-array for
>> kfree_bulk().  I would only optimize the case that call kfree()
>> directly.  In the while(list) loop I would defer calling
>> __rcu_reclaim() for __is_kfree_rcu_offset(head->func), and instead add
>> them to the ptr-array (and flush if the array is full in loop, and
>> kfree_bulk flush after loop).
>>
>> The real advantage of kfree_bulk() comes from amortizing the per kfree
>> (behind-the-scenes) sync cost.  There is an additional benefit, because
>> objects comes from RCU and will hit a slower path in SLUB.   The SLUB
>> allocator is very fast for objects that gets recycled quickly (short
>> lifetime), non-locked (cpu-local) double-cmpxchg.  But slower for
>> longer-lived/more-outstanding objects, as this hits a slower code-path,
>> fully locked (cross-cpu) double-cmpxchg.
> Something like this ...  (compile tested only)
>
> Considerably less code; Rao, what do you think?
>
> diff --git a/kernel/rcu/rcu.h b/kernel/rcu/rcu.h
> index 59c471de342a..5ac4ed077233 100644
> --- a/kernel/rcu/rcu.h
> +++ b/kernel/rcu/rcu.h
> @@ -174,20 +174,19 @@ static inline void debug_rcu_head_unqueue(struct rcu_head *head)
>   }
>   #endif	/* #else !CONFIG_DEBUG_OBJECTS_RCU_HEAD */
>   
> -void kfree(const void *);
> -
>   /*
>    * Reclaim the specified callback, either by invoking it (non-lazy case)
>    * or freeing it directly (lazy case).  Return true if lazy, false otherwise.
>    */
> -static inline bool __rcu_reclaim(const char *rn, struct rcu_head *head)
> +static inline bool __rcu_reclaim(const char *rn, struct rcu_head *head, void **kfree,
> +				unsigned int *idx)
>   {
>   	unsigned long offset = (unsigned long)head->func;
>   
>   	rcu_lock_acquire(&rcu_callback_map);
>   	if (__is_kfree_rcu_offset(offset)) {
>   		RCU_TRACE(trace_rcu_invoke_kfree_callback(rn, head, offset);)
> -		kfree((void *)head - offset);
> +		kfree[*idx++] = (void *)head - offset;
>   		rcu_lock_release(&rcu_callback_map);
>   		return true;
>   	} else {
> diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
> index f9c0ca2ccf0c..7e13979b4697 100644
> --- a/kernel/rcu/tree.c
> +++ b/kernel/rcu/tree.c
> @@ -2725,6 +2725,8 @@ static void rcu_do_batch(struct rcu_state *rsp, struct rcu_data *rdp)
>   	struct rcu_head *rhp;
>   	struct rcu_cblist rcl = RCU_CBLIST_INITIALIZER(rcl);
>   	long bl, count;
> +	void *to_free[16];
> +	unsigned int to_free_idx = 0;
>   
>   	/* If no callbacks are ready, just return. */
>   	if (!rcu_segcblist_ready_cbs(&rdp->cblist)) {
> @@ -2755,8 +2757,10 @@ static void rcu_do_batch(struct rcu_state *rsp, struct rcu_data *rdp)
>   	rhp = rcu_cblist_dequeue(&rcl);
>   	for (; rhp; rhp = rcu_cblist_dequeue(&rcl)) {
>   		debug_rcu_head_unqueue(rhp);
> -		if (__rcu_reclaim(rsp->name, rhp))
> +		if (__rcu_reclaim(rsp->name, rhp, to_free, &to_free_idx))
>   			rcu_cblist_dequeued_lazy(&rcl);
> +		if (to_free_idx == 16)
> +			kfree_bulk(16, to_free);
>   		/*
>   		 * Stop only if limit reached and CPU has something to do.
>   		 * Note: The rcl structure counts down from zero.
> @@ -2766,6 +2770,8 @@ static void rcu_do_batch(struct rcu_state *rsp, struct rcu_data *rdp)
>   		     (!is_idle_task(current) && !rcu_is_callbacks_kthread())))
>   			break;
>   	}
> +	if (to_free_idx)
> +		kfree_bulk(to_free_idx, to_free);
>   
>   	local_irq_save(flags);
>   	count = -rcl.len;
> diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
> index db85ca3975f1..4127be06759b 100644
> --- a/kernel/rcu/tree_plugin.h
> +++ b/kernel/rcu/tree_plugin.h
> @@ -2189,6 +2189,8 @@ static int rcu_nocb_kthread(void *arg)
>   	struct rcu_head *next;
>   	struct rcu_head **tail;
>   	struct rcu_data *rdp = arg;
> +	void *to_free[16];
> +	unsigned int to_free_idx = 0;
>   
>   	/* Each pass through this loop invokes one batch of callbacks */
>   	for (;;) {
> @@ -2226,13 +2228,18 @@ static int rcu_nocb_kthread(void *arg)
>   			}
>   			debug_rcu_head_unqueue(list);
>   			local_bh_disable();
> -			if (__rcu_reclaim(rdp->rsp->name, list))
> +			if (__rcu_reclaim(rdp->rsp->name, list, to_free,
> +								&to_free_idx))
>   				cl++;
>   			c++;
> +			if (to_free_idx == 16)
> +				kfree_bulk(16, to_free);
>   			local_bh_enable();
>   			cond_resched_rcu_qs();
>   			list = next;
>   		}
> +		if (to_free_idx)
> +			kfree_bulk(to_free_idx, to_free);
>   		trace_rcu_batch_end(rdp->rsp->name, c, !!list, 0, 0, 1);
>   		smp_mb__before_atomic();  /* _add after CB invocation. */
>   		atomic_long_add(-c, &rdp->nocb_q_count);
This is definitely less code and I believe this is what I tried initially.
With this approach we are accumulating for one cycle only and 
__call_rcu() is called for each object, though I am not sure if that is 
an issue because my change has to hold a lock. If everyone else thinks 
this is good enough than we should just go with this, there is no need 
to make unnecessary changes.

Please let me know so I do not have to submit a patch :-)

Shoaib.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
