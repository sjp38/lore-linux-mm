Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8EB6B006C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 10:00:56 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id w62so39507645wes.7
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 07:00:55 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id n6si23718468wic.21.2015.02.02.07.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 07:00:54 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id b13so39126125wgh.13
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 07:00:53 -0800 (PST)
Date: Mon, 2 Feb 2015 16:00:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg, shmem: fix shmem migration to use lrucare. (was: Re:
 [Intel-gfx] memcontrol.c BUG)
Message-ID: <20150202150050.GD4583@dhcp22.suse.cz>
References: <CAPM=9tyyP_pKpWjc7LBZU7e6wAt26XGZsyhRh7N497B2+28rrQ@mail.gmail.com>
 <20150128084852.GC28132@nuc-i3427.alporthouse.com>
 <20150128143242.GF6542@dhcp22.suse.cz>
 <alpine.LSU.2.11.1501291751170.1761@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1501291751170.1761@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Dave Airlie <airlied@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Jet Chen <jet.chen@intel.com>, Felipe Balbi <balbi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 29-01-15 18:04:15, Hugh Dickins wrote:
> On Wed, 28 Jan 2015, Michal Hocko wrote:
> > On Wed 28-01-15 08:48:52, Chris Wilson wrote:
> > > On Wed, Jan 28, 2015 at 08:13:06AM +1000, Dave Airlie wrote:
> > > > https://bugzilla.redhat.com/show_bug.cgi?id=1165369
> > > > 
> > > > ov 18 09:23:22 elissa.gathman.org kernel: page:f5e36a40 count:2
> > > > mapcount:0 mapping:  (null) index:0x0
> > > > Nov 18 09:23:22 elissa.gathman.org kernel: page flags:
> > > > 0x80090029(locked|uptodate|lru|swapcache|swapbacked)
> > > > Nov 18 09:23:22 elissa.gathman.org kernel: page dumped because:
> > > > VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage))
> > > > Nov 18 09:23:23 elissa.gathman.org kernel: ------------[ cut here ]------------
> > > > Nov 18 09:23:23 elissa.gathman.org kernel: kernel BUG at mm/memcontrol.c:6733!
> > 
> > I guess this matches the following bugon in your kernel:
> >         VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
> > 
> > so the oldpage is on the LRU list already. I am completely unfamiliar
> > with 965GM but is the page perhaps shared with somebody with a different
> > gfp mask requirement (e.g. userspace accessing the memory via mmap)? So
> > the other (racing) caller didn't need to move the page and put it on
> > LRU.
> 
> It would be surprising (but not impossible) for oldpage not to be on
> the LRU already: it's a swapin readahead page that has every right to
> be on LRU,

True, thanks for pointing this out.

> but turns out to have been allocated from an unsuitable zone,
> once we discover that it's needed in one of these odd hardware-limited
> mappings.  (Whereas newpage is newly allocated and not yet on LRU.)
> 
> > 
> > If yes we need to tell shmem_replace_page to do the lrucare handling.
> 
> Absolutely, thanks Michal.  It would also be good to change the comment
> on mem_cgroup_migrate() in mm/memcontrol.c, from "@lrucare: both pages..."
> to "@lrucare: either or both pages..." - though I certainly won't pretend
> that the corrected wording would have prevented this bug creeping in!

Yes, I have updated the wording.
 
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 339e06639956..e3cdc1a16c0f 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -1013,7 +1013,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> >  		 */
> >  		oldpage = newpage;
> >  	} else {
> > -		mem_cgroup_migrate(oldpage, newpage, false);
> > +		mem_cgroup_migrate(oldpage, newpage, true);
> >  		lru_cache_add_anon(newpage);
> >  		*pagep = newpage;
> >  	}
> 
> Acked-by: Hugh Dickins <hughd@google.com>

Thanks! The full patch is below. I wasn't sure who was the one to report
the issue so I hope the credits are right. I have marked the patch for
stable because some people are running with VM debugging enabled. AFAICS
the issue is not so harmful without debugging on because the stale
oldpage would be removed from the LRU list eventually.
---
