Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 767D66B006C
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 21:04:27 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so45932905pab.9
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:04:27 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id wq4si12072045pab.92.2015.01.29.18.04.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 18:04:26 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so45966785pab.12
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:04:26 -0800 (PST)
Date: Thu, 29 Jan 2015 18:04:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Intel-gfx] memcontrol.c BUG
In-Reply-To: <20150128143242.GF6542@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1501291751170.1761@eggly.anvils>
References: <CAPM=9tyyP_pKpWjc7LBZU7e6wAt26XGZsyhRh7N497B2+28rrQ@mail.gmail.com> <20150128084852.GC28132@nuc-i3427.alporthouse.com> <20150128143242.GF6542@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Dave Airlie <airlied@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Jet Chen <jet.chen@intel.com>, Felipe Balbi <balbi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, 28 Jan 2015, Michal Hocko wrote:
> On Wed 28-01-15 08:48:52, Chris Wilson wrote:
> > On Wed, Jan 28, 2015 at 08:13:06AM +1000, Dave Airlie wrote:
> > > https://bugzilla.redhat.com/show_bug.cgi?id=1165369
> > > 
> > > ov 18 09:23:22 elissa.gathman.org kernel: page:f5e36a40 count:2
> > > mapcount:0 mapping:  (null) index:0x0
> > > Nov 18 09:23:22 elissa.gathman.org kernel: page flags:
> > > 0x80090029(locked|uptodate|lru|swapcache|swapbacked)
> > > Nov 18 09:23:22 elissa.gathman.org kernel: page dumped because:
> > > VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage))
> > > Nov 18 09:23:23 elissa.gathman.org kernel: ------------[ cut here ]------------
> > > Nov 18 09:23:23 elissa.gathman.org kernel: kernel BUG at mm/memcontrol.c:6733!
> 
> I guess this matches the following bugon in your kernel:
>         VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
> 
> so the oldpage is on the LRU list already. I am completely unfamiliar
> with 965GM but is the page perhaps shared with somebody with a different
> gfp mask requirement (e.g. userspace accessing the memory via mmap)? So
> the other (racing) caller didn't need to move the page and put it on
> LRU.

It would be surprising (but not impossible) for oldpage not to be on
the LRU already: it's a swapin readahead page that has every right to
be on LRU, but turns out to have been allocated from an unsuitable zone,
once we discover that it's needed in one of these odd hardware-limited
mappings.  (Whereas newpage is newly allocated and not yet on LRU.)

> 
> If yes we need to tell shmem_replace_page to do the lrucare handling.

Absolutely, thanks Michal.  It would also be good to change the comment
on mem_cgroup_migrate() in mm/memcontrol.c, from "@lrucare: both pages..."
to "@lrucare: either or both pages..." - though I certainly won't pretend
that the corrected wording would have prevented this bug creeping in!

> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 339e06639956..e3cdc1a16c0f 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1013,7 +1013,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>  		 */
>  		oldpage = newpage;
>  	} else {
> -		mem_cgroup_migrate(oldpage, newpage, false);
> +		mem_cgroup_migrate(oldpage, newpage, true);
>  		lru_cache_add_anon(newpage);
>  		*pagep = newpage;
>  	}

Acked-by: Hugh Dickins <hughd@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
