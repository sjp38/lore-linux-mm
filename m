Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F07BB6B0098
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 18:48:49 -0400 (EDT)
Received: by iwn9 with SMTP id 9so1173131iwn.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 15:48:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101103220941.C88FA932@kernel.beaverton.ibm.com>
References: <20101103220941.C88FA932@kernel.beaverton.ibm.com>
Date: Thu, 4 Nov 2010 07:48:45 +0900
Message-ID: <AANLkTi=4a6+4qQHN5pqi8Dd7-FUSn7TzauK4uUQ4YCVf@mail.gmail.com>
Subject: Re: [PATCH] Revalidate page->mapping in do_generic_file_read()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, arunabal@in.ibm.com, sbest@us.ibm.com, stable <stable@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 4, 2010 at 7:09 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrote=
:
>
> 70 hours into some stress tests of a 2.6.32-based enterprise kernel,
> we ran into a NULL dereference in here:
>
> =A0 =A0 =A0 =A0int block_is_partially_uptodate(struct page *page, read_de=
scriptor_t *desc,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned long from)
> =A0 =A0 =A0 =A0{
> ----> =A0 =A0 =A0 =A0 =A0 struct inode *inode =3D page->mapping->host;
>
> It looks like page->mapping was the culprit. =A0(xmon trace is below).
> After closer examination, I realized that do_generic_file_read() does
> a find_get_page(), and eventually locks the page before calling
> block_is_partially_uptodate(). =A0However, it doesn't revalidate the
> page->mapping after the page is locked. =A0So, there's a small window
> between the find_get_page() and ->is_partially_uptodate() where the
> page could get truncated and page->mapping cleared.
>
> We _have_ a reference, so it can't get reclaimed, but it certainly
> can be truncated.
>
> I think the correct thing is to check page->mapping after the
> trylock_page(), and jump out if it got truncated. =A0This patch has
> been running in the test environment for a month or so now, and we
> have not seen this bug pop up again.
>
> xmon info:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> 1f:mon> e
> cpu 0x1f: Vector: 300 (Data Access) at [c0000002ae36f770]
> =A0 =A0pc: c0000000001e7a6c: .block_is_partially_uptodate+0xc/0x100
> =A0 =A0lr: c000000000142944: .generic_file_aio_read+0x1e4/0x770
> =A0 =A0sp: c0000002ae36f9f0
> =A0 msr: 8000000000009032
> =A0 dar: 0
> =A0dsisr: 40000000
> =A0current =3D 0xc000000378f99e30
> =A0paca =A0 =A0=3D 0xc000000000f66300
> =A0 =A0pid =A0 =3D 21946, comm =3D bash
> 1f:mon> r
> R00 =3D 0025c0500000006d =A0 R16 =3D 0000000000000000
> R01 =3D c0000002ae36f9f0 =A0 R17 =3D c000000362cd3af0
> R02 =3D c000000000e8cd80 =A0 R18 =3D ffffffffffffffff
> R03 =3D c0000000031d0f88 =A0 R19 =3D 0000000000000001
> R04 =3D c0000002ae36fa68 =A0 R20 =3D c0000003bb97b8a0
> R05 =3D 0000000000000000 =A0 R21 =3D c0000002ae36fa68
> R06 =3D 0000000000000000 =A0 R22 =3D 0000000000000000
> R07 =3D 0000000000000001 =A0 R23 =3D c0000002ae36fbb0
> R08 =3D 0000000000000002 =A0 R24 =3D 0000000000000000
> R09 =3D 0000000000000000 =A0 R25 =3D c000000362cd3a80
> R10 =3D 0000000000000000 =A0 R26 =3D 0000000000000002
> R11 =3D c0000000001e7b60 =A0 R27 =3D 0000000000000000
> R12 =3D 0000000042000484 =A0 R28 =3D 0000000000000001
> R13 =3D c000000000f66300 =A0 R29 =3D c0000003bb97b9b8
> R14 =3D 0000000000000001 =A0 R30 =3D c000000000e28a08
> R15 =3D 000000000000ffff =A0 R31 =3D c0000000031d0f88
> pc =A0=3D c0000000001e7a6c .block_is_partially_uptodate+0xc/0x100
> lr =A0=3D c000000000142944 .generic_file_aio_read+0x1e4/0x770
> msr =3D 8000000000009032 =A0 cr =A0=3D 22000488
> ctr =3D c0000000001e7a60 =A0 xer =3D 0000000020000000 =A0 trap =3D =A0300
> dar =3D 0000000000000000 =A0 dsisr =3D 40000000
> 1f:mon> t
> [link register =A0 ] c000000000142944 .generic_file_aio_read+0x1e4/0x770
> [c0000002ae36f9f0] c000000000142a14 .generic_file_aio_read+0x2b4/0x770
> (unreliable)
> [c0000002ae36fb40] c0000000001b03e4 .do_sync_read+0xd4/0x160
> [c0000002ae36fce0] c0000000001b153c .vfs_read+0xec/0x1f0
> [c0000002ae36fd80] c0000000001b1768 .SyS_read+0x58/0xb0
> [c0000002ae36fe30] c00000000000852c syscall_exit+0x0/0x40
> --- Exception: c00 (System Call) at 00000080a840bc54
> SP (fffca15df30) is in userspace
> 1f:mon> di c0000000001e7a6c
> c0000000001e7a6c =A0e9290000 =A0 =A0 =A0ld =A0 =A0 =A0r9,0(r9)
> c0000000001e7a70 =A0418200c0 =A0 =A0 =A0beq =A0 =A0 c0000000001e7b30 =A0 =
=A0 =A0 =A0#
> .block_is_partially_uptodate+0xd0/0x100
> c0000000001e7a74 =A0e9440008 =A0 =A0 =A0ld =A0 =A0 =A0r10,8(r4)
> c0000000001e7a78 =A078a80020 =A0 =A0 =A0clrldi =A0r8,r5,32
> c0000000001e7a7c =A03c000001 =A0 =A0 =A0lis =A0 =A0 r0,1
> c0000000001e7a80 =A0812900a8 =A0 =A0 =A0lwz =A0 =A0 r9,168(r9)
> c0000000001e7a84 =A039600001 =A0 =A0 =A0li =A0 =A0 =A0r11,1
> c0000000001e7a88 =A07c080050 =A0 =A0 =A0subf =A0 =A0r0,r8,r0
> c0000000001e7a8c =A07f805040 =A0 =A0 =A0cmplw =A0 cr7,r0,r10
> c0000000001e7a90 =A07d6b4830 =A0 =A0 =A0slw =A0 =A0 r11,r11,r9
> c0000000001e7a94 =A0796b0020 =A0 =A0 =A0clrldi =A0r11,r11,32
> c0000000001e7a98 =A0419d00a8 =A0 =A0 =A0bgt =A0 =A0 cr7,c0000000001e7b40 =
=A0 =A0#
> .block_is_partially_uptodate+0xe0/0x100
> c0000000001e7a9c =A07fa55840 =A0 =A0 =A0cmpld =A0 cr7,r5,r11
> c0000000001e7aa0 =A07d004214 =A0 =A0 =A0add =A0 =A0 r8,r0,r8
> c0000000001e7aa4 =A079080020 =A0 =A0 =A0clrldi =A0r8,r8,32
> c0000000001e7aa8 =A0419c0078 =A0 =A0 =A0blt =A0 =A0 cr7,c0000000001e7b20 =
=A0 =A0#
> .block_is_partially_uptodate+0xc0/0x100
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> Cc: arunabal@in.ibm.com
> Cc: sbest@us.ibm.com
> Cc: stable <stable@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch.
It was much better if you comment it.
Thanks, Dave.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
