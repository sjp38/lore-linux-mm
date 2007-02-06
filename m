Date: Tue, 6 Feb 2007 00:25:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/3] mm: fix PageUptodate memorder
Message-Id: <20070206002512.4e0bbbad.akpm@linux-foundation.org>
In-Reply-To: <20070206054935.21042.13541.sendpatchset@linux.site>
References: <20070206054925.21042.50546.sendpatchset@linux.site>
	<20070206054935.21042.13541.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue,  6 Feb 2007 09:02:11 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:

> +static inline void __SetPageUptodate(struct page *page)
> +{
> +#ifdef CONFIG_S390
>  	if (!test_and_set_bit(PG_uptodate, &page->flags))
>  		page_test_and_clear_dirty(page);
> -}
>  #else
> -#define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
> +	/*
> +	 * Memory barrier must be issued before setting the PG_uptodate bit,
> +	 * so all previous writes that served to bring the page uptodate are
> +	 * visible before PageUptodate becomes true.
> +	 *
> +	 * S390 is guaranteed to have a barrier in the test_and_set operation
> +	 * (see Documentation/atomic_ops.txt).
> +	 *
> +	 * XXX: does this memory barrier need to be anything special to
> +	 * handle things like DMA writes into the page?
> +	 */
> +	smp_wmb();
> +	set_bit(PG_uptodate, &(page)->flags);
>  #endif
> +}
> +
> +static inline void SetPageUptodate(struct page *page)
> +{
> +	WARN_ON(!PageLocked(page));
> +	__SetPageUptodate(page);
> +}
> +
> +static inline void SetNewPageUptodate(struct page *page)
> +{
> +	__SetPageUptodate(page);
> +}

I was panicing for a minute when I saw that __SetPageUptodate() in there.

Conventionally the __SetPageFoo namespace is for nonatomic updates to
page->flags.  Can we call this something different?


What a fugly patchset :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
