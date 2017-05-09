Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA4FA6B03EB
	for <linux-mm@kvack.org>; Tue,  9 May 2017 05:18:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p134so14274108wmg.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 02:18:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g129si12189702wmf.146.2017.05.09.02.18.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 02:18:25 -0700 (PDT)
Date: Tue, 9 May 2017 11:18:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Message-ID: <20170509091823.GF6481@dhcp22.suse.cz>
References: <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz>
 <87pofxk20k.fsf@firstfloor.org>
 <20170428060755.GA8143@dhcp22.suse.cz>
 <20170428073136.GE8143@dhcp22.suse.cz>
 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
 <20170428134831.GB26705@dhcp22.suse.cz>
 <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
 <20170502185507.GB19165@dhcp22.suse.cz>
 <20170508025827.GA4913@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170508025827.GA4913@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon 08-05-17 02:58:36, Naoya Horiguchi wrote:
> On Tue, May 02, 2017 at 08:55:07PM +0200, Michal Hocko wrote:
> > On Tue 02-05-17 16:59:30, Laurent Dufour wrote:
> > > On 28/04/2017 15:48, Michal Hocko wrote:
> > [...]
> > > > This is getting quite hairy. What is the expected page count of the
> > > > hwpoison page?
> > 
> > OK, so from the quick check of the hwpoison code it seems that the ref
> > count will be > 1 (from get_hwpoison_page).
> > 
> > > > I guess we would need to update the VM_BUG_ON in the
> > > > memcg uncharge code to ignore the page count of hwpoison pages if it can
> > > > be arbitrary.
> > > 
> > > Based on the experiment I did, page count == 2 when isolate_lru_page()
> > > succeeds, even in the case of a poisoned page.
> > 
> > that would make some sense to me. The page should have been already
> > unmapped therefore but memory_failure increases the ref count and 1 is
> > for isolate_lru_page().
> 
> # sorry for late reply, I was on holidays last week...
> 
> Right, and the refcount taken for memory_failure is not freed after
> memory_failure() returns. unpoison_memory() does free the refcount.

OK, from the charge POV this would be safe because we clear page->memcg
so it wouldn't get uncharged more times.

> > > In my case I think this
> > > is because the page is still used by the process which is calling madvise().
> > > 
> > > I'm wondering if I'm looking at the right place. May be the poisoned
> > > page should remain attach to the memory_cgroup until no one is using it.
> > > In that case this means that something should be done when the page is
> > > off-lined... I've to dig further here.
> > 
> > No, AFAIU the page will not drop the reference count down to 0 in most
> > cases. Maybe there are some scenarios where this can happen but I would
> > expect that the poisoned page will be mapped and in use most of the time
> > and won't drop down 0. And then we should really uncharge it because it
> > will pin the memcg and make it unfreeable which doesn't seem to be what
> > we want.  So does the following work reasonable? Andi, Johannes, what do
> > you think? I cannot say I would be really comfortable touching hwpoison
> > code as I really do not understand the workflow. Maybe we want to move
> > this uncharge down to memory_failure() right before we report success?
> 
> memory_failure() can be called for any types of page (including slab or
> any kernel/driver pages), and the reported problem seems happen only on
> in-use user pages, so uncharging in delete_from_lru_cache() as done below
> looks better to me.

Yeah, we do see problems only for LRU/page cache pages but my
understanding is that error_states (e.g. me_kernel for the kernel
memory) might change in the future and then we wouldn't catch the same
bug, no?

> > ---
> > From 8bf0791bcf35996a859b6d33fb5494e5b53de49d Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 2 May 2017 20:32:24 +0200
> > Subject: [PATCH] hwpoison, memcg: forcibly uncharge LRU pages
> > 
> > Laurent Dufour has noticed that hwpoinsoned pages are kept charged. In
> > his particular case he has hit a bad_page("page still charged to cgroup")
> > when onlining a hwpoison page.
> 
> > While this looks like something that shouldn't
> > happen in the first place because onlining hwpages and returning them to
> > the page allocator makes only little sense it shows a real problem.
> > 
> > hwpoison pages do not get freed usually so we do not uncharge them (at
> > least not since 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")).
> > Each charge pins memcg (since e8ea14cc6ead ("mm: memcontrol: take a css
> > reference for each charged page")) as well and so the mem_cgroup and the
> > associated state will never go away. Fix this leak by forcibly
> > uncharging a LRU hwpoisoned page in delete_from_lru_cache(). We also
> > have to tweak uncharge_list because it cannot rely on zero ref count
> > for these pages.
> > 
> > Fixes: 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API")
> > Reported-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks! I will wait a day or two for Johannes and repost the patch.
Andrew could you drop
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-uncharge-poisoned-pages.patch
in the mean time, please?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
