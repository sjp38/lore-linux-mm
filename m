Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 34AD66B0256
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 11:44:52 -0400 (EDT)
Received: by ykei199 with SMTP id i199so24669949yke.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 08:44:51 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id p136si1707418yke.111.2015.09.04.08.44.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 08:44:51 -0700 (PDT)
Received: by ykcf206 with SMTP id f206so24577968ykc.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 08:44:51 -0700 (PDT)
Date: Fri, 4 Sep 2015 11:44:48 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150904154448.GA25329@mtj.duckdns.org>
References: <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
 <20150901123612.GB8810@dhcp22.suse.cz>
 <20150901134003.GD21226@esperanza>
 <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza>
 <20150901183849.GA28824@dhcp22.suse.cz>
 <20150902093039.GA30160@esperanza>
 <20150903163243.GD10394@mtj.duckdns.org>
 <20150904111550.GB13699@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904111550.GB13699@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Vladimir.

On Fri, Sep 04, 2015 at 02:15:50PM +0300, Vladimir Davydov wrote:
> Trying a high-order page before falling back on lower order is not
> something really common. It implicitly relies on the fact that
> reclaiming memory for a new continuous high-order page is much more
> expensive than getting the same amount of order-1 pages. This is true
> for buddy alloc, but not for memcg. That's why playing such a trick with
> try_charge is wrong IMO. If such a trick becomes common, I think we will
> have to introduce a helper for it, because otherwise a change in buddy
> alloc internal logic (e.g. a defrag optimization making high order pages
> cheaper) may affect its users.

I'm having trouble following why this matters.  The layering here is
pretty clear regardless of how slab is trespassing into page
allocator's role.  memcg of course doesn't care whether an allocation
is high-order or order-1.  All it does is imposing extra restrictions
when allocating memory and all that's necessary is reasonably
satisfying the expectations expressed by the specified gfp mask.

> That said, I totally agree that memcg should handle GFP_NOWAIT, but I'm
> opposed to the idea that it should handle the tricks that rely on
> internal buddy alloc logic similar to those used by SLAB and SLUB. We'd
> better strive to hide these tricks in buddy alloc helpers and never use
> them directly.

All these don't really matter once memcg handles GFP_NOWAIT in a
reasonable manner, right?  memcg doesn't need all the fancy tricks of
the page allocator.  All it needs is honoring the intentions expressed
by the gfp mask in a reasonable way w/o systematic failures.
 
> That's why I think we need these patches and they aren't workarounds
> that can be reverted once try_charge has been taught to handle
> GFP_NOWAIT properly.

So, if this is separate slab improvements, I have no objections but
independent of that, we need to be able to handle back-to-back
GFP_NOWAIT cases and w/ the high limit punting to the return path
should work well enough.

> > You said elsewhere that GFP_NOWAIT happening back-to-back is unlikely.
> > I'm not sure how much we can commit to that statement.  GFP_KERNEL
> > allocating huge amount of memory in a single go is a kernel bug.
> > GFP_NOWAIT optimization in a hot path which is accessible to userland
> > isn't and we'll be growing more and more of them.  We need to be
> > protected against back-to-back GFP_NOWAIT allocations.
> 
> AFAIU if someone tries to allocate with GFP_NOWAIT (i.e. w/o
> __GFP_NOFAIL or __GFP_HIGH), he/she must be prepared to allocation
> failures, so there should be a safe fall back path, which fixes things
> in normal context. It doesn't mean we shouldn't do anything to satisfy
> such optimistic requests from memcg, but we may occasionally fail them.

Yes, it can fail under stress or if unluckly; however, it shouldn't
fail consistently under nominal conditions or be able to run over high
limit unchecked.

> OTOH if someone allocates with GFP_KERNEL, he/she should be prepared to
> get NULL, but in this case the whole operation will usually be aborted.
> Therefore with the possibility of all GFP_KERNEL being transformed to
> GFP_NOWAIT inside slab, memcg has to be extra cautious, because failing
> a usual GFP_NOWAIT in such a case may result not in falling back on slow
> path, but in user-visible effects like failing to open a file with
> ENOMEM. This is really difficult to achieve and I doubt it's worth
> complicating memcg code, because we can just fix SLAB/SLUB.

I'm not following you at all here.  slab too of course should fall
back to more robust gfp mask if NOWAIT fails and as long as those
failures are exceptions, it's fine.

> Regarding __GFP_NOFAIL and __GFP_HIGH, IMO we can let them go uncharged
> or charge them forcefully even if they breach the limit, because there
> shouldn't be many of them (if there were really a lot of them, they
> could deplete memory reserves and hang the system).
> 
> If all these assumptions are true, we don't need to do anything (apart
> from forcefully charging high prio allocations may be) for kmemcg to
> work satisfactory. For optimizing optimistic GFP_NOWAIT callers one can
> use memory.high instead or along with memory.max. Reclaiming memory.high
> in kernel while holding various locks can result in prio inversions
> though, but that's a different story, which could be fixed by task_work
> reclaim.

GFP_NOWAIT has a systematic problem which needs to be fixed.

> I admit I may be mistaken, but if I'm right, we may end up with really
> complex memcg reclaim logic trying to closely mimic behavior of buddy
> alloc with all its historic peculiarities. That's why I don't want to
> rush ahead "fixing" memcg reclaim before an agreement among all
> interested people is reached...

I think that's a bit out of proportion.  I'm not suggesting bringing
in all complexities of global reclaim.  There's no reason to and what
memcg deals with is inherently way simpler than actual memory
allocation.  The original patch was about fixing systematic failure
around GFP_NOWAIT close to the high limit.  We might want to do
background reclaim close to max but as long as high limit functions
correctly, that's much less of a problem at least on the v2 interface.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
