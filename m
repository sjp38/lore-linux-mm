Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8C066B0006
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 18:26:03 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 126-v6so9085959qkd.20
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 15:26:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w51-v6sor5037475qtj.137.2018.06.15.15.26.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 15:26:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180615121716.37fb93385825b0b2f59240cc@linux-foundation.org>
References: <20180606194144.16990-1-malat@debian.org> <CA+8MBbKj4A5kh=hE0vcadzD+=cEAFY7OCWFCzvubu6cWULCJ0A@mail.gmail.com>
 <20180615121716.37fb93385825b0b2f59240cc@linux-foundation.org>
From: Tony Luck <tony.luck@gmail.com>
Date: Fri, 15 Jun 2018 15:26:01 -0700
Message-ID: <CA+8MBbJyXC7YmnjG-k+mahC0ZiSgZy=EoiO0N5gvw8S4afLqng@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: add missing include <linux/bootmem.h>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jun 15, 2018 at 12:17 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:

> Huh.  How did that ever work.  I guess it's either this:
>
> --- a/mm/Makefile~a
> +++ a/mm/Makefile
> @@ -45,6 +45,7 @@ obj-y += init-mm.o
>
>  ifdef CONFIG_NO_BOOTMEM
>         obj-y           += nobootmem.o
> +       obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
>  else
>         obj-y           += bootmem.o
>  endif
> @@ -53,7 +54,6 @@ obj-$(CONFIG_ADVISE_SYSCALLS) += fadvise
>  ifdef CONFIG_MMU
>         obj-$(CONFIG_ADVISE_SYSCALLS)   += madvise.o
>  endif
> -obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
>
>  obj-$(CONFIG_SWAP)     += page_io.o swap_state.o swapfile.o swap_slots.o
>  obj-$(CONFIG_FRONTSWAP)        += frontswap.o

That option gave me a boatload of undefined symbols.

> or this:
>
> --- a/include/linux/bootmem.h~a
> +++ a/include/linux/bootmem.h
> @@ -154,7 +154,7 @@ extern void *__alloc_bootmem_low_node(pg
>         __alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
>
>
> -#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
> +#if defined(CONFIG_HAVE_MEMBLOCK)
>
>  /* FIXME: use MEMBLOCK_ALLOC_* variants here */
>  #define BOOTMEM_ALLOC_ACCESSIBLE       0

That compiles cleanly, but didn't boot:

 [<a000000100029910>] ia64_fault+0xf0/0xe00
                                sp=e0000004fb37f8a0 bsp=e0000004fb371438
 [<a00000010000c920>] ia64_leave_kernel+0x0/0x270
                                sp=e0000004fb37fba0 bsp=e0000004fb371438
hid-generic 0003:0624:0200.0001: input: USB HID v1.10 Mouse [Avocent
USB_AMIQ] on usb-0000:00:1d.0-2/input1
 [<a00000010020b100>] pcpu_find_block_fit+0x20/0x300
                                sp=e0000004fb37fd70 bsp=e0000004fb3713a8
 [<a00000010020ee70>] pcpu_alloc+0x630/0xc40
                                sp=e0000004fb37fd90 bsp=e0000004fb371308
input: Avocent USB_AMIQ as
/devices/pci0000:00/0000:00:1d.0/usb4/4-2/4-2:1.0/0003:0624:0200.0002/input/input3
 [<a00000010020f520>] __alloc_percpu+0x40/0x60
                                sp=e0000004fb37fda0 bsp=e0000004fb3712e0
 [<a0000001002fb4c0>] alloc_vfsmnt+0x1c0/0x4e0
                                sp=e0000004fb37fda0 bsp=e0000004fb371280
 [<a000000100303d10>] vfs_kern_mount+0x30/0x2a0
                                sp=e0000004fb37fdf0 bsp=e0000004fb371238


> and I'm not sure which.  I think I'll just revert $subject for now.

Reverting is a good short term fix.

-Tony
