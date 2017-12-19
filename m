Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBB486B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:30:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m17so13048489pgu.19
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:30:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x21si5110469pgc.295.2017.12.19.11.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 11:30:45 -0800 (PST)
Date: Tue, 19 Dec 2017 11:30:39 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171219193039.GB6515@bombadil.infradead.org>
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Tue, Dec 19, 2017 at 09:52:27AM -0800, rao.shoaib@oracle.com wrote:
> @@ -129,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
>  
>  	for (i = 0; i < nr; i++) {
>  		void *x = p[i] = kmem_cache_alloc(s, flags);
> +
>  		if (!x) {
>  			__kmem_cache_free_bulk(s, i, p);
>  			return 0;

Don't mix whitespace changes with significant patches.

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

Are you sure we can't call kfree_rcu() from interrupt context?

> +		rbfc = rbf->rbf_container;
> +		rbfc->rbfc_entries = 0;
> +
> +		if (rbf->rbf_list_head != NULL)
> +			__rcu_bulk_schedule_list(rbf);

You've broken RCU.  Consider this scenario:

Thread 1	Thread 2		Thread 3
kfree_rcu(a)	
		schedule()
schedule()	
		gets pointer to b
kfree_rcu(b)	
					processes rcu callbacks
		uses b

Thread 3 will free a and also free b, so thread 2 is going to use freed
memory and go splat.  You can't batch up memory to be freed without
taking into account the grace periods.

It might make sense for RCU to batch up all the memory it's going to free
in a single grace period, and hand it all off to slub at once, but that's
not what you've done here.


I've been doing a lot of thinking about this because I really want a
way to kfree_rcu() an object without embedding a struct rcu_head in it.
But I see no way to do that today; even if we have an external memory
allocation to point to the object to be freed, we have to keep track of
the grace periods.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
