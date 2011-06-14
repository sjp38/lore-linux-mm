Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 61B4B6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 14:15:42 -0400 (EDT)
Received: by yxp4 with SMTP id 4so1271621yxp.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:15:39 -0700 (PDT)
MIME-Version: 1.0
Reply-To: M.K.Edwards@gmail.com
In-Reply-To: <20110613115437.62824f2f@jbarnes-desktop>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
	<BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
	<201106131707.49217.arnd@arndb.de>
	<BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
	<20110613154033.GA29185@1n450.cable.virginmedia.net>
	<BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
	<BANLkTi=C6NKT94Fk6Rq6wmhndVixOqC6mg@mail.gmail.com>
	<20110613115437.62824f2f@jbarnes-desktop>
Date: Tue, 14 Jun 2011 11:15:38 -0700
Message-ID: <BANLkTimV5ZXVTDDFqHxMpOkrgokdCp1YXA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: "Michael K. Edwards" <m.k.edwards@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: KyongHo Cho <pullip.cho@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

On Mon, Jun 13, 2011 at 11:54 AM, Jesse Barnes <jbarnes@virtuousgeek.org> w=
rote:
> Well only if things are really broken. =A0sysfs exposes _wc resource
> files to allow userland drivers to map a given PCI BAR using write
> combining, if the underlying platform supports it.

Mmm, I hadn't spotted that; that is useful, at least as sample code.
Doesn't do me any good directly, though; I'm not on a PCI device, I'm
on a SoC.  And what I need to do is to allocate normal memory through
an uncacheable write-combining page table entry (with certainty that
it is not aliased by a cacheable entry for the same physical memory),
and use it for interchange of data (GPU assets, compressed video) with
other on-chip cores.  (Or with off-chip PCI devices which use DMA to
transfer data to/from these buffers and then interrupt the CPU to
notify it to rotate them.)

What doesn't seem to be straightforward to do from userland is to
allocate pages that are locked to physical memory and mapped for
write-combining.  The device driver shouldn't have to mediate their
allocation, just map to a physical address (or set up an IOMMU entry,
I suppose) and pass that to the hardware that needs it.  Typical
userland code that could use such a mechanism would be the Qt/OpenGL
back end (which needs to store decompressed images and other
pre-rendered assets in GPU-ready buffers) and media pipelines.

> Similarly, userland mapping of GEM objects through the GTT are supposed
> to be write combined, though I need to verify this (we've had trouble
> with it in the past).

Also a nice source of sample code; though, again, I don't want this to
be driver-specific.  I might want a stage in my media pipeline that
uses the GPU to perform, say, lens distortion correction.  I shouldn't
have to go through contortions to use the same buffers from the GPU
and the video capture device.  The two devices are likely to have
their own variants on scatter-gather DMA, with a circularly linked
list of block descriptors with ownership bits and all that jazz; but
the actual data buffers should be generic, and the userland pipeline
setup code should just allocate them (presumably as contiguous regions
in a write-combining hugepage) and feed them to the plumbing.

Cheers,
- Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
