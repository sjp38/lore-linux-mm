Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1240C6B0036
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 18:02:13 -0500 (EST)
Received: by mail-ve0-f177.google.com with SMTP id db12so9341865veb.36
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 15:02:12 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id gs7si30274745veb.91.2013.12.02.15.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 15:02:12 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id v1so8465153yhn.18
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 15:02:11 -0800 (PST)
Date: Mon, 2 Dec 2013 15:02:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
In-Reply-To: <20131202132201.GC18838@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312021452510.13465@chino.kir.corp.google.com>
References: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com> <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com> <20131127163916.GB3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com> <20131127225340.GE3556@cmpxchg.org> <alpine.DEB.2.02.1311271526080.22848@chino.kir.corp.google.com> <20131128102049.GF2761@dhcp22.suse.cz> <alpine.DEB.2.02.1311291543400.22413@chino.kir.corp.google.com>
 <20131202132201.GC18838@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 2 Dec 2013, Michal Hocko wrote:

> > > What if the callers simply cannot deal with the allocation failure?
> > > 84235de394d97 (fs: buffer: move allocation failure loop into the
> > > allocator) describes one such case when __getblk_slow tries desperately
> > > to grow buffers relying on the reclaim to free something. As there might
> > > be no reclaim going on we are screwed.
> > > 
> > 
> > My suggestion is to spin, not return NULL. 
> 
> Spin on which level? The whole point of this change was to not spin for
> ever because the caller might sit on top of other locks which might
> prevent somebody else to die although it has been killed.
> 

See my question about the non-memcg page allocator behavior below.

> > Bypassing to the root memcg 
> > can lead to a system oom condition whereas if memcg weren't involved at 
> > all the page allocator would just spin (because of !__GFP_FS).
> 
> I am confused now. The page allocation has already happened at the time
> we are doing the charge. So the global OOM would have happened already.
> 

That's precisely the point, the successful charges can allow additional 
page allocations to occur and cause system oom conditions if you don't 
have memcg isolation.  Some customers, including us, use memcg to ensure 
that a set of processes cannot use more resources than allowed.  Any 
bypass opens up the possibility of additional memory allocations that 
cause the system to be oom and then we end up requiring a userspace oom 
handler because our policy is complex enough that it cannot be effected 
simply by /proc/pid/oom_score_adj.

I'm not quite sure how significant of a point this is, though, because it 
depends on the caller doing the __GFP_NOFAIL allocations that allow the 
bypass.  If you're doing

	for (i = 0; i < 1 << 20; i++)
		page[i] = alloc_page(GFP_NOFS | __GFP_NOFAIL);

it can become significant, but I'm unsure of how much memory all callers 
end up allocating in this context.

> > > That being said, while I do agree with you that we should strive for
> > > isolation as much as possible there are certain cases when this is
> > > impossible to achieve without seeing much worse consequences. For now,
> > > we hope that __GFP_NOFAIL is used very scarcely.
> > 
> > If that's true, why not bypass the per-zone min watermarks in the page 
> > allocator as well to allow these allocations to succeed?
> 
> Allocations are already done. We simply cannot charge that allocation
> because we have reached the hard limit. And the said allocation might
> prevent OOM action to proceed due to held locks.

I'm referring to the generic non-memcg page allocator behavior.  Forget 
memcg for a moment.  What is the behavior in the _page_allocator_ for 
GFP_NOFS | __GFP_NOFAIL?  Do we spin forever if reclaim fails or do we 
bypas the per-zone min watermarks to allow it to allocate because "it 
needs to succeed, it may be holding filesystem locks"?

It's already been acknowledged in this thread that no bypassing is done 
in the page allocator and it just spins.  There's some handwaving saying 
that since the entire system is oom that there is a greater chance that 
memory will be freed by something else, but that's just handwaving and is 
certainly no guaranteed.

So, my question again: why not bypass the per-zone min watermarks in the 
page allocator?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
