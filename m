Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2E73C9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:46:06 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8LEPGTW025283
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:25:16 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8LFk3u4217108
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:46:03 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8LFk2jx005327
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:46:03 -0400
Subject: Re: [PATCH 1/3] fixup! mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <ea1bc31120e0670a044de6af7b3c67203c178065.1316617681.git.mina86@mina86.com>
References: <1315505152.3114.9.camel@nimitz>
	 <ea1bc31120e0670a044de6af7b3c67203c178065.1316617681.git.mina86@mina86.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Sep 2011 08:45:59 -0700
Message-ID: <1316619959.16137.308.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mnazarewicz@google.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Wed, 2011-09-21 at 17:19 +0200, Michal Nazarewicz wrote:
> Do the attached changes seem to make sense?

The logic looks OK.

> I wanted to avoid calling pfn_to_page() each time as it seem fairly
> expensive in sparsemem and disctontig modes.  At the same time, the
> macro trickery is so that users of sparsemem-vmemmap and flatmem won't
> have to pay the price.

Personally, I'd say the (incredibly minuscule) runtime cost is worth the
cost of making folks' eyes bleed when they see those macros.  I think
there are some nicer ways to do it.

Is there a reason you can't logically do?

	page = pfn_to_page(pfn);
	for (;;) {
		if (pfn_to_section_nr(pfn) == pfn_to_section_nr(pfn+1))
			page++;
		else
			page = pfn_to_page(pfn+1);
	}

pfn_to_section_nr() is a register shift.  Our smallest section size on
x86 is 128MB and on ppc64 16MB.  So, at *WORST* (64k pages on ppc64),
you're doing pfn_to_page() one of every 256 loops.

My suggestion would be put put a macro up in the sparsemem headers that
does something like:

#ifdef VMEMMAP
#define zone_pfn_same_memmap(pfn1, pfn2) (1)
#elif SPARSEMEM_OTHER
static inline int zone_pfn_same_memmap(unsigned long pfn1, unsigned long pfn2)
{
	return (pfn_to_section_nr(pfn1) == pfn_to_section_nr(pfn2));
}
#else
#define zone_pfn_same_memmap(pfn1, pfn2) (1)
#endif

The zone_ bit is necessary in the naming because DISCONTIGMEM's pfns are
at least contiguous within a zone.  Only the non-VMEMMAP sparsemem case
isn't.

Other folks would probably have a use for something like that.  Although
most of the previous users have gotten to this point, given up, and just
done pfn_to_page() on each loop. :)

> +#if defined(CONFIG_FLATMEM) || defined(CONFIG_SPARSEMEM_VMEMMAP)
> +
> +/*
> + * In FLATMEM and CONFIG_SPARSEMEM_VMEMMAP we can safely increment the page
> + * pointer and get the same value as if we were to get by calling
> + * pfn_to_page() on incremented pfn counter.
> + */
> +#define __contig_next_page(page, pageblock_left, pfn, increment) \
> +	((page) + (increment))
> +
> +#define __contig_first_page(pageblock_left, pfn) pfn_to_page(pfn)
> +
> +#else
> +
> +/*
> + * If we cross pageblock boundary, make sure we get a valid page pointer.  If
> + * we are within pageblock, incrementing the pointer is good enough, and is
> + * a bit of an optimisation.
> + */
> +#define __contig_next_page(page, pageblock_left, pfn, increment)	\
> +	(likely((pageblock_left) -= (increment)) ? (page) + (increment)	\
> +	 : (((pageblock_left) = pageblock_nr_pages), pfn_to_page(pfn)))
> +
> +#define __contig_first_page(pageblock_left, pfn) (			\
> +	((pageblock_left) = pageblock_nr_pages -			\
> +		 ((pfn) & (pageblock_nr_pages - 1))),			\
> +	pfn_to_page(pfn))
> +
> +
> +#endif

For the love of Pete, please make those in to functions if you're going
to keep them.  They're really unreadable like that.

You might also want to look at mm/internal.h's mem_map_offset() and
mem_map_next().  They're not _quite_ what you need, but they're close.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
