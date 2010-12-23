Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 644D26B0089
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 09:08:27 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=ISO-8859-1
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LDV00AAMWM0BF60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Dec 2010 14:08:24 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDV00B2FWLXCY@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Dec 2010 14:08:22 +0000 (GMT)
Date: Thu, 23 Dec 2010 15:08:21 +0100
From: Tomasz Fujak <t.fujak@samsung.com>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
In-reply-to: <20101223135120.GL3636@n2100.arm.linux.org.uk>
Message-id: <4D1357D5.9000507@samsung.com>
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
 <20101223100642.GD3636@n2100.arm.linux.org.uk>
 <87k4j0ehdl.fsf@erwin.mina86.com>
 <20101223135120.GL3636@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kmpark@infradead.org>, linux-arm-kernel@lists.infradead.org, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On 2010-12-23 14:51, Russell King - ARM Linux wrote:
> On Thu, Dec 23, 2010 at 02:41:26PM +0100, Michal Nazarewicz wrote:
>> Russell King - ARM Linux <linux@arm.linux.org.uk> writes:
>>> Has anyone addressed my issue with it that this is wide-open for
>>> abuse by allocating large chunks of memory, and then remapping
>>> them in some way with different attributes, thereby violating the
>>> ARM architecture specification?
>>>
>>> In other words, do we _actually_ have a use for this which doesn't
>>> involve doing something like allocating 32MB of memory from it,
>>> remapping it so that it's DMA coherent, and then performing DMA
>>> on the resulting buffer?
>> Huge pages.
>>
>> Also, don't treat it as coherent memory and just flush/clear/invalidate
>> cache before and after each DMA transaction.  I never understood what's
>> wrong with that approach.
> If you've ever used an ARM system with a VIVT cache, you'll know what's
> wrong with this approach.
>
> ARM systems with VIVT caches have extremely poor task switching
> performance because they flush the entire data cache at every task switch
> - to the extent that it makes system performance drop dramatically when
> they become loaded.
>
> Doing that for every DMA operation will kill the advantage we've gained
> from having VIPT caches and ASIDs stone dead.
This statement effectively means: don't map dma-able memory to the CPU
unless it's uncached. Have I missed anything?

> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
