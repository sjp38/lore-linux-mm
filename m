Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5824A6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 16:59:16 -0400 (EDT)
Received: by ywb26 with SMTP id 26so3691287ywb.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 13:59:14 -0700 (PDT)
MIME-Version: 1.0
Reply-To: M.K.Edwards@gmail.com
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
Date: Tue, 14 Jun 2011 13:59:14 -0700
Message-ID: <BANLkTi=n+sig+JE5cCEdBqw1WwBn+2VZBA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: "Michael K. Edwards" <m.k.edwards@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: KyongHo Cho <pullip.cho@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

On Tue, Jun 14, 2011 at 11:21 AM, Jesse Barnes <jbarnes@virtuousgeek.org> w=
rote:
> We try to avoid allowing userspace to pin arbitrary buffers though. =A0So
> on the gfx side, userspace can allocate buffers, but they're only
> actually pinned when some operation is performed on them (e.g. they're
> referenced in a command buffer or used for a mode set operation).

The issue isn't so much pinning; I don't really care if the physical
memory moves out from under me as long as the mappings are properly
updated in all the process page tables that share it and all the
hardware units that care.  But the mapping has to have the right cache
policy from the beginning, so that I get the important part of write
combining (the fill buffer allocation -- without bothering to load
contents from DRAM that are likely to be completely clobbered -- and
the cache-line-sized flush once it's filled).  In any case, supposedly
there are weird aliasing issues if you try to take a page that is
already mapped cacheable and remap it write-combine; and in the case
of shared pages, you'd need to look up all processes that have the
page mapped and alter their page tables, even if they're currently
running on other SMP cores.  Nasty.

Besides, I don't want little 4K pages; I want a hugepage with the
right cache policy, in which I can build a malloc pool (tcmalloc,
jemalloc, something like that) and allocate buffers for a variety of
purposes.  (I also want to use this to pass whole data structures,
like priority search trees built using offset pointers, among cores
that don't share a cache hierarchy or a cache coherency protocol.)

Presumably the privilege of write-combine buffer allocation would be
limited to processes that have been granted the appropriate
capability; but then that process should be able to share it with
others.  I would think the natural thing would be for the special-page
allocation API to return a file descriptor, which can then be passed
over local domain sockets and mmap()ed by as many processes as
necessary.  For many usage patterns, there will be no need for a
kernel virtual mapping; hardware wants physical addresses (or IOMMU
mappings) anyway.

> Something like ION or GEM can provide the basic alloc & map API, but
> the platform code still has to deal with grabbing hunks of memory,
> making them uncached or write combine, and mapping them to app space
> without conflicts.

Absolutely.  Much like any other hugepage allocation, right?  Not
really something ION or GEM or any other device driver needs to be
involved in.  Except for alignment issues, I suppose; I haven't given
that much thought.

The part about setting up corresponding mappings to the same physical
addresses in the device's DMA mechanics is not buffer *allocation*,
it's buffer *registration*.  That's sort of like V4L2's "user pointer
I/O" mode, in which the userspace app allocates the buffers and uses
the QBUF ioctl to register them.  I see no reason why the enforcement
of minimum alignment and cache policy couldn't be done at buffer
registration time rather than region allocation time.

Cheers,
- Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
