Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5605A6B02A8
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 13:02:21 -0400 (EDT)
Date: Wed, 28 Jul 2010 12:02:16 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <20100728155617.GA5401@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1007281158150.21717@router.home>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com> <alpine.DEB.2.00.1007261136160.5438@router.home> <pfn.valid.v4.reply.1@mdm.bga.com> <AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com> <pfn.valid.v4.reply.2@mdm.bga.com>
 <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com> <alpine.DEB.2.00.1007270929290.28648@router.home> <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
 <alpine.DEB.2.00.1007281005440.21717@router.home> <20100728155617.GA5401@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2010, Minchan Kim wrote:

> > Simplest scheme would be to clear PageReserved() in all page struct
> > associated with valid pages and clear those for page structs that do not
> > refer to valid pages.
>
> I can't understand your words.
> Clear PG_resereved in valid pages and invalid pages both?

Argh sorry. No. Set PageReserved for pages that do not refer to reserved
pages.

> I guess your code look like that clear PG_revered on valid memmap
> but set PG_reserved on invalid memmap.
> Right?

Right.

> invalid memmap pages will be freed by free_memmap and will be used
> on any place. How do we make sure it has PG_reserved?

Not present memmap pages make pfn_valid fail already since there is no
entry for the page table (vmemmap) or blocks are missing in the sparsemem
tables.

> Maybe I don't understand your point.

I thought we are worrying about holes in the memmap blocks containing page
structs. Some page structs point to valid pages and some are not. The
invalid page structs need to be marked consistently to allow the check.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
