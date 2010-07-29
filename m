Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D7BC16B02A9
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 12:47:31 -0400 (EDT)
Date: Thu, 29 Jul 2010 11:47:26 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <20100729161856.GA16420@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1007291132210.17734@router.home>
References: <pfn.valid.v4.reply.2@mdm.bga.com> <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com> <alpine.DEB.2.00.1007270929290.28648@router.home> <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
 <alpine.DEB.2.00.1007281005440.21717@router.home> <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop> <alpine.DEB.2.00.1007291038100.16510@router.home>
 <20100729161856.GA16420@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jul 2010, Minchan Kim wrote:

> The thing is valid section also have a invalid memmap.

Oww... . A valid section points to a valid memmap memory block (the page
structs) but the underlying memory pages may not present. So you can check
the (useless) page structs for the page state of the not present pages in
the memory map. If the granularity of the sparsemem mapping is not
sufficient for your purpose then you can change the sparsemem config
(configuration is in arch/<arch>/include/asm/sparsemem.h but does not
exist for arm).

>      It means section 0 is an incompletely filled section.
>      Nontheless, current pfn_valid of sparsemem checks pfn loosely.
>      It checks only mem_section's validation but ARM can free mem_map on hole
>      to save memory space. So in above case, pfn on 0x25000000 can pass pfn_valid's
>      validation check. It's not what we want.

IMHO ARM should not poke holes in the memmap sections. The guarantee of
the full presence of the section is intentional to avoid having to do
these checks that you are proposing. The page allocator typically expects
to be able to check all page structs in one basic allocation unit.

Also pfn_valid then does not have to touch the pag struct to perform its
function as long as we guarantee the presence of the memmap section.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
