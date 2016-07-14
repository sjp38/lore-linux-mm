Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14D556B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 10:59:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so58098080wma.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 07:59:40 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id s70si34190075wme.140.2016.07.14.07.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 07:59:38 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so4996811wma.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 07:59:38 -0700 (PDT)
Date: Thu, 14 Jul 2016 16:59:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160714145937.GB12289@dhcp22.suse.cz>
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607140952550.1102@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607140952550.1102@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On Thu 14-07-16 10:00:16, Mikulas Patocka wrote:
> 
> 
> On Thu, 14 Jul 2016, Michal Hocko wrote:
> 
> > On Wed 13-07-16 11:02:15, Mikulas Patocka wrote:
> 
> > > > diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> > > > index 4f3cb3554944..0b806810efab 100644
> > > > --- a/drivers/md/dm-crypt.c
> > > > +++ b/drivers/md/dm-crypt.c
> > > > @@ -1392,11 +1392,14 @@ static void kcryptd_async_done(struct crypto_async_request *async_req,
> > > >  static void kcryptd_crypt(struct work_struct *work)
> > > >  {
> > > >  	struct dm_crypt_io *io = container_of(work, struct dm_crypt_io, work);
> > > > +	unsigned int pflags = current->flags;
> > > >  
> > > > +	current->flags |= PF_LESS_THROTTLE;
> > > >  	if (bio_data_dir(io->base_bio) == READ)
> > > >  		kcryptd_crypt_read_convert(io);
> > > >  	else
> > > >  		kcryptd_crypt_write_convert(io);
> > > > +	tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
> > > >  }
> > > >  
> > > >  static void kcryptd_queue_crypt(struct dm_crypt_io *io)
> > > 
> > > ^^^ That fixes just one specific case - but there may be other threads 
> > > doing mempool allocations in the device mapper subsystem - and you would 
> > > need to mark all of them.
> > 
> > Now that I am thinking about it some more. Are there any mempool users
> > which would actually want to be throttled? I would expect mempool users
> > are necessary to push IO through and throttle them sounds like a bad
> > decision in the first place but there might be other mempool users which
> > could cause issues. Anyway how about setting PF_LESS_THROTTLE
> > unconditionally inside mempool_alloc? Something like the following:
> >
> > diff --git a/mm/mempool.c b/mm/mempool.c
> > index 8f65464da5de..e21fb632983f 100644
> > --- a/mm/mempool.c
> > +++ b/mm/mempool.c
> > @@ -310,7 +310,8 @@ EXPORT_SYMBOL(mempool_resize);
> >   */
> >  void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  {
> > -	void *element;
> > +	unsigned int pflags = current->flags;
> > +	void *element = NULL;
> >  	unsigned long flags;
> >  	wait_queue_t wait;
> >  	gfp_t gfp_temp;
> > @@ -327,6 +328,12 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  
> >  	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
> >  
> > +	/*
> > +	 * Make sure that the allocation doesn't get throttled during the
> > +	 * reclaim
> > +	 */
> > +	if (gfpflags_allow_blocking(gfp_mask))
> > +		current->flags |= PF_LESS_THROTTLE;
> >  repeat_alloc:
> >  	if (likely(pool->curr_nr)) {
> >  		/*
> > @@ -339,7 +346,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  
> >  	element = pool->alloc(gfp_temp, pool->pool_data);
> >  	if (likely(element != NULL))
> > -		return element;
> > +		goto out;
> >  
> >  	spin_lock_irqsave(&pool->lock, flags);
> >  	if (likely(pool->curr_nr)) {
> > @@ -352,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  		 * for debugging.
> >  		 */
> >  		kmemleak_update_trace(element);
> > -		return element;
> > +		goto out;
> >  	}
> >  
> >  	/*
> > @@ -369,7 +376,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
> >  	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
> >  		spin_unlock_irqrestore(&pool->lock, flags);
> > -		return NULL;
> > +		goto out;
> >  	}
> >  
> >  	/* Let's wait for someone else to return an element to @pool */
> > @@ -386,6 +393,10 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  
> >  	finish_wait(&pool->wait, &wait);
> >  	goto repeat_alloc;
> > +out:
> > +	if (gfpflags_allow_blocking(gfp_mask))
> > +		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
> > +	return element;
> >  }
> >  EXPORT_SYMBOL(mempool_alloc);
> >  
> 
> But it needs other changes to honor the PF_LESS_THROTTLE flag:
> 
> static int current_may_throttle(void)
> {
>         return !(current->flags & PF_LESS_THROTTLE) ||
>                 current->backing_dev_info == NULL ||
>                 bdi_write_congested(current->backing_dev_info);
> }
> --- if you set PF_LESS_THROTTLE, current_may_throttle may still return 
> true if one of the other conditions is met.

That is true but doesn't that mean that the device is congested and
waiting a bit is the right thing to do?

> shrink_zone_memcg calls throttle_vm_writeout without checking 
> PF_LESS_THROTTLE at all.

Yes it doesn't call it because it relies on
global_dirty_limits()->domain_dirty_limits() to DTRT. It will give the
caller with PF_LESS_THROTTLE some boost wrt. all other writers.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
