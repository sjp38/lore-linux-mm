Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9AA186B0211
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 18:32:37 -0400 (EDT)
Date: Wed, 24 Mar 2010 23:32:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mincore and transparent huge pages
Message-ID: <20100324223232.GO10659@random.random>
References: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Johannes,

On Tue, Mar 23, 2010 at 03:34:57PM +0100, Johannes Weiner wrote:
> 
> Hi,
> 
> I wanted to make mincore() handle huge pmds natively over the weekend
> but I chose do beef up the code a bit first (1-4).
> 
> Andrew, 1-4 may have merit without transparent huge pages, so they
> could go in independently.  They are based on Andrea's patches but the
> only thing huge page in them is the split_huge_page_vma() call, so it
> would be easy to rebase (I can do that).
> 
> Below is also an ugly hack I used to test transparent huge pages on my
> 32bit netbook.  The VM_ flags, oh, the VM_ flags!

Thanks a lot for this effort.

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 85fa92a..b6aec57 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -106,10 +106,11 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
>  #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
>  #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
> +#ifdef CONFIG_KSM
> +#error no more VM_ flags
>  #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
> -#if BITS_PER_LONG > 32
> -#define VM_HUGEPAGE	0x100000000UL	/* MADV_HUGEPAGE marked this vma */
>  #endif
> +#define VM_HUGEPAGE	0x80000000	/* MADV_HUGEPAGE marked this vma */
>  
>  #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
>  #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS

The moment we say we need 32bit archs, I suggest to takeover VM_SAO, I
think it's more likely you need ksm on 32bit x86, than transparent
hugepage on ppc32. I also doubt VM_RESERVED is still actual these
days, but I guess I won't take the tangent to go after it (if somebody
does that's welcome, otherwise later after transparent hugepage is in,
after ksm works on transparent hugepages, after memory compaction is
in, and after slab gets its front huge-allocator to make sure it allocates
fine with 4k granularity but if a hugepage is available it eats from
there first). It's not like a big priority to nuke VM_RESERVED
compared to all the rest...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
