Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id D44DD6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 10:05:34 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id x48so3215541wes.18
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 07:05:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cd17si2653133wib.14.2014.09.23.07.05.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 07:05:30 -0700 (PDT)
Date: Tue, 23 Sep 2014 10:05:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140923140526.GA15014@cmpxchg.org>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144436.GG336@dhcp22.suse.cz>
 <20140922155049.GA6630@cmpxchg.org>
 <20140922172800.GA4343@dhcp22.suse.cz>
 <20140922195829.GA5197@cmpxchg.org>
 <20140923132553.GB10046@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140923132553.GB10046@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 23, 2014 at 03:25:53PM +0200, Michal Hocko wrote:
> On Mon 22-09-14 15:58:29, Johannes Weiner wrote:
> > On Mon, Sep 22, 2014 at 07:28:00PM +0200, Michal Hocko wrote:
> > > On Mon 22-09-14 11:50:49, Johannes Weiner wrote:
> > > > On Mon, Sep 22, 2014 at 04:44:36PM +0200, Michal Hocko wrote:
> > > > > On Fri 19-09-14 09:22:08, Johannes Weiner wrote:
> > > [...]
> > > > > Nevertheless I think that the counter should live outside of memcg (it
> > > > > is ugly and bad in general to make HUGETLB controller depend on MEMCG
> > > > > just to have a counter). If you made kernel/page_counter.c and led both
> > > > > containers select CONFIG_PAGE_COUNTER then you do not need a dependency
> > > > > on MEMCG and I would find it cleaner in general.
> > > > 
> > > > The reason I did it this way is because the hugetlb controller simply
> > > > accounts and limits a certain type of memory and in the future I would
> > > > like to make it a memcg extension, just like kmem and swap.
> > > 
> > > I am not sure this is the right way to go. Hugetlb has always been
> > > "special" and I do not see any advantage to pull its specialness into
> > > memcg proper.
> > >
> > > It would just make the code more complicated. I can also imagine
> > > users who simply do not want to pay memcg overhead and use only
> > > hugetlb controller.
> > 
> > We already group user memory, kernel memory, and swap space together,
> > what makes hugetlb-backed memory special?
> 
> There is only a little overlap between LRU backed and kmem accounted
> memory with hugetlb which has always been standing aside from the rest
> of the memory management code (THP being a successor which fits in much
> better and which is already covered by memcg). It has basically its own
> code path for every aspect of its object life cycle and internal data
> structures which are in many ways not compatible with regular user or
> kmem memory. Merging the controllers would require to merge hugetlb code
> closer the MM code. Until then it just doesn't make sense to me.

Just look at the hugetlb controller code and think about what would be
left if it were simply another page counter in struct mem_cgroup.

There is a glaring memory leak in its css_alloc() method because
nobody ever looks at this code.  The controller was missed in the
reparenting removal patches because it's just not on the radar.

This is so painfully obvious if you actually work on this code, I
don't know why we are even discussing this.

> > It's also better for the user interface to have a single memory
> > controller.
> 
> I have seen so much confusion coming from hugetlb vs. THP that I think
> the quite opposite is true. Besides that we would need a separate limit
> for hugetlb accounted memory anyway so having a small and specialized
> controller for specialized memory sounds like a proper way to go.
> 
> Finally, as mentioned in previous email, you might have users interested
> only in hugetlb controller with memcg disabled.

They use a global spinlock to allocate and charge these pages, I think
they'll be fine with memcg.

> > We're also close to the point where we don't differentiate between the
> > root group and dedicated groups in terms of performance, Dave's tests
> > fell apart at fairly high concurrency, and I'm already getting rid of
> > the lock he saw contended.
> 
> Sure but this has nothing to do with it. Hugetlb can safely use the same
> lockless counter as a replacement for res_counter and benefit from it
> even though the contention hasn't been seen/reported yet.

It doesn't even use these counters the right way, just look at what it
does during reparenting.  And as per above, it should also be included
in the reparenting removal, but I'm haven't even configured the thing.

> > The downsides of fragmenting our configuration- and testspace, our
> > user interface, and our code base by far outweigh the benefits of
> > offering a dedicated hugetlb controller.
> 
> Could you be more specific please? Hugetlb has to be configured and
> tested separately whether it would be in a separate controller or not.
> 
> Last but not least, even if this turns out to make some sense in
> the future please do not mix those things together here. Your
> res_counter -> page_counter transition makes a lot of sense for both
> controllers. And it is a huge improvement. I do not see any reason
> to pull a conceptually nontrivial merging/dependency of two separate
> controllers into the picture. If you think it makes some sense then
> bring that up later for a separate discussion.

That's one way to put it.  But the way I see it is that I remove a
generic resource counter and replace it with a pure memory counter
which I put where we account and limit memory - with one exception
that is hardly worth creating a dedicated library file for.

I only explained my plans of merging all memory controllers because I
assumed we could ever be on the same page when it comes to this code.

But regardless of that, my approach immediately simplifies Kconfig,
Makefiles, #includes, and you haven't made a good point why the
hugetlb controller depending on memcg would harm anybody in real life.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
