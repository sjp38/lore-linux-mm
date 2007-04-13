Date: Fri, 13 Apr 2007 11:57:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: madvise avoid exclusive mmap_sem
Message-Id: <20070413115719.2bdf5705.akpm@linux-foundation.org>
In-Reply-To: <20070412005638.GA25469@wotan.suse.de>
References: <20070412005638.GA25469@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Apr 2007 02:56:38 +0200
Nick Piggin <npiggin@suse.de> wrote:

> Avoid down_write of the mmap_sem in madvise when we can help it.
> 
> Acked-by: Hugh Dickins <hugh@veritas.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Index: linux-2.6/mm/madvise.c
> ===================================================================
> --- linux-2.6.orig/mm/madvise.c
> +++ linux-2.6/mm/madvise.c
> @@ -12,6 +12,24 @@
>  #include <linux/hugetlb.h>
>  
>  /*
> + * Any behaviour which results in changes to the vma->vm_flags needs to
> + * take mmap_sem for writing. Others, which simply traverse vmas, need
> + * to only take it for reading.
> + */
> +static int madvise_need_mmap_write(int behavior)
> +{
> +	switch (behavior) {
> +	case MADV_REMOVE:
> +	case MADV_WILLNEED:
> +	case MADV_DONTNEED:
> +		return 0;
> +	default:
> +		/* be safe, default to 1. list exceptions explicitly */
> +		return 1;
> +	}
> +}

Are we sure that running zap_page_range() under down_read() is safe?
For hugepage regions too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
