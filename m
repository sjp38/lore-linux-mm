Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A22AF6B009C
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 16:48:26 -0400 (EDT)
Message-ID: <56111.84.105.60.153.1287521237.squirrel@gate.crashing.org>
In-Reply-To: <20101019181021.22456.qmail@kosh.dhis.org>
References: <20101019181021.22456.qmail@kosh.dhis.org>
Date: Tue, 19 Oct 2010 22:47:17 +0200 (CEST)
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
From: "Segher Boessenkool" <segher@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: pacman@kosh.dhis.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I made a new discovery.

And this nails it :-)

> So then I ran
>   dd if=/dev/mem bs=4 count=1 skip=$((0xfc5c080/4)) | od -t x4
> a few times very fast, plucking the first affected word directly out of
> memory by its physical address. The result:
>
> The low 16 bits are always zero as before. The high 16 bits are a counter,
> being incremented at about 1000Hz (as close as I could measure with a
> crude
> shell script. 1024Hz would also be within the margin of error). And it's
> little-endian.

> So what type of driver, firmware, or hardware bug puts a 16-bit 1000Hz
> timer
> in memory, and does it in little-endian instead of the CPU's native byte
> order? And why does it stop doing it some time during the early init
> scripts,
> shortly after the root filesystem fsck?

It looks like it is the frame counter in an USB OHCI HCCA.
16-bit, 1kHz update, offset x'80 in a page.

So either the kernel forgot to call quiesce on it, or the firmware
doesn't implement that, or the firmware messed up some other way.


Segher

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
