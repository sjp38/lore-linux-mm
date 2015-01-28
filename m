Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA0B6B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 09:32:47 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id k14so20927425wgh.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:32:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6si23295533wiw.1.2015.01.28.06.32.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 06:32:46 -0800 (PST)
Date: Wed, 28 Jan 2015 15:32:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Intel-gfx] memcontrol.c BUG
Message-ID: <20150128143242.GF6542@dhcp22.suse.cz>
References: <CAPM=9tyyP_pKpWjc7LBZU7e6wAt26XGZsyhRh7N497B2+28rrQ@mail.gmail.com>
 <20150128084852.GC28132@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128084852.GC28132@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Dave Airlie <airlied@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Jet Chen <jet.chen@intel.com>, Felipe Balbi <balbi@ti.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Wed 28-01-15 08:48:52, Chris Wilson wrote:
> On Wed, Jan 28, 2015 at 08:13:06AM +1000, Dave Airlie wrote:
> > https://bugzilla.redhat.com/show_bug.cgi?id=1165369
> > 
> > ov 18 09:23:22 elissa.gathman.org kernel: page:f5e36a40 count:2
> > mapcount:0 mapping:  (null) index:0x0
> > Nov 18 09:23:22 elissa.gathman.org kernel: page flags:
> > 0x80090029(locked|uptodate|lru|swapcache|swapbacked)
> > Nov 18 09:23:22 elissa.gathman.org kernel: page dumped because:
> > VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage))
> > Nov 18 09:23:23 elissa.gathman.org kernel: ------------[ cut here ]------------
> > Nov 18 09:23:23 elissa.gathman.org kernel: kernel BUG at mm/memcontrol.c:6733!

I guess this matches the following bugon in your kernel:
        VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);

so the oldpage is on the LRU list already. I am completely unfamiliar
with 965GM but is the page perhaps shared with somebody with a different
gfp mask requirement (e.g. userspace accessing the memory via mmap)? So
the other (racing) caller didn't need to move the page and put it on
LRU.

If yes we need to tell shmem_replace_page to do the lrucare handling.

diff --git a/mm/shmem.c b/mm/shmem.c
index 339e06639956..e3cdc1a16c0f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1013,7 +1013,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 		 */
 		oldpage = newpage;
 	} else {
-		mem_cgroup_migrate(oldpage, newpage, false);
+		mem_cgroup_migrate(oldpage, newpage, true);
 		lru_cache_add_anon(newpage);
 		*pagep = newpage;
 	}

[...]
> 965GM and that it uniquely uses
> 
> mask = GFP_HIGHUSER | __GFP_RECLAIMABLE;
> if (IS_CRESTLINE(dev) || IS_BROADWATER(dev)) {
> 	/* 965gm cannot relocate objects above 4GiB. */
> 	mask &= ~__GFP_HIGHMEM;
> 	mask |= __GFP_DMA32;
> }
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
