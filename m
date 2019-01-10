Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB7B98E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:55:10 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so4540099edb.5
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:55:10 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id w51si3245413edc.321.2019.01.10.06.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 06:55:09 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id E5D151C1DD8
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:55:08 +0000 (GMT)
Date: Thu, 10 Jan 2019 14:55:07 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 1/3] mm, thp: restore __GFP_NORETRY for madvised thp fault
 allocations
Message-ID: <20190110145507.GB31517@techsingularity.net>
References: <20181211142941.20500-1-vbabka@suse.cz>
 <20181211142941.20500-2-vbabka@suse.cz>
 <20190108111630.GN31517@techsingularity.net>
 <cba804dd-5a07-0a40-b5ae-86795dc860d4@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <cba804dd-5a07-0a40-b5ae-86795dc860d4@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jan 10, 2019 at 02:52:32PM +0100, Vlastimil Babka wrote:
> > It also means that the merit of this series needs to account for whether
> > it's before or after the compaction series as the impact will be
> > different. FWIW, I had the same problem with evaluating the compaction
> > series on the context of __GFP_THISNODE vs !__GFP_THISNODE
> 
> Right. In that case I think for mainline, making compaction better has
> priority over trying to compensate for it.

Thanks, I agree.

> The question is if somebody
> wants to fix stable/older distro kernels. Now that it wasn't possible to
> remove the __GFP_THISNODE for THP's, I thought this might be an
> alternative acceptable to anyone, provided that it works. Backporting
> your compaction series would be much more difficult I guess. Of course
> distro kernels can also divert from mainline and go with the
> __GFP_THISNODE removal privately.
> 

That is a good point and hopefully Andrea can come back with some data from
his side. I can queue up something our side and see how it affects the
usemem case. As it's a backporting issue that I think would be rejected
by the stable rules, we can discuss the specifics offline and keep "did
it work or not" for here.

I agree that backporting the compaction series too far back would get
"interesting" as some of the pre-requisites are unexpected -- e.g. all
the data we have assumes the fragmentation avoidance stuff is in place and
that in turn has other dependencies such as when kcompactd gets woken up,
your patches on how fallbacks are managed etc.

> >> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >> index 5da55b38b1b7..c442b12b060c 100644
> >> --- a/mm/huge_memory.c
> >> +++ b/mm/huge_memory.c
> >> @@ -633,24 +633,23 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> >>  {
> >>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> >>  
> >> -	/* Always do synchronous compaction */
> >> +	/* Always try direct compaction */
> >>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> >> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
> >> +		return GFP_TRANSHUGE | __GFP_NORETRY;
> >>  
> > 
> > While I get that you want to reduce thrashing, the configuration item
> > really indicates the system (not just the caller, but everyone) is willing
> > to take a hit to get a THP.
> 
> Yeah some hit in exchange for THP's, but probably not an overreclaim due
> to __GFP_THISNODE implications.
> 

Fair point, we can get that data.

-- 
Mel Gorman
SUSE Labs
