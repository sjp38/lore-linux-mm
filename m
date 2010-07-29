Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F32816B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 16:55:39 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6TKi3ri017530
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:44:04 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6TKtNQC082616
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:55:23 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6TKtLfG007632
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:55:22 -0600
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100729183320.GH18923@n2100.arm.linux.org.uk>
References: <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
	 <alpine.DEB.2.00.1007281005440.21717@router.home>
	 <20100728155617.GA5401@barrios-desktop>
	 <alpine.DEB.2.00.1007281158150.21717@router.home>
	 <20100728225756.GA6108@barrios-desktop>
	 <alpine.DEB.2.00.1007291038100.16510@router.home>
	 <20100729161856.GA16420@barrios-desktop>
	 <alpine.DEB.2.00.1007291132210.17734@router.home>
	 <20100729170313.GB16420@barrios-desktop>
	 <alpine.DEB.2.00.1007291222410.17734@router.home>
	 <20100729183320.GH18923@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 29 Jul 2010 13:55:19 -0700
Message-ID: <1280436919.16922.11246.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-29 at 19:33 +0100, Russell King - ARM Linux wrote:
> And no, setting the sparse section size to 512kB doesn't work - memory is
> offset by 256MB already, so you need a sparsemem section array of 1024
> entries just to cover that - with the full 256MB populated, that's 512
> unused entries followed by 512 used entries.  That too is going to waste
> memory like nobodies business.

Sparsemem could use some work in the case where memory doesn't start at
0x0.  But, it doesn't seem like it would be _too_ oppressive to add.
It's literally just adding an offset to all of the places where a
physical address is stuck into the system.  It'll make a few of the
calculations longer, of course, but it should be manageable.

Could you give some full examples of how the memory is laid out on these
systems?  I'm having a bit of a hard time visualizing it.

As Christoph mentioned, SPARSEMEM_EXTREME might be viable here, too.

If you free up parts of the mem_map[] array, how does the buddy
allocator still work?  I thought we required at 'struct page's to be
contiguous and present for at least 2^MAX_ORDER-1 pages in one go.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
