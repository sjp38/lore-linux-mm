Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 56C4B6B00D1
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 17:32:51 -0500 (EST)
Date: Thu, 5 Mar 2009 14:31:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] generic debug pagealloc (-v2)
Message-Id: <20090305143150.136e2708.akpm@linux-foundation.org>
In-Reply-To: <20090305145926.GA27015@localhost.localdomain>
References: <20090305145926.GA27015@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, jirislaby@gmail.com, rmk+lkml@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Thu, 5 Mar 2009 23:59:27 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> CONFIG_DEBUG_PAGEALLOC is now supported by x86, powerpc, sparc (64bit),
> and s390. This patch implements it for the rest of the architectures
> by filling the pages with poison byte patterns after free_pages() and
> verifying the poison patterns before alloc_pages().
> 
> This generic one cannot detect invalid read accesses and it can only
> detect invalid write accesses after a long delay. But it is a feasible way
> for nommu architectures.
> 
> ...
>
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +
> +static void poison_page(struct page *page)
> +{
> +	void *addr;
> +
> +	if (PageHighMem(page))
> +		return; /* i goofed */

heh.  A more complete comment would be needed here.

Also, as this is a kernel bug, perhaps some sort of runtime warning?

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
> +	printk(KERN_ERR "Page corruption: %p-%p\n", start, end);
> +	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
> +			end - start + 1, 1);
> +}
> +
> +static void unpoison_page(struct page *page)
> +{
> +	void *addr;
> +

Shouldn't we check PageHighmem() here also?

> +	if (!page->poison)
> +		return;
> +
> +	addr = page_address(page);
> +	check_poison_mem(addr, PAGE_SIZE);
> +	page->poison = false;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
