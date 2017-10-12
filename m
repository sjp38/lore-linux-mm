Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79BBD6B0038
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:03:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so3991718pfk.0
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:03:43 -0700 (PDT)
Received: from relmlie2.idc.renesas.com (relmlor3.renesas.com. [210.160.252.173])
        by mx.google.com with ESMTP id m39si12465753plg.228.2017.10.12.10.03.41
        for <linux-mm@kvack.org>;
        Thu, 12 Oct 2017 10:03:42 -0700 (PDT)
From: Chris Brandt <Chris.Brandt@renesas.com>
Subject: RE: [PATCH v6 1/4] cramfs: direct memory access support
Date: Thu, 12 Oct 2017 17:03:37 +0000
Message-ID: <SG2PR06MB1165E92262CE88C704AE5ED48A4B0@SG2PR06MB1165.apcprd06.prod.outlook.com>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org>
 <20171012061613.28705-2-nicolas.pitre@linaro.org>
In-Reply-To: <20171012061613.28705-2-nicolas.pitre@linaro.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thursday, October 12, 2017, Nicolas Pitre wrote:
> Small embedded systems typically execute the kernel code in place (XIP)
> directly from flash to save on precious RAM usage. This adds the ability
> to consume filesystem data directly from flash to the cramfs filesystem
> as well. Cramfs is particularly well suited to this feature as it is
> very simple and its RAM usage is already very low, and with this feature
> it is possible to use it with no block device support and even lower RAM
> usage.
>=20
> This patch was inspired by a similar patch from Shane Nay dated 17 years
> ago that used to be very popular in embedded circles but never made it
> into mainline. This is a cleaned-up implementation that uses far fewer
> ifdef's and gets the actual memory location for the filesystem image
> via MTD at run time. In the context of small IoT deployments, this
> functionality has become relevant and useful again.
>=20
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> ---
>  fs/cramfs/Kconfig |  30 +++++++-
>  fs/cramfs/inode.c | 215 +++++++++++++++++++++++++++++++++++++++++++-----=
-
> -----

Works!

I first applied the MTD patch series from here:

http://patchwork.ozlabs.org/project/linux-mtd/list/?series=3D7504

Then this v6 patch series on top of it.

I created a mtd-rom/direct-mapped partition and was able to both mount afte=
r boot, and also boot as the rootfs.

Log from booting as rootfs:

[    1.586625] cramfs: checking physical address 0x1b000000 for linear cram=
fs image
[    1.594512] cramfs: linear cramfs image on mtd:rootfs_xipcramfs appears =
to be 15744 KB in size
[    1.603619] VFS: Mounted root (cramfs filesystem) readonly on device 31:=
1.


$ cat /proc/self/maps
00008000-000a1000 r-xp 1b005000 1f:01 18192      /bin/busybox
000a9000-000aa000 rw-p 00099000 1f:01 18192      /bin/busybox
000aa000-000ac000 rw-p 00000000 00:00 0          [heap]
b6e07000-b6ee0000 r-xp 00000000 1f:01 766540     /lib/libc-2.18-2013.10.so
b6ee0000-b6ee8000 ---p 000d9000 1f:01 766540     /lib/libc-2.18-2013.10.so
b6ee8000-b6eea000 r--p 000d9000 1f:01 766540     /lib/libc-2.18-2013.10.so
b6eea000-b6eeb000 rw-p 000db000 1f:01 766540     /lib/libc-2.18-2013.10.so
b6eeb000-b6eee000 rw-p 00000000 00:00 0
b6eee000-b6f05000 r-xp 00000000 1f:01 670372     /lib/ld-2.18-2013.10.so
b6f08000-b6f09000 rw-p 00000000 00:00 0
b6f0a000-b6f0c000 rw-p 00000000 00:00 0
b6f0c000-b6f0d000 r--p 00016000 1f:01 670372     /lib/ld-2.18-2013.10.so
b6f0d000-b6f0e000 rw-p 00017000 1f:01 670372     /lib/ld-2.18-2013.10.so
bedb0000-bedd1000 rw-p 00000000 00:00 0          [stack]
bedf4000-bedf5000 r-xp 00000000 00:00 0          [sigpage]
ffff0000-ffff1000 r-xp 00000000 00:00 0          [vectors]

So far, so good.

Thank you!


Tested-by: Chris Brandt <chris.brandt@renesas.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
