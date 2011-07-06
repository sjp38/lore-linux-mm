Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C79D66B004A
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 13:16:51 -0400 (EDT)
Date: Wed, 6 Jul 2011 18:15:42 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 6/8] drivers: add Contiguous Memory Allocator
Message-ID: <20110706171542.GJ8286@n2100.arm.linux.org.uk>
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107061609.29996.arnd@arndb.de> <20110706142345.GC8286@n2100.arm.linux.org.uk> <201107061651.49824.arnd@arndb.de> <20110706154857.GG8286@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1107061100290.17624@router.home> <op.vx7ghajd3l0zgt@mnazarewicz-glaptop> <alpine.DEB.2.00.1107061114150.19547@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107061114150.19547@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-media@vger.kernel.org, Andi Kleen <andi@firstfloor.org>

On Wed, Jul 06, 2011 at 11:19:00AM -0500, Christoph Lameter wrote:
> What I described is the basic memory architecture of Linux. I am not that
> familiar with ARM and the issue discussed here. Only got involved because
> ZONE_DMA was mentioned. The nature of ZONE_DMA is often misunderstood.
> 
> The allocation of the memory banks for the Samsung devices has to fit
> somehow into one of these zones. Its probably best to put the memory banks
> into ZONE_NORMAL and not have any dependency on ZONE_DMA at all.

Let me teach you about the ARM memory management on Linux.

Firstly, lets go over the structure of zones in Linux.  There are three
zones - ZONE_DMA, ZONE_NORMAL and ZONE_HIGHMEM.  These zones are filled
in that order.  So, ZONE_DMA starts at zero.  Following on from ZONE_DMA
is ZONE_NORMAL memory, and lastly ZONE_HIGHMEM.

At boot, we pass all memory over to the kernel as follows:

1. If there is no DMA zone, then we pass all low memory over as ZONE_NORMAL.

2. If there is a DMA zone, by default we pass all low memory as ZONE_DMA.
   This is required so drivers which use GFP_DMA can work.

   Platforms with restricted DMA requirements can modify that layout to
   move memory from ZONE_DMA into ZONE_NORMAL, thereby restricting the
   upper address which the kernel allocators will give for GFP_DMA
   allocations.

3. In either case, any high memory as ZONE_HIGHMEM if configured (or memory
   is truncated if not.)

So, when we have (eg) a platform where only the _even_ MBs of memory are
DMA-able, we have a 1MB DMA zone at the beginning of system memory, and
everything else in ZONE_NORMAL.  This means GFP_DMA will return either
memory from the first 1MB or fail if it can't.  This is the behaviour we
desire.

Normal allocations will come from ZONE_NORMAL _first_ and then try ZONE_DMA
if there's no other alternative.  This is the same desired behaviour as
x86.

So, ARM is no different from x86, with the exception that the 16MB DMA
zone due to ISA ends up being different sizes on ARM depending on our
restrictions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
