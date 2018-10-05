Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C39FB6B026F
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 03:39:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v15-v6so3261989edm.13
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 00:39:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k26-v6si4715547ejd.312.2018.10.05.00.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 00:38:59 -0700 (PDT)
Date: Fri, 5 Oct 2018 08:38:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181005073854.GB6931@suse.de>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Oct 04, 2018 at 01:16:32PM -0700, David Rientjes wrote:
> On Tue, 25 Sep 2018, Michal Hocko wrote:
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index da858f794eb6..149b6f4cf023 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -2046,8 +2046,36 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> >  		nmask = policy_nodemask(gfp, pol);
> >  		if (!nmask || node_isset(hpage_node, *nmask)) {
> >  			mpol_cond_put(pol);
> > -			page = __alloc_pages_node(hpage_node,
> > -						gfp | __GFP_THISNODE, order);
> > +			/*
> > +			 * We cannot invoke reclaim if __GFP_THISNODE
> > +			 * is set. Invoking reclaim with
> > +			 * __GFP_THISNODE set, would cause THP
> > +			 * allocations to trigger heavy swapping
> > +			 * despite there may be tons of free memory
> > +			 * (including potentially plenty of THP
> > +			 * already available in the buddy) on all the
> > +			 * other NUMA nodes.
> > +			 *
> > +			 * At most we could invoke compaction when
> > +			 * __GFP_THISNODE is set (but we would need to
> > +			 * refrain from invoking reclaim even if
> > +			 * compaction returned COMPACT_SKIPPED because
> > +			 * there wasn't not enough memory to succeed
> > +			 * compaction). For now just avoid
> > +			 * __GFP_THISNODE instead of limiting the
> > +			 * allocation path to a strict and single
> > +			 * compaction invocation.
> > +			 *
> > +			 * Supposedly if direct reclaim was enabled by
> > +			 * the caller, the app prefers THP regardless
> > +			 * of the node it comes from so this would be
> > +			 * more desiderable behavior than only
> > +			 * providing THP originated from the local
> > +			 * node in such case.
> > +			 */
> > +			if (!(gfp & __GFP_DIRECT_RECLAIM))
> > +				gfp |= __GFP_THISNODE;
> > +			page = __alloc_pages_node(hpage_node, gfp, order);
> >  			goto out;
> >  		}
> >  	}
> 
> This causes, on average, a 13.9% access latency regression on Haswell, and 
> the regression would likely be more severe on Naples and Rome.
> 

That assumes that fragmentation prevents easy allocation which may very
well be the case. While it would be great that compaction or the page
allocator could be further improved to deal with fragmentation, it's
outside the scope of this patch.

> There exist libraries that allow the .text segment of processes to be 
> remapped to memory backed by transparent hugepages and use MADV_HUGEPAGE 
> to stress local compaction to defragment node local memory for hugepages 
> at startup. 

That is taking advantage of a co-incidence of the implementation.
MADV_HUGEPAGE is *advice* that huge pages be used, not what the locality
is. A hint for strong locality preferences should be separate advice
(madvise) or a separate memory policy. Doing that is outside the context
of this patch but nothing stops you introducing such a policy or madvise,
whichever you think would be best for the libraries to consume (I'm only
aware of libhugetlbfs but there might be others).

> The cost, including the statistics Mel gathered, is 
> acceptable for these processes: they are not concerned with startup cost, 
> they are concerned only with optimal access latency while they are 
> running.
> 

Then such applications at startup have the option of setting
zone_reclaim_mode during initialisation assuming a privileged helper
can be created. That would be somewhat heavy handed and a longer-term
solution would still be to create a proper memory policy of madvise flag
for those libraries.

> So while it may take longer to start the process because memory compaction 
> is attempting to allocate hugepages with __GFP_DIRECT_RECLAIM, in the 
> cases where compaction is successful, this is a very significant long-term 
> win.  In cases where compaction fails, falling back to local pages of the 
> native page size instead of remote thp is a win for the remaining time 
> this process wins: as stated, 13.9% faster for all memory accesses to the 
> process's text while it runs on Haswell.
> 

Again, I remind you that it only benefits applications that prefectly
fit into NUMA nodes. Not all applications are created with that level of
awareness and easily get thrashed if using MADV_HUGEPAGE and do not fit
into a NUMA node.

While it is unfortunate that there are specialised applications that
benefit from the current configuration, I bet there is heavier usage of
qemu affected by the bug this patch addresses than specialised
applications that both fit perfectly into NUMA nodes and are extremely
sensitive to access latencies. It's a question of causing the least harm
to the most users which is what this patch does.

If you need behaviour for more agressive reclaim or locality hints then
kindly introduce them and do not depend in MADV_HUGEPAGE accidentically
doubling up as hints about memory locality.

-- 
Mel Gorman
SUSE Labs
