Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 07B7F6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 14:19:04 -0400 (EDT)
Date: Fri, 5 Aug 2011 20:18:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] THP: mremap support and TLB optimization #2
Message-ID: <20110805181838.GZ9770@redhat.com>
References: <20110728142631.GI3087@redhat.com>
 <20110805152516.GI9211@csn.ul.ie>
 <20110805162151.GX9770@redhat.com>
 <20110805171126.GJ9211@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110805171126.GJ9211@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Aug 05, 2011 at 06:11:26PM +0100, Mel Gorman wrote:
> That's a tough call. Increased jitter within KVM might be unwelcome
> but ordinarily the only people that might care about latencies are
> real time people and I dont think they would care about the KVM case.

Ah KVM won't possibly ever run mremap on regions backed by the mmu
notifier, so that's not an issue.

> I agree with you that overall it's probably for the best but splitting
> it out as a separate patch and cc'ing the KVM people would do no harm.
> Is there any impact for things like xpmem that might be using MMU
> notifiers in some creative manner?

KVM people are already safe, this mremap optimization won't affect
KVM, it's more for JVM than anything else. xpmem currently can't run
on mmu notifier because they require scheduling at least in the
range_start/end methods (not in the invalidate_page methods), and
without srcu in mmu notifier they can't schedule even in
range_start/end. The only other user in tree is the GRU driver.

I don't think it's a fundamental new limitation, the whole mremap
region becomes unavailable to the users of the primary MMU for the
whole duration, it was more by accident that the part of the region
was still available to the secondary mmu users during mremap despite
not being "accessible" with predictable result on the primary mmu
(modulo trapping sigsegv). So I don't think we can make things
worse with this, not worse than they already were for the primary mmu,
plus the duration of the syscall will be shorter now.

> > The one IPI per page is a major bottleneck for java, lack of hugepmd
> > migrate also major bottleneck, here we get both combined so we get 1
> > IPI for a ton of THP. The benchmark I run was single threaded on a 12
> > core system (and single threaded if scheduler is doing good won't
> > require any IPI), you can only imagine the boost it gets on heavily
> > multithreaded apps that requires flooding IPI on large SMP (I didn't
> > measure that as I was already happy with what I got single threaded :).
> > 
> 
> Yeah, I imagine it should also be a boost during GC if the JVM is
> using mremap to migrate full pages from an old heap to a new one.

Correct, it's GC doing mremap AFIK.

> I don't feel very strongly about it. The change looks reasonable
> and with a fresh head with the patch split out, it probably is more
> readable.

Yes I plan to do a split out. I just wanted to know if I should change
the -1 into the code that doesn't relay on PAGE_SIZE > 1 and that
explicitly says it's about the overflow, so that it feels
less obscure, or if I should leave the -1 as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
