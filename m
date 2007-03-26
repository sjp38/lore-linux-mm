Date: Mon, 26 Mar 2007 09:52:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
In-Reply-To: <20070323222133.f17090cf.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703260938520.3297@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
 <20070322223927.bb4caf43.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
 <20070322234848.100abb3d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com>
 <20070323222133.f17090cf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2007, Andrew Morton wrote:

> On Fri, 23 Mar 2007 10:54:12 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Here are the results of aim9 tests on x86_64. There are some minor performance 
> > improvements and some fluctuations.
> 
> There are a lot of numbers there - what do they tell us?

That there are performance improvements because of quicklists.

> So what has changed here?  From a quick look it appears that x86_64 is
> using get_zeroed_page() for ptes, puds and pmds and is using a custom
> quicklist for pgds.

x86_64 is only using a list in order to track pgds. There is no 
quicklist without this patchset.
 
> After your patches, x86_64 is using a common quicklist allocator for puds,
> pmds and pgds and continues to use get_zeroed_page() for ptes.

x86_64 should be using quicklists for all ptes after this patch. I did not 
convert pte_free() since it is only used for freeing ptes during races 
(see __pte_alloc). Since pte_free gets passed a page struct it would require 
virt_to_page before being put onto the freelist. Not worth doing.

Hmmm... Then how does x86_64 free the ptes? Seems that we do 
free_page_and_swap_cache() in tlb_remove_pages. Yup so ptes are not 
handled which limits the speed improvements that we see.

> My question is pretty simple: how do we justify the retention of this
> custom allocator?

I would expect this functionality (never thought about it as an allocator) 
to extract common code from many arches that use one or the other form of 
preserving zeroed pages for page table pages. I saw lots of arches doing 
the same with some getting into trouble with the page structs. Having a 
common code base that does not have this issue would clean up the kernel 
and deal with the slab issue.

> Because simply removing it is the preferable way of fixing the SLUB
> problem.

That would reduce performance. I did not think that a common feature 
that is used throughout many arches would need rejustification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
