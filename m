Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9246B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 19:20:47 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id q13so15915747qtb.13
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 16:20:47 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r1si3448007qki.90.2017.12.19.16.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 16:20:46 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBK0JNBa062312
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 19:20:45 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eybdbm2hv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 19:20:44 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Dec 2017 19:20:43 -0500
Date: Tue, 19 Dec 2017 16:20:51 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Reply-To: paulmck@linux.vnet.ibm.com
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219214158.353032f0@redhat.com>
 <20171219221206.GA22696@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219221206.GA22696@bombadil.infradead.org>
Message-Id: <20171220002051.GJ7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, rao.shoaib@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 19, 2017 at 02:12:06PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 19, 2017 at 09:41:58PM +0100, Jesper Dangaard Brouer wrote:
> > If I had to implement this: I would choose to do the optimization in
> > __rcu_process_callbacks() create small on-call-stack ptr-array for
> > kfree_bulk().  I would only optimize the case that call kfree()
> > directly.  In the while(list) loop I would defer calling
> > __rcu_reclaim() for __is_kfree_rcu_offset(head->func), and instead add
> > them to the ptr-array (and flush if the array is full in loop, and
> > kfree_bulk flush after loop).
> > 
> > The real advantage of kfree_bulk() comes from amortizing the per kfree
> > (behind-the-scenes) sync cost.  There is an additional benefit, because
> > objects comes from RCU and will hit a slower path in SLUB.   The SLUB
> > allocator is very fast for objects that gets recycled quickly (short
> > lifetime), non-locked (cpu-local) double-cmpxchg.  But slower for
> > longer-lived/more-outstanding objects, as this hits a slower code-path,
> > fully locked (cross-cpu) double-cmpxchg.  
> 
> Something like this ...  (compile tested only)
> 
> Considerably less code; Rao, what do you think?

I am sorry, but I am not at all fan of this approach.

If we are going to make this sort of change, we should do so in a way
that allows the slab code to actually do the optimizations that might
make this sort of thing worthwhile.  After all, if the main goal was small
code size, the best approach is to drop kfree_bulk() and get on with life
in the usual fashion.

I would prefer to believe that something like kfree_bulk() can help,
and if that is the case, we should give it a chance to do things like
group kfree_rcu() requests by destination slab and soforth, allowing
batching optimizations that might provide more significant increases
in performance.  Furthermore, having this in slab opens the door to
slab taking emergency action when memory is low.

But for the patch below, NAK.

							Thanx, Paul

> diff --git a/kernel/rcu/rcu.h b/kernel/rcu/rcu.h
> index 59c471de342a..5ac4ed077233 100644
> --- a/kernel/rcu/rcu.h
> +++ b/kernel/rcu/rcu.h
> @@ -174,20 +174,19 @@ static inline void debug_rcu_head_unqueue(struct rcu_head *head)
>  }
>  #endif	/* #else !CONFIG_DEBUG_OBJECTS_RCU_HEAD */
> 
> -void kfree(const void *);
> -
>  /*
>   * Reclaim the specified callback, either by invoking it (non-lazy case)
>   * or freeing it directly (lazy case).  Return true if lazy, false otherwise.
>   */
> -static inline bool __rcu_reclaim(const char *rn, struct rcu_head *head)
> +static inline bool __rcu_reclaim(const char *rn, struct rcu_head *head, void **kfree,
> +				unsigned int *idx)
>  {
>  	unsigned long offset = (unsigned long)head->func;
> 
>  	rcu_lock_acquire(&rcu_callback_map);
>  	if (__is_kfree_rcu_offset(offset)) {
>  		RCU_TRACE(trace_rcu_invoke_kfree_callback(rn, head, offset);)
> -		kfree((void *)head - offset);
> +		kfree[*idx++] = (void *)head - offset;
>  		rcu_lock_release(&rcu_callback_map);
>  		return true;
>  	} else {
> diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
> index f9c0ca2ccf0c..7e13979b4697 100644
> --- a/kernel/rcu/tree.c
> +++ b/kernel/rcu/tree.c
> @@ -2725,6 +2725,8 @@ static void rcu_do_batch(struct rcu_state *rsp, struct rcu_data *rdp)
>  	struct rcu_head *rhp;
>  	struct rcu_cblist rcl = RCU_CBLIST_INITIALIZER(rcl);
>  	long bl, count;
> +	void *to_free[16];
> +	unsigned int to_free_idx = 0;
> 
>  	/* If no callbacks are ready, just return. */
>  	if (!rcu_segcblist_ready_cbs(&rdp->cblist)) {
> @@ -2755,8 +2757,10 @@ static void rcu_do_batch(struct rcu_state *rsp, struct rcu_data *rdp)
>  	rhp = rcu_cblist_dequeue(&rcl);
>  	for (; rhp; rhp = rcu_cblist_dequeue(&rcl)) {
>  		debug_rcu_head_unqueue(rhp);
> -		if (__rcu_reclaim(rsp->name, rhp))
> +		if (__rcu_reclaim(rsp->name, rhp, to_free, &to_free_idx))
>  			rcu_cblist_dequeued_lazy(&rcl);
> +		if (to_free_idx == 16)
> +			kfree_bulk(16, to_free);
>  		/*
>  		 * Stop only if limit reached and CPU has something to do.
>  		 * Note: The rcl structure counts down from zero.
> @@ -2766,6 +2770,8 @@ static void rcu_do_batch(struct rcu_state *rsp, struct rcu_data *rdp)
>  		     (!is_idle_task(current) && !rcu_is_callbacks_kthread())))
>  			break;
>  	}
> +	if (to_free_idx)
> +		kfree_bulk(to_free_idx, to_free);
> 
>  	local_irq_save(flags);
>  	count = -rcl.len;
> diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
> index db85ca3975f1..4127be06759b 100644
> --- a/kernel/rcu/tree_plugin.h
> +++ b/kernel/rcu/tree_plugin.h
> @@ -2189,6 +2189,8 @@ static int rcu_nocb_kthread(void *arg)
>  	struct rcu_head *next;
>  	struct rcu_head **tail;
>  	struct rcu_data *rdp = arg;
> +	void *to_free[16];
> +	unsigned int to_free_idx = 0;
> 
>  	/* Each pass through this loop invokes one batch of callbacks */
>  	for (;;) {
> @@ -2226,13 +2228,18 @@ static int rcu_nocb_kthread(void *arg)
>  			}
>  			debug_rcu_head_unqueue(list);
>  			local_bh_disable();
> -			if (__rcu_reclaim(rdp->rsp->name, list))
> +			if (__rcu_reclaim(rdp->rsp->name, list, to_free,
> +								&to_free_idx))
>  				cl++;
>  			c++;
> +			if (to_free_idx == 16)
> +				kfree_bulk(16, to_free);
>  			local_bh_enable();
>  			cond_resched_rcu_qs();
>  			list = next;
>  		}
> +		if (to_free_idx)
> +			kfree_bulk(to_free_idx, to_free);
>  		trace_rcu_batch_end(rdp->rsp->name, c, !!list, 0, 0, 1);
>  		smp_mb__before_atomic();  /* _add after CB invocation. */
>  		atomic_long_add(-c, &rdp->nocb_q_count);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
