Date: Mon, 26 Mar 2007 11:14:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
In-Reply-To: <Pine.LNX.4.64.0703260938520.3297@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0703261112110.13105@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
 <20070322223927.bb4caf43.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
 <20070322234848.100abb3d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com>
 <20070323222133.f17090cf.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703260938520.3297@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Mar 2007, Christoph Lameter wrote:

> > After your patches, x86_64 is using a common quicklist allocator for puds,
> > pmds and pgds and continues to use get_zeroed_page() for ptes.
> 
> x86_64 should be using quicklists for all ptes after this patch. I did not 
> convert pte_free() since it is only used for freeing ptes during races 
> (see __pte_alloc). Since pte_free gets passed a page struct it would require 
> virt_to_page before being put onto the freelist. Not worth doing.
> 
> Hmmm... Then how does x86_64 free the ptes? Seems that we do 
> free_page_and_swap_cache() in tlb_remove_pages. Yup so ptes are not 
> handled which limits the speed improvements that we see.

And if we would try to put the ptes onto quicklists then we would get into 
more difficulties with the tlb shootdown code. Sigh. We cannot easily 
deal with ptes. Quicklists on i386 and x86_64 only work for pgds,puds and 
pmds. And as was pointed out elsewhere in this thread: The performance 
gains are therefore limited on these platforms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
