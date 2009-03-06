Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C93446B00AF
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 15:46:22 -0500 (EST)
Date: Fri, 6 Mar 2009 12:45:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] generic debug pagealloc (-v3)
Message-Id: <20090306124551.beb5b131.akpm@linux-foundation.org>
In-Reply-To: <20090306153943.GB6915@localhost.localdomain>
References: <20090305145926.GA27015@localhost.localdomain>
	<20090305143150.136e2708.akpm@linux-foundation.org>
	<20090306032814.GA9874@localhost.localdomain>
	<20090306153943.GB6915@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, jirislaby@gmail.com, rmk+lkml@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Sat, 7 Mar 2009 00:39:45 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> CONFIG_DEBUG_PAGEALLOC is now supported by x86, powerpc, sparc64, and s390.
> This patch implements it for the rest of the architectures by filling the
> pages with poison byte patterns after free_pages() and verifying the poison
> patterns before alloc_pages().
> 
> This generic one cannot detect invalid page accesses immediately but invalid
> read access may cause invalid dereference by poisoned memory and invalid write
> access can be detected after a long delay.
> 
> ...
>
> +static void poison_page(struct page *page)
> +{
> +	void *addr;
> +
> +	if (PageHighMem(page)) {
> +		/*
> +		 * Skip poisoning for highmem pages
> +		 */

This isn't a good comment - what it tells us is already utterly obvious
from the code, and the reader is left with no clue as to _why_ the code
does this.

> +		return;
> +	}
> +	page->poison = true;
> +	addr = page_address(page);
> +	memset(addr, PAGE_POISON, PAGE_SIZE);
> +}
> +
> +static void poison_pages(struct page *page, int n)
> +{
> +	int i;
> +
> +	for (i = 0; i < n; i++)
> +		poison_page(page + i);
> +}
> +
> +static bool single_bit_flip(unsigned char a, unsigned char b)
> +{
> +	unsigned char error = a ^ b;
> +
> +	return error && !(error & (error - 1));
> +}
> +
> +static void check_poison_mem(unsigned char *mem, size_t bytes)
> +{
> +	unsigned char *start;
> +	unsigned char *end;
> +
> +	for (start = mem; start < mem + bytes; start++) {
> +		if (*start != PAGE_POISON)
> +			break;
> +	}
> +	if (start == mem + bytes)
> +		return;
> +
> +	for (end = mem + bytes - 1; end > start; end--) {
> +		if (*end != PAGE_POISON)
> +			break;
> +	}
> +	if (start == end && single_bit_flip(*start, PAGE_POISON))
> +		printk(KERN_ERR "Single bit error: %p\n", start);
> +	else
> +		printk(KERN_ERR "Page corruption: %p-%p\n", start, end);
> +
> +	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
> +			end - start + 1, 1);

These messages should be self-identifying in some fashion.  A message
like "Single bit error" could come from almost any part of the kernel. 
Something like "pagealloc: single bit error", perhaps?

There's a decent chance that if this warning triggers once, it will
trigger a thousand times, depending upon the nature of the fault.  So
it would be sensible to put some constraint upon the reporting.  That
could be time-based (include/linux/ratelimit.h) or perhaps just stop at
ten or whatever.

If this message ever comes out, the chances are high that we'll really
really want to know which kernel subsystem owned that page.  Because if
it's a software fault, this will help us find the bug.  A suitable way
of doing this is to run dump_stack().  This will also cause the reports
to be tracked by kerneloops.org.

> --- 2.6-poison.orig/include/linux/mm_types.h
> +++ 2.6-poison/include/linux/mm_types.h
> @@ -94,6 +94,10 @@ struct page {
>  	void *virtual;			/* Kernel virtual address (NULL if
>  					   not kmapped, ie. highmem) */
>  #endif /* WANT_PAGE_VIRTUAL */
> +
> +#ifdef CONFIG_PAGE_POISONING
> +	bool poison;
> +#endif /* CONFIG_PAGE_POISONING */
>  };
>  

Adding 32 bits to the pageframe for a single feature which needs one
bit is rather sad.  Sure, this is a super-slow feature and nobody will
be turning it on in production.  But I wonder if we can do better.


#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
	unsigned long debug_flags;	/* Use atomic bitops on this */
#endif
};

#define PAGE_DEBUG_FLAG_PAGEALLOC	0
#define PAGE_DEBUG_SOMETHING_ELSE	1
etc


Now, your feature needs to turn on CONFIG_WANT_PAGE_DEBUG_FLAGS.  Other
debug features can do so as well.

But we do need to ensure that CONFIG_WANT_PAGE_DEBUG_FLAGS reliably
gets turned off when no debug features are enabling it!  It would be
sad if a developer were to enable your feature, then disable it, then
run `oldconfig', then have a pageframe which contains an extra unused
long.  I don't trust the Kconfig system ;)


Maybe this is all a bit overdesigned, dunno.  If someone else later
comes along wanting to add more debug stuff then they'll need to
do this, might as well do it now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
