Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 39BE56B002C
	for <linux-mm@kvack.org>; Sat,  4 Feb 2012 23:25:42 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so4315069wgb.26
        for <linux-mm@kvack.org>; Sat, 04 Feb 2012 20:25:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328271538-14502-13-git-send-email-m.szyprowski@samsung.com>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
	<1328271538-14502-13-git-send-email-m.szyprowski@samsung.com>
Date: Sun, 5 Feb 2012 12:25:40 +0800
Message-ID: <CAJd=RBBPOwftZJUfe3xc6y24=T8un5hPk0wEOT_5v6WMCbDSag@mail.gmail.com>
Subject: Re: [PATCH 12/15] drivers: add Contiguous Memory Allocator
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>

On Fri, Feb 3, 2012 at 8:18 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> The Contiguous Memory Allocator is a set of helper functions for DMA
> mapping framework that improves allocations of contiguous memory chunks.
>
> CMA grabs memory on system boot, marks it with CMA_MIGRATE_TYPE and
> gives back to the system. Kernel is allowed to allocate movable pages
> within CMA's managed memory so that it can be used for example for page
> cache when DMA mapping do not use it. On dma_alloc_from_contiguous()
> request such pages are migrated out of CMA area to free required
> contiguous block and fulfill the request. This allows to allocate large
> contiguous chunks of memory at any time assuming that there is enough
> free memory available in the system.
>
> This code is heavily based on earlier works by Michal Nazarewicz.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> Tested-by: Rob Clark <rob.clark@linaro.org>
> Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
> Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
> ---

[...]

> +/*
> + * Contiguous Memory Allocator
> + *
> + * =C2=A0 The Contiguous Memory Allocator (CMA) makes it possible to
> + * =C2=A0 allocate big contiguous chunks of memory after the system has
> + * =C2=A0 booted.
> + *
> + * Why is it needed?
> + *
> + * =C2=A0 Various devices on embedded systems have no scatter-getter and=
/or
> + * =C2=A0 IO map support and require contiguous blocks of memory to
> + * =C2=A0 operate. =C2=A0They include devices such as cameras, hardware =
video
> + * =C2=A0 coders, etc.
> + *
> + * =C2=A0 Such devices often require big memory buffers (a full HD frame
> + * =C2=A0 is, for instance, more then 2 mega pixels large, i.e. more tha=
n 6
> + * =C2=A0 MB of memory), which makes mechanisms such as kmalloc() or
> + * =C2=A0 alloc_page() ineffective.
> + *
> + * =C2=A0 At the same time, a solution where a big memory region is
> + * =C2=A0 reserved for a device is suboptimal since often more memory is
> + * =C2=A0 reserved then strictly required and, moreover, the memory is
> + * =C2=A0 inaccessible to page system even if device drivers don't use i=
t.
> + *
> + * =C2=A0 CMA tries to solve this issue by operating on memory regions
> + * =C2=A0 where only movable pages can be allocated from. =C2=A0This way=
, kernel
> + * =C2=A0 can use the memory for pagecache and when device driver reques=
ts
> + * =C2=A0 it, allocated pages can be migrated.
> + *

Without boot mem reservation, what is the successful rate of CMA to
serve requests of 1MiB, 2MiB, 4MiB and 8MiB chunks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
