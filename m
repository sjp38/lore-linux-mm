Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 55BEE9000C2
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 11:28:47 -0400 (EDT)
Date: Sun, 3 Jul 2011 16:28:26 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 1/8] ARM: dma-mapping: remove offset parameter to
	prepare for generic dma_ops
Message-ID: <20110703152826.GL21898@n2100.arm.linux.org.uk>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <1308556213-24970-2-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308556213-24970-2-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>

On Mon, Jun 20, 2011 at 09:50:06AM +0200, Marek Szyprowski wrote:
> This patch removes the need for offset parameter in dma bounce
> functions. This is required to let dma-mapping framework on ARM
> architecture use common, generic dma-mapping helpers.

I really don't like this.  Really as in hate.  Why?  I've said in the past
that the whole idea of getting rid of the sub-range functions is idiotic.

If you have to deal with cache coherence, what you _really_ want is an
API which tells you the size of the original buffer and the section of
that buffer which you want to handle - because the edges of the buffer
need special handling.

Lets say that you have a buffer which is 256 bytes long, misaligned to
half a cache line.  Let's first look at the sequence for whole-buffer:

1. You map it for DMA from the device.  This means you writeback the
   first and last cache lines to perserve any data shared in the
   overlapping cache line.  The remainder you can just invalidate.

2. You want to access the buffer, so you use the sync_for_cpu function.
   If your CPU doesn't do any speculative prefetching, then you don't
   need to do anything.  If you do, you have to invalidate the buffer,
   but you must preserve the overlapping cache lines which again must
   be written back.

3. You transfer ownership back to the device using sync_for_device.
   As you may have caused cache lines to be read in, again you need to
   invalidate, and the overlapping cache lines must be written back.

Now, if you ask for a sub-section of the buffer to be sync'd, you can
actually eliminate those writebacks which are potentially troublesome,
and which could corrupt neighbouring data.

If you get rid of the sub-buffer functions and start using the whole
buffer functions for that purpose, you no longer know whether the
partial cache lines are part of the buffer or not, so you have to write
those back every time too.

So far, we haven't had any reports of corruption of this type (maybe
folk using the sync functions are rare on ARM - thankfully) but getting
rid of the range sync functions means that solving this becomes a lot
more difficult because we've lost the information to make the decision.

So I've always believed - and continue to do so - that those who want
to get rid of the range sync functions are misguided and are storing up
problems for the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
