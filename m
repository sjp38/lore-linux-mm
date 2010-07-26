Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BDEEC600044
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:40:49 -0400 (EDT)
Date: Mon, 26 Jul 2010 11:40:44 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1007261136160.5438@router.home>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Kukjin Kim <kgene.kim@samsung.com>, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010, Minchan Kim wrote:

> This patch registers address of mem_section to memmap itself's page struct's
> pg->private field. This means the page is used for memmap of the section.
> Otherwise, the page is used for other purpose and memmap has a hole.

What if page->private just happens to be the value of the page struct?
Even if that is not possible today, someday someone may add new
functionality to the kernel where page->pivage == page is used for some
reason.

Checking for PG_reserved wont work?

> +void mark_valid_memmap(unsigned long start, unsigned long end);
> +
> +#ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
> +static inline int memmap_valid(unsigned long pfn)
> +{
> +	struct page *page = pfn_to_page(pfn);
> +	struct page *__pg = virt_to_page(page);
> +	return page_private(__pg) == (unsigned long)__pg;

Hmmm.. hmmm....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
