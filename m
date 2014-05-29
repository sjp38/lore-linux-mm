Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id 701896B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 23:48:41 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id m1so12285132oag.28
        for <linux-mm@kvack.org>; Wed, 28 May 2014 20:48:41 -0700 (PDT)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id br7si23630624oec.30.2014.05.28.20.48.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 20:48:40 -0700 (PDT)
Received: by mail-ob0-f181.google.com with SMTP id wm4so11490219obc.26
        for <linux-mm@kvack.org>; Wed, 28 May 2014 20:48:40 -0700 (PDT)
Date: Wed, 28 May 2014 22:48:35 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCHv3 3/6] mm/zpool: implement common zpool api to
 zbud/zsmalloc
Message-ID: <20140529034835.GA18063@cerebellum.variantweb.net>
References: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-4-git-send-email-ddstreet@ieee.org>
 <20140527220639.GA25781@cerebellum.variantweb.net>
 <CALZtONBp+ckT222fcXQgGOx4AgNBLA7D6ZOKB4Zg_RqX1do0vw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBp+ckT222fcXQgGOx4AgNBLA7D6ZOKB4Zg_RqX1do0vw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, May 27, 2014 at 08:06:28PM -0400, Dan Streetman wrote:
> On Tue, May 27, 2014 at 6:06 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> > On Sat, May 24, 2014 at 03:06:06PM -0400, Dan Streetman wrote:
<snip>
> >> + * Returns: 0 on success, negative value on error/failure.
> >> + */
> >> +int zpool_shrink(struct zpool *pool, size_t size);
> >
> > This should take a number of pages to be reclaimed, not a size.  The
> > user can evict their own object to reclaim a certain number of bytes
> > from the pool.  What the user can't do is reclaim a page since it is not
> > aware of the arrangement of the stored objects in the memory pages.
> 
> Yes I suppose that's true, I'll update it for v4...
> 
> >
> > Also in patch 5/6 of six I see:
> >
> > -               if (zbud_reclaim_page(zswap_pool, 8)) {
> > +               if (zpool_shrink(zswap_pool, PAGE_SIZE)) {
> >
> > but then in 4/6 I see:
> >
> > +int zbud_zpool_shrink(void *pool, size_t size)
> > +{
> > +       return zbud_reclaim_page(pool, 8);
> > +}
> >
> > That is why it didn't completely explode on you since the zbud logic
> > is still reclaiming pages.
> 
> Ha, yes clearly I neglected to translate between the size and the
> number of pages there, oops!
> 
> On this topic - 8 retries seems very arbitrary.  Does it make sense to
> include retrying in zbud and/or zpool at all?  The caller can easily
> retry any number of times themselves, especially since zbud (and
> eventually zsmalloc) will return -EAGAIN if the caller should retry.

Yeah, the retries argument in the zbud API isn't good.  You can change
the zbud_reclaim_page() to just try once and return -EAGAIN if you want
and I'll be in favor of that.

That did make me think of something else though.  The zpool API is
zpool_shrink() with, what will be, a number of pages.  The zbud API is
zbud_reclaim_page() which, as the name implies, reclaims one page.  So
it seems that you would need a loop in zbud_zpool_shrink() to try to
reclaim a multiple number of pages.

> 
> >
> >> +
> >> +/**
> >> + * zpool_map_handle() - Map a previously allocated handle into memory
> >> + * @pool     The zpool that the handle was allocated from
> >> + * @handle   The handle to map
> >> + * @mm       How the memory should be mapped
> >> + *
<snip>
> >> +int zpool_evict(void *pool, unsigned long handle)
> >> +{
> >> +     struct zpool *zpool;
> >> +
> >> +     spin_lock(&pools_lock);
> >> +     list_for_each_entry(zpool, &pools_head, list) {
> >
> > You can do a container_of() here:
> >
> > zpool = container_of(pool, struct zpool, pool);
> 
> unfortunately, that's not true, since the driver pool isn't actually a
> member of the struct zpool.  The struct zpool only has a pointer to
> the driver pool.

Ah yes, got my user API vs driver API crossed here :-/

Meh, can't think of a better way for now and it doesn't cause contention
on the hot paths so... works for me.

Seth

> 
> I really wanted to use container_of(), but I think zbud/zsmalloc would
> need alternate pool creation functions that create struct zpools of
> the appropriate size with their pool embedded, and the
> driver->create() function would need to alloc and return the entire
> struct zpool, instead of just the driver pool.  Do you think that's a
> better approach?  Or is there another better way I'm missing?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
