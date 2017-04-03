Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCE16B039F
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 04:47:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f50so23055914wrf.7
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 01:47:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n136si14307104wmg.104.2017.04.03.01.47.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 01:47:33 -0700 (PDT)
Date: Mon, 3 Apr 2017 10:47:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in
 zswap_frontswap_store()
Message-ID: <20170403084729.GG24661@dhcp22.suse.cz>
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
 <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri 31-03-17 10:00:30, Shakeel Butt wrote:
> On Fri, Mar 31, 2017 at 8:30 AM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
> > zswap_frontswap_store() is called during memory reclaim from
> > __frontswap_store() from swap_writepage() from shrink_page_list().
> > This may happen in NOFS context, thus zswap shouldn't use __GFP_FS,
> > otherwise we may renter into fs code and deadlock.
> > zswap_frontswap_store() also shouldn't use __GFP_IO to avoid recursion
> > into itself.
> >
> 
> Is it possible to enter fs code (or IO) from zswap_frontswap_store()
> other than recursive memory reclaim? However recursive memory reclaim
> is protected through PF_MEMALLOC task flag. The change seems fine but
> IMHO reasoning needs an update. Adding Michal for expert opinion.

Yes this is true. I haven't checked all the callers of
zswap_frontswap_store but is it fixing any real problem or just trying
to be overly cautious.
 
Btw...

> > zswap_frontswap_store() call zpool_malloc() with __GFP_NORETRY |
> > __GFP_NOWARN | __GFP_KSWAPD_RECLAIM, so let's use the same flags for
> > zswap_entry_cache_alloc() as well, instead of GFP_KERNEL.
> >
> > Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > ---
> >  mm/zswap.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/zswap.c b/mm/zswap.c
> > index eedc278..12ad7e9 100644
> > --- a/mm/zswap.c
> > +++ b/mm/zswap.c
> > @@ -966,6 +966,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> >         struct zswap_tree *tree = zswap_trees[type];
> >         struct zswap_entry *entry, *dupentry;
> >         struct crypto_comp *tfm;
> > +       gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;

This doesn't trigger direct reclaim so __GFP_NORETRY is bogus. I suspect
you didn't want GFP_NOWAIT alternative.

[...]
> > @@ -1017,9 +1018,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> >
> >         /* store */
> >         len = dlen + sizeof(struct zswap_header);
> > -       ret = zpool_malloc(entry->pool->zpool, len,
> > -                          __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
> > -                          &handle);
> > +       ret = zpool_malloc(entry->pool->zpool, len, gfp, &handle);

and here we used to do GFP_NOWAIT alternative already. What is going on
here?

> >         if (ret == -ENOSPC) {
> >                 zswap_reject_compress_poor++;
> >                 goto put_dstmem;
> > --
> > 2.10.2
> >

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
