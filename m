Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 461F3900117
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 20:06:32 -0400 (EDT)
Received: by pvh10 with SMTP id 10so2429890pvh.15
        for <linux-mm@kvack.org>; Sat, 25 Jun 2011 17:06:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=y6PGMdHq0uT9QJ7aej3nU6cKW2g@mail.gmail.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<4E017539.30505@gmail.com>
	<001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>
	<4E01AD7B.3070806@gmail.com>
	<002701cc30be$ab296cc0$017c4640$%szyprowski@samsung.com>
	<4E02119F.4000901@codeaurora.org>
	<4E033AFF.4020603@gmail.com>
	<BANLkTikzTwNvaaUSk26qzONemogBAGuBRg@mail.gmail.com>
	<BANLkTimi2FAmcb7ZWnjRqb-Cb8acXWsCTw@mail.gmail.com>
	<BANLkTinUCZrd-JuMc3TkaF4f1VBmOu9nxQ@mail.gmail.com>
	<BANLkTi=y6PGMdHq0uT9QJ7aej3nU6cKW2g@mail.gmail.com>
Date: Sun, 26 Jun 2011 03:06:30 +0300
Message-ID: <BANLkTi=uNVLOy4oTTBpr8niRMX+m6wgWBg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
From: Jonathan Morton <jonathan.morton@movial.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: M.K.Edwards@gmail.com
Cc: Subash Patel <subashrp@gmail.com>, Jordan Crouse <jcrouse@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arch@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On 25 June 2011 12:55, Michael K. Edwards <m.k.edwards@gmail.com> wrote:
> With regard to the use of NEON for data moves, I have appended a
> snippet of a conversation from the BeagleBoard list that veered off
> into a related direction. =A0(My response is lightly edited, since I
> made some stupid errors in the original.) =A0While this is somewhat
> off-topic from Marek's patch set, I think it's relevant to the
> question of whether "user-allocated" buffers are an important design
> consideration for his otherwise DMA-centric API. =A0(And more to the
> point, buffers allocated suitably for one or more on-chip devices, and
> also mapped as uncacheable to userland.)

As far as userspace is concerned, dealing with the memory hierarchy's
quirks is already pretty much a black art, and that's *before* you
start presenting it with uncached buffers.  The best rule of thumb
userspace can follow is to keep things in cache if they can, and use
the biggest memory-move instructions (and prefetching if available) if
they can't.  Everything else they have to rely on the hardware to
optimise for them.  Indeed, when working in C, you barely even get
*that* level of control (optimised copy routines have been known to
use double simply because it is reliably 64 bits that can be loaded
and stored efficiently), and most other languages are worse.

Small wonder that userspace code that knows it has to work with
uncached buffers sometimes - such as Pixman - relies heavily on
handwritten SIMD assembler.

Video decoders are a particularly fun case, because the correct
solution is actually to DMA the output buffer to the GPU (or, better,
to map one onto the other so that zero-copy semantics result) so that
the CPU doesn't have to touch it.  But then you have to find a common
format that both VPU and GPU support, and you have to have a free DMA
channel and a way to use it.  Frankly though, this is a solution from
the 20th century (remember MPEG2 decoders sitting beside the SVGA
card?).

We *have* had to occasionally deal with hardware where no such common
format could be found, although often this has been due to inadequate
documentation or driver support (a familiar refrain).  In one case I
wrote a NEON NV12-to-RGB32 conversion routine which read directly from
the video buffer and wrote directly into a texture buffer, both of
which were of course uncached.  This halved the CPU consumption of the
video playback applet, but prefixing it with a routine which copied
the video buffer into cached memory (using 32-byte VLD1 instead of
16-byte versions) halved it again.  Profiling showed that the vast
majority of the time was spent in the prefix copy loop.  No doubt if
further savings had been required, I'd have tried using VLDM in the
copy loop.  (There weren't enough registers to widen the load stage of
the conversion routine itself.)

The takeaway from this is that if your code has to read from uncached
memory at all, that will undoubtedly dominate it's performance.  A
read-modify-write cycle is at least as bad (because the memory has to
go through at least one CAS latency and a write-to-read turnaround
before the next read can be serviced).  A pure write is, however, no
problem.

On cached memory, the L2 cache of most modern (even ARM) CPUs has an
auto-prefetcher which will help out with sequential transfers.  This
should get somewhere reasonably close to optimal performance.

 - Jonathan Morton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
