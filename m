Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E398B6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 10:52:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so11178410wmz.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 07:52:27 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id f197si25888343wmf.73.2016.08.17.07.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 07:52:26 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id i5so237514273wmg.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 07:52:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdU+j50GFT=DUWsx_dz1VJJ5zY2EVJi4cX4ZhVVLRMyjCA@mail.gmail.com>
References: <CAMuHMdU+j50GFT=DUWsx_dz1VJJ5zY2EVJi4cX4ZhVVLRMyjCA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 17 Aug 2016 07:52:25 -0700
Message-ID: <CAGXu5jJ0OCR995Xu41SQvw2YQX-JUO5BhVyOuy0=wJ3Su07puw@mail.gmail.com>
Subject: Re: usercopy: kernel memory exposure attempt detected
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux MM <linux-mm@kvack.org>, "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, Aug 17, 2016 at 5:13 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> Hi Kees, Al,
>
> Saw this when using NFS root on r8a7791/koelsch, using a tree based on
> renesas-drivers-2016-08-16-v4.8-rc2:
>
> usercopy: kernel memory exposure attempt detected from c01ff000
> (<kernel text>) (4096 bytes)

Hmmm, the kernel text exposure on ARM usually means the hardened
usercopy patchset was applied to an ARM tree without the _etext patch:
http://git.kernel.org/linus/14c4a533e0996f95a0a64dfd0b6252d788cebc74

If you _do_ have this patch already (and based on the comment below, I
suspect you do: usually the missing _etext makes the system entirely
unbootable), then we need to dig further.

> ------------[ cut here ]------------
> kernel BUG at mm/usercopy.c:75!
> Internal error: Oops - BUG: 0 [#1] SMP ARM
> Modules linked in:
> CPU: 1 PID: 1636 Comm: exim4 Not tainted
> 4.8.0-rc2-koelsch-00407-g7a4ab698caefa57a-dirty #2901
> Hardware name: Generic R8A7791 (Flattened Device Tree)
> task: eeae7100 task.stack: eeace000
> PC is at __check_object_size+0x2d0/0x390
> LR is at __check_object_size+0x2d0/0x390
> pc : [<c02d33fc>]    lr : [<c02d33fc>]    psr: 600f0013
> sp : eeacfe28  ip : 00000000  fp : c0200000
> r10: b6f9c000  r9 : eeacff0c  r8 : 00000001
> r7 : c0e05444  r6 : c01fffff  r5 : 00001000  r4 : c01ff000
> r3 : 00000001  r2 : 2ed71000  r1 : ef9b43f0  r0 : 0000005c
> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> Control: 30c5387d  Table: 6dcd62c0  DAC: 55555555
> Process exim4 (pid: 1636, stack limit = 0xeeace210)
> Stack: (0xeeacfe28 to 0xeead0000)
> fe20:                   c095c004 00001000 00000002 ef9fcc80 eeacfe38 00001000
> fe40: c01ff000 00001000 00000000 eeacff14 eeacff0c b6f9c000 ef22d4ac c03eea60
> fe60: 00000001 00000000 00000000 ee78bf00 eeacff28 ef9fcfe0 00001000 c029c914
> fe80: 00000004 00000001 00000000 eeacff14 00000000 ef22d3b8 00001000 00000000
> fea0: ee78bf88 00000002 ef22d3b8 c06afb3c 00000000 c038a9c8 c0c4b780 c02a0cd8
> fec0: effce060 eeacff28 ef22d3b8 00000000 eeacff14 c0206ce4 eeace000 00000000
> fee0: 00000000 c0387698 c0387644 00000000 ee78bf00 eeacff88 00001000 c02d5550
> ff00: 00001000 c06afb3c 00000001 b6f9c000 00001000 00000000 00000000 00001000
> ff20: eeacff0c 00000001 ee78bf00 00000000 00001000 00000000 00000000 00000000
> ff40: 00000000 00000000 ef365e38 00001000 ee78bf00 b6f9c000 eeacff88 c02d6080
> ff60: ee78bf00 b6f9c000 00001000 ee78bf00 ee78bf00 00001000 b6f9c000 c0206ce4
> ff80: eeace000 c02d6cd8 00001000 00000000 00001000 7f723250 b6c2bbfc 00003fdf
> ffa0: 00000003 c0206b40 7f723250 b6c2bbfc 00000004 b6f9c000 00001000 00000000
> ffc0: 7f723250 b6c2bbfc 00003fdf 00000003 7f71efdf 0000000a 7f71efc0 00000000
> ffe0: 00000000 be80f4ac b6b90817 b6bcadd6 400f0030 00000004 30133e52 60547340
> [<c02d33fc>] (__check_object_size) from [<c03eea60>]
> (copy_page_to_iter+0x114/0x1f0)
> [<c03eea60>] (copy_page_to_iter) from [<c029c914>]
> (generic_file_read_iter+0x3a0/0x7e8)
> [<c029c914>] (generic_file_read_iter) from [<c0387698>]
> (nfs_file_read+0x54/0x98)
> [<c0387698>] (nfs_file_read) from [<c02d5550>] (__vfs_read+0xdc/0x104)
> [<c02d5550>] (__vfs_read) from [<c02d6080>] (vfs_read+0x94/0x100)
> [<c02d6080>] (vfs_read) from [<c02d6cd8>] (SyS_read+0x40/0x80)
> [<c02d6cd8>] (SyS_read) from [<c0206b40>] (ret_fast_syscall+0x0/0x34)
> Code: e88d0021 e1a03004 e59f00b0 ebff176b (e7f001f2)
>
> Despite the BUG(), the system continues working.

I assume exim4 got killed, though?

If you can figure out what bytes are present at c01ff000, that may
give us a clue.

-Kees

>
> Gr{oetje,eeting}s,
>
>                         Geert
>
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
>
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
