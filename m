Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1CB196B00DB
	for <linux-mm@kvack.org>; Tue,  6 Jan 2009 03:38:19 -0500 (EST)
Message-ID: <49631877.3090803@aon.at>
Date: Tue, 06 Jan 2009 09:38:15 +0100
From: Peter Klotz <peter.klotz@aon.at>
MIME-Version: 1.0
Subject: Re: [patch] mm: fix lockless pagecache reordering bug (was Re: BUG:
 soft lockup - is this XFS problem?)
References: <20090105041959.GC367@wotan.suse.de> <20090105064838.GA5209@wotan.suse.de> <49623384.2070801@aon.at> <20090105164135.GC32675@wotan.suse.de> <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain> <20090105180008.GE32675@wotan.suse.de> <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain> <20090105201258.GN6959@linux.vnet.ibm.com> <alpine.LFD.2.00.0901051224110.3057@localhost.localdomain> <20090105215727.GQ6959@linux.vnet.ibm.com> <20090106020550.GA819@wotan.suse.de>
In-Reply-To: <20090106020550.GA819@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> --
> Subject: mm lockless pagecache barrier fix
> 
> An XFS workload showed up a bug in the lockless pagecache patch. Basically it
> would go into an "infinite" loop, although it would sometimes be able to break
> out of the loop! The reason is a missing compiler barrier in the "increment
> reference count unless it was zero" case of the lockless pagecache protocol in
> the gang lookup functions.
> 
> This would cause the compiler to use a cached value of struct page pointer to
> retry the operation with, rather than reload it. So the page might have been
> removed from pagecache and freed (refcount==0) but the lookup would not correctly
> notice the page is no longer in pagecache, and keep attempting to increment the
> refcount and failing, until the page gets reallocated for something else. This
> isn't a data corruption because the condition will be detected if the page has
> been reallocated. However it can result in a lockup. 
> 
> Linus points out that ACCESS_ONCE is also required in that pointer load, even
> if it's absence is not causing a bug on our particular build. The most general
> way to solve this is just to put an rcu_dereference in radix_tree_deref_slot.
> 
> Assembly of find_get_pages,
> before:
> .L220:
>         movq    (%rbx), %rax    #* ivtmp.1162, tmp82
>         movq    (%rax), %rdi    #, prephitmp.1149
> .L218:
>         testb   $1, %dil        #, prephitmp.1149
>         jne     .L217   #,
>         testq   %rdi, %rdi      # prephitmp.1149
>         je      .L203   #,
>         cmpq    $-1, %rdi       #, prephitmp.1149
>         je      .L217   #,
>         movl    8(%rdi), %esi   # <variable>._count.counter, c
>         testl   %esi, %esi      # c
>         je      .L218   #,
> 
> after:
> .L212:
>         movq    (%rbx), %rax    #* ivtmp.1109, tmp81
>         movq    (%rax), %rdi    #, ret
>         testb   $1, %dil        #, ret
>         jne     .L211   #,
>         testq   %rdi, %rdi      # ret
>         je      .L197   #,
>         cmpq    $-1, %rdi       #, ret
>         je      .L211   #,
>         movl    8(%rdi), %esi   # <variable>._count.counter, c
>         testl   %esi, %esi      # c
>         je      .L212   #,
> 
> (notice the obvious infinite loop in the first example, if page->count remains 0)
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  include/linux/radix-tree.h |    2 +-
>  mm/filemap.c               |   23 ++++++++++++++++++++---
>  2 files changed, 21 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/include/linux/radix-tree.h
> ===================================================================
> --- linux-2.6.orig/include/linux/radix-tree.h
> +++ linux-2.6/include/linux/radix-tree.h
> @@ -136,7 +136,7 @@ do {									\
>   */
>  static inline void *radix_tree_deref_slot(void **pslot)
>  {
> -	void *ret = *pslot;
> +	void *ret = rcu_dereference(*pslot);
>  	if (unlikely(radix_tree_is_indirect_ptr(ret)))
>  		ret = RADIX_TREE_RETRY;
>  	return ret;
> 
> 

The patch above fixes my problem. I did two complete test runs that 
normally fail rather quickly.

Regards, Peter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
