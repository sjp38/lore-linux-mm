Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0DC6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 15:10:08 -0400 (EDT)
Received: by fxm18 with SMTP id 18so5656610fxm.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 12:10:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110614112108.0186c562@jbarnes-desktop>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
	<BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
	<201106131707.49217.arnd@arndb.de>
	<BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
	<20110613154033.GA29185@1n450.cable.virginmedia.net>
	<BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
	<BANLkTi=C6NKT94Fk6Rq6wmhndVixOqC6mg@mail.gmail.com>
	<20110613115437.62824f2f@jbarnes-desktop>
	<BANLkTimV5ZXVTDDFqHxMpOkrgokdCp1YXA@mail.gmail.com>
	<20110614112108.0186c562@jbarnes-desktop>
Date: Tue, 14 Jun 2011 14:10:04 -0500
Message-ID: <BANLkTimXdVqAXP7nQLE=y79xOOJ1a5ayOw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: Zach Pfeffer <zach.pfeffer@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: M.K.Edwards@gmail.com, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KyongHo Cho <pullip.cho@samsung.com>, linux-arm-kernel@lists.infradead.org

On 14 June 2011 13:21, Jesse Barnes <jbarnes@virtuousgeek.org> wrote:
> On Tue, 14 Jun 2011 11:15:38 -0700
> "Michael K. Edwards" <m.k.edwards@gmail.com> wrote:
>> What doesn't seem to be straightforward to do from userland is to
>> allocate pages that are locked to physical memory and mapped for
>> write-combining. =A0The device driver shouldn't have to mediate their
>> allocation, just map to a physical address (or set up an IOMMU entry,
>> I suppose) and pass that to the hardware that needs it. =A0Typical
>> userland code that could use such a mechanism would be the Qt/OpenGL
>> back end (which needs to store decompressed images and other
>> pre-rendered assets in GPU-ready buffers) and media pipelines.
>
> We try to avoid allowing userspace to pin arbitrary buffers though. =A0So
> on the gfx side, userspace can allocate buffers, but they're only
> actually pinned when some operation is performed on them (e.g. they're
> referenced in a command buffer or used for a mode set operation).
>
> Something like ION or GEM can provide the basic alloc & map API, but
> the platform code still has to deal with grabbing hunks of memory,
> making them uncached or write combine, and mapping them to app space
> without conflicts.
>
>> Also a nice source of sample code; though, again, I don't want this to
>> be driver-specific. =A0I might want a stage in my media pipeline that
>> uses the GPU to perform, say, lens distortion correction. =A0I shouldn't
>> have to go through contortions to use the same buffers from the GPU
>> and the video capture device. =A0The two devices are likely to have
>> their own variants on scatter-gather DMA, with a circularly linked
>> list of block descriptors with ownership bits and all that jazz; but
>> the actual data buffers should be generic, and the userland pipeline
>> setup code should just allocate them (presumably as contiguous regions
>> in a write-combining hugepage) and feed them to the plumbing.
>
> Totally agree. =A0That's one reason I don't think enhancing the DMA
> mapping API in the kernel is a complete solution. =A0Sure, the platform
> code needs to be able to map buffers to devices and use any available
> IOMMUs, but we still need a userspace API for all of that, with its
> associated changes to the CPU MMU handling.

I haven't seen all the discussions but it sounds like creating the
correct userspace abstraction and then looking at how the kernel needs
to change (instead of the other way around) may add some clarity to
things.

> --
> Jesse Barnes, Intel Open Source Technology Center
>
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
