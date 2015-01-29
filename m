Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id AE02A6B006E
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 03:16:48 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so6357752wib.1
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 00:16:48 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id n4si1796194wia.45.2015.01.29.00.16.46
        for <linux-mm@kvack.org>;
        Thu, 29 Jan 2015 00:16:47 -0800 (PST)
Date: Thu, 29 Jan 2015 08:16:43 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [Intel-gfx] memcontrol.c BUG
Message-ID: <20150129081643.GK25850@nuc-i3427.alporthouse.com>
References: <CAPM=9tyyP_pKpWjc7LBZU7e6wAt26XGZsyhRh7N497B2+28rrQ@mail.gmail.com>
 <20150128084852.GC28132@nuc-i3427.alporthouse.com>
 <20150128143242.GF6542@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128143242.GF6542@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Airlie <airlied@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Jet Chen <jet.chen@intel.com>, Felipe Balbi <balbi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Jan 28, 2015 at 03:32:43PM +0100, Michal Hocko wrote:
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

Generally, yes. The shmemfs filp is exported through a vm_mmap() as well
as pinned into the GPU via shmem_read_mapping_page_gfp(). But I would
not expect that to be the case very often, if at all, on 965GM as the
two access paths are incoherent. Still it sounds promising, hopefully
Dave can put it into a fedora kernel for testing?
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
