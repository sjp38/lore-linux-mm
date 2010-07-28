Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0710E6B02AA
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:14:55 -0400 (EDT)
Date: Wed, 28 Jul 2010 10:14:51 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1007281005440.21717@router.home>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com> <alpine.DEB.2.00.1007261136160.5438@router.home> <pfn.valid.v4.reply.1@mdm.bga.com> <AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com> <pfn.valid.v4.reply.2@mdm.bga.com>
 <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com> <alpine.DEB.2.00.1007270929290.28648@router.home> <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2010, Minchan Kim wrote:

> static inline int memmap_valid(unsigned long pfn)
> {
>        struct page *page = pfn_to_page(pfn);
>        struct page *__pg = virt_to_page(page);

Does that work both for vmemmap and real mmapping?

>        return page_private(__pg) == MAGIC_MEMMAP && PageReserved(__pg);
> }

Problem is that pages may be allocated for the mmap from a variety of
places. The pages in mmap_init_zone() and allocated during boot may have
PageReserved set whereas the page allocated via vmemmap_alloc_block() have
PageReserved cleared since they came from the page allocator.

You need to have consistent use of PageReserved in page structs for the
mmap in order to do this properly.

Simplest scheme would be to clear PageReserved() in all page struct
associated with valid pages and clear those for page structs that do not
refer to valid pages.

Then

mmap_valid = !PageReserved(xxx(pfn_to_page(pfn))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
