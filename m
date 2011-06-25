Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 746E690023D
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 01:23:04 -0400 (EDT)
Received: by mail-pv0-f180.google.com with SMTP id 21so1961509pvc.25
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 22:23:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimi2FAmcb7ZWnjRqb-Cb8acXWsCTw@mail.gmail.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<4E017539.30505@gmail.com>
	<001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>
	<4E01AD7B.3070806@gmail.com>
	<002701cc30be$ab296cc0$017c4640$%szyprowski@samsung.com>
	<4E02119F.4000901@codeaurora.org>
	<4E033AFF.4020603@gmail.com>
	<BANLkTikzTwNvaaUSk26qzONemogBAGuBRg@mail.gmail.com>
	<BANLkTimi2FAmcb7ZWnjRqb-Cb8acXWsCTw@mail.gmail.com>
Date: Sat, 25 Jun 2011 08:23:00 +0300
Message-ID: <BANLkTinUCZrd-JuMc3TkaF4f1VBmOu9nxQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
From: Jonathan Morton <jonathan.morton@movial.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: M.K.Edwards@gmail.com
Cc: Subash Patel <subashrp@gmail.com>, Jordan Crouse <jcrouse@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arch@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On 24 June 2011 01:09, Michael K. Edwards <m.k.edwards@gmail.com> wrote:
> Jonathan -
>
> I'm inviting you to this conversation (and to linaro-mm-sig, if you'd
> care to participate!), because I'd really like your commentary on what
> it takes to make write-combining fully effective on various ARMv7
> implementations.

Thanks for the invite.  I'm not fully conversant with the kernel-level
intricacy, but I do know what application code sees, and I have a
fairly good idea of what happens at the SDRAM pinout.

> Getting full write-combining performance on Intel architectures
> involves a somewhat delicate dance:
> =A0http://software.intel.com/en-us/articles/copying-accelerated-video-dec=
ode-frame-buffers/

At a high level, that looks like a pretty effective technique (and
well explained) that works cross-platform with detail changes.
However, that describes *read* combining on an uncached area, rather
than write combining.

Write combining is easy - in my experience it Just Works on ARMv7 SoCs
in general.  In practice, I've found that you can write pretty much
anything to uncached memory and the write-combiner will deal with it
fairly intelligently.  Small writes sufficiently close together in
time and contiguous in area will be combined reliably.  This assumes
that the region is marked write-combinable, which should always be the
case for plain SDRAM.  So memcpy() *to* an uncached zone works okay,
even wtih an alignment mismatch.

Read combining is much harder as soon as you turn off the cache, which
defeats all of the nice auto-prefetching mechanisms that tend to be
built into modern caches.  Even the newest ARM SoCs disable any and
all speculative behaviour for uncached reads - it is then not possible
to set up a "streaming read" even explicitly (even though you could
reasonably express such using PLD).

There will typically be a full cache-miss latency per instruction (20+
cycles on A8), even if the addresses are exactly sequential.  If they
are not sequential, or if the memory controller does a read or write
to somewhere else in the meantime, you also get the CAS or RAS
latencies of about 25ns each, which hurt badly (CAS and RAS have not
sped up appreciably, in real terms, since PC133 a decade ago - sense
amps are not so good at fulfilling Moore's Law).  So on a 1GHz
Cortex-A8, you can spend 80 clock cycles waiting for a memory load to
complete - that's about 20 for the memory system to figure out it's
uncacheable and cause the CPU core to replay the instruction twice, 50
waiting for the SDRAM chip to spin up, and another 10 as a fudge
factor and to allow the data to percolate up.

This situation is sufficiently common that I assume (and I tell my
colleagues to assume) that this is the case.  If a vendor were to turn
off write-combining for a memory area, I would complain very loudly to
them once I discovered it.  So far, though, I can only wish that they
would sort out the memory hierarchy to make framebuffer & video reads
better.

I *have* found one vendor who appears to put GPU command buffers in
cached memory, but this necessitates a manual cache cleaning exercise
every time the command buffer is flushed.  This is a substantial
overhead too, but is perhaps easier to optimise.

IMO this whole problem is a hardware design fault.  It's SDRAM
directly wired to the chip; there's nothing going on that the memory
controller doesn't know about.  So why isn't the last cache level part
of / attached to the memory controller, so that it can be used
transparently by all relevant bus masters?  It is, BTW, not only ARM
that gets this wrong, but in the Wintel world there is so much
horsepower to spare that few people notice.

> And I expect something similar to be necessary in order to avoid the
> read-modify-write penalty for write-combining buffers on ARMv7. =A0(NEON
> store-multiple operations can fill an entire 64-byte entry in the
> victim buffer in one opcode; I don't know whether this is enough to
> stop the L3 memory system from reading the data before clobbering it.)

Ah, now you are talking about store misses to cached memory.

Why 64 bytes?  VLD1 does 32 bytes (4x64b) and VLDM can do 128 bytes
(16x64b).  The latter is, I think, bigger than Intel's fill buffers.
Each of these have exactly equivalent store variants.

The manual for the Cortex-A8 states that store misses in the L1 cache
are sent to the L2 cache; the L2 cache then has validity bits for
every quadword (ie. four validity domains per line), so a 16-byte
store (if aligned) is sufficient to avoid read traffic.  I assume that
the A9 and A5 are at least as sophisticated, not sure about
Snapdragon.

 - Jonathan Morton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
