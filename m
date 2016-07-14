Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92FF16B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:51:32 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u25so140163651qtb.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:51:32 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id g12si1189742qtg.83.2016.07.14.05.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 05:51:31 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id f65so65414051wmi.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:51:31 -0700 (PDT)
Date: Thu, 14 Jul 2016 14:51:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160714125129.GA12289@dhcp22.suse.cz>
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-07-16 11:02:15, Mikulas Patocka wrote:
> On Wed, 13 Jul 2016, Michal Hocko wrote:
[...]

We are discussing several topics together so let's focus on this
particlar thing for now

> > > The kernel 4.7-rc almost deadlocks in another way. The machine got stuck 
> > > and the following stacktrace was obtained when swapping to dm-crypt.
> > > 
> > > We can see that dm-crypt does a mempool allocation. But the mempool 
> > > allocation somehow falls into throttle_vm_writeout. There, it waits for 
> > > 0.1 seconds. So, as a result, the dm-crypt worker thread ends up 
> > > processing requests at an unusually slow rate of 10 requests per second 
> > > and it results in the machine being stuck (it would proabably recover if 
> > > we waited for extreme amount of time).
> > 
> > Hmm, that throttling is there since ever basically. I do not see what
> > would have changed that recently, but I haven't looked too close to be
> > honest.
> > 
> > I agree that throttling a flusher (which this worker definitely is)
> > doesn't look like a correct thing to do. We have PF_LESS_THROTTLE for
> > this kind of things. So maybe the right thing to do is to use this flag
> > for the dm_crypt worker:
> > 
> > diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> > index 4f3cb3554944..0b806810efab 100644
> > --- a/drivers/md/dm-crypt.c
> > +++ b/drivers/md/dm-crypt.c
> > @@ -1392,11 +1392,14 @@ static void kcryptd_async_done(struct crypto_async_request *async_req,
> >  static void kcryptd_crypt(struct work_struct *work)
> >  {
> >  	struct dm_crypt_io *io = container_of(work, struct dm_crypt_io, work);
> > +	unsigned int pflags = current->flags;
> >  
> > +	current->flags |= PF_LESS_THROTTLE;
> >  	if (bio_data_dir(io->base_bio) == READ)
> >  		kcryptd_crypt_read_convert(io);
> >  	else
> >  		kcryptd_crypt_write_convert(io);
> > +	tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
> >  }
> >  
> >  static void kcryptd_queue_crypt(struct dm_crypt_io *io)
> 
> ^^^ That fixes just one specific case - but there may be other threads 
> doing mempool allocations in the device mapper subsystem - and you would 
> need to mark all of them.

Now that I am thinking about it some more. Are there any mempool users
which would actually want to be throttled? I would expect mempool users
are necessary to push IO through and throttle them sounds like a bad
decision in the first place but there might be other mempool users which
could cause issues. Anyway how about setting PF_LESS_THROTTLE
unconditionally inside mempool_alloc? Something like the following:

diff --git a/mm/mempool.c b/mm/mempool.c
index 8f65464da5de..e21fb632983f 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -310,7 +310,8 @@ EXPORT_SYMBOL(mempool_resize);
  */
 void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 {
-	void *element;
+	unsigned int pflags = current->flags;
+	void *element = NULL;
 	unsigned long flags;
 	wait_queue_t wait;
 	gfp_t gfp_temp;
@@ -327,6 +328,12 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
 
+	/*
+	 * Make sure that the allocation doesn't get throttled during the
+	 * reclaim
+	 */
+	if (gfpflags_allow_blocking(gfp_mask))
+		current->flags |= PF_LESS_THROTTLE;
 repeat_alloc:
 	if (likely(pool->curr_nr)) {
 		/*
@@ -339,7 +346,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	element = pool->alloc(gfp_temp, pool->pool_data);
 	if (likely(element != NULL))
-		return element;
+		goto out;
 
 	spin_lock_irqsave(&pool->lock, flags);
 	if (likely(pool->curr_nr)) {
@@ -352,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 		 * for debugging.
 		 */
 		kmemleak_update_trace(element);
-		return element;
+		goto out;
 	}
 
 	/*
@@ -369,7 +376,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
 	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
 		spin_unlock_irqrestore(&pool->lock, flags);
-		return NULL;
+		goto out;
 	}
 
 	/* Let's wait for someone else to return an element to @pool */
@@ -386,6 +393,10 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	finish_wait(&pool->wait, &wait);
 	goto repeat_alloc;
+out:
+	if (gfpflags_allow_blocking(gfp_mask))
+		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
+	return element;
 }
 EXPORT_SYMBOL(mempool_alloc);
 

> I would try the patch below - generally, allocations from the mempool 
> subsystem should not wait in the memory allocator at all. I don't know if 
> there are other cases when these allocations can sleep. I'm interested if 
> it fixes Ondrej's case - or if it uncovers some other sleeping.

__GFP_NORETRY is used outside of mempool allocator as well and
throttling them sounds like a proper think to do. The primary point of
throttle_vm_writeout is to slow down reclaim so that it doesn't generate
excessive amount of dirty pages. It used to be a bigger deal in the past
when we initiated regular IO from the direct reclaim but we can still
generate swap IO these days. So I would rather come up with a more
robust solution.

> An alternate possibility would be to drop the flag __GFP_DIRECT_RECLAIM in 
> mempool_alloc - so that mempool allocations never sleep in the allocator.

Hmm, that would mean that the retry loop would completely rely on kswapd
doing forward progress. But note that kswapd might trigger IO and get
stuck waiting for the FS. GFP_NOIO request might be hopelessly
inefficient on its own but at least we try to reclaim something which
sounds better to me than looping and relying only on kswapd. I do not
see other potential side effects of such a change but my gut feeling
tells me this is not quite right. It works around a problem that is at a
different layer.
 
> ---
>  mm/page-writeback.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> Index: linux-4.7-rc7/mm/page-writeback.c
> ===================================================================
> --- linux-4.7-rc7.orig/mm/page-writeback.c	2016-07-12 20:57:53.000000000 +0200
> +++ linux-4.7-rc7/mm/page-writeback.c	2016-07-12 20:59:41.000000000 +0200
> @@ -1945,6 +1945,14 @@ void throttle_vm_writeout(gfp_t gfp_mask
>  	unsigned long background_thresh;
>  	unsigned long dirty_thresh;
>  
> +	/*
> +	 * If we came here from mempool_alloc, we don't want to wait 0.1s.
> +	 * We want to fail as soon as possible, so that the allocation is tried
> +	 * from mempool reserve.
> +	 */
> +	if (unlikely(gfp_mask & __GFP_NORETRY))
> +		return;
> +
>          for ( ; ; ) {
>  		global_dirty_limits(&background_thresh, &dirty_thresh);
>  		dirty_thresh = hard_dirty_limit(&global_wb_domain, dirty_thresh);
> 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
