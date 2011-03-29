Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 504728D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 06:40:14 -0400 (EDT)
Subject: Re: kmemleak for MIPS
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	 <AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	 <1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
Date: Tue, 29 Mar 2011 11:40:06 +0100
Message-ID: <1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin John <maxin.john@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-03-28 at 22:15 +0100, Maxin John wrote:
> > Just add "depends on MIPS" and give it a try.
> As per your suggestion, I have tried it in my qemu environment (MIPS malt=
a).
>=20
> With a minor modification in arch/mips/kernel/vmlinux.lds.S (added the
> symbol  _sdata ), I was able to add kmemleak support for MIPS.
>=20
> Output in MIPS (Malta):

You may want to disable the kmemleak testing to reduce the amount of
leaks reported.

> debian-mips:~# uname -a
> Linux debian-mips 2.6.38-08826-g1788c20-dirty #4 SMP Mon Mar 28
> 23:22:04 EEST 2011 mips GNU/Linux
> debian-mips:~# mount -t debugfs nodev /sys/kernel/debug/
> debian-mips:~# cat /sys/kernel/debug/kmemleak
> unreferenced object 0x8f95d000 (size 4096):
>   comm "swapper", pid 1, jiffies 4294937330 (age 467.240s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<80529644>] alloc_large_system_hash+0x2f8/0x410
>     [<8053864c>] udp_table_init+0x4c/0x158
>     [<80538774>] udp_init+0x1c/0x94
>     [<80538b34>] inet_init+0x184/0x2a0
>     [<80100584>] do_one_initcall+0x174/0x1e0
>     [<8051f348>] kernel_init+0xe4/0x174
>     [<80103d4c>] kernel_thread_helper+0x10/0x18
> unreferenced object 0x8f95e000 (size 4096):
>   comm "swapper", pid 1, jiffies 4294937330 (age 467.240s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<80529644>] alloc_large_system_hash+0x2f8/0x410
>     [<8053864c>] udp_table_init+0x4c/0x158
>     [<8053881c>] udplite4_register+0x24/0xa8
>     [<80538b3c>] inet_init+0x18c/0x2a0
>     [<80100584>] do_one_initcall+0x174/0x1e0
>     [<8051f348>] kernel_init+0xe4/0x174
>     [<80103d4c>] kernel_thread_helper+0x10/0x18

These are probably false positives. Since the pointer referring this
block (udp_table) is __read_mostly, is it possible that the
corresponding section gets placed outside the _sdata.._edata range?

diff --git a/arch/mips/include/asm/cache.h b/arch/mips/include/asm/cache.h
index 650ac9b..b4db69f 100644
--- a/arch/mips/include/asm/cache.h
+++ b/arch/mips/include/asm/cache.h
@@ -17,6 +17,6 @@
 #define SMP_CACHE_SHIFT=09=09L1_CACHE_SHIFT
 #define SMP_CACHE_BYTES=09=09L1_CACHE_BYTES
=20
-#define __read_mostly __attribute__((__section__(".data.read_mostly")))
+#define __read_mostly __attribute__((__section__(".data..read_mostly")))
=20
 #endif /* _ASM_CACHE_H */
diff --git a/arch/mips/kernel/vmlinux.lds.S b/arch/mips/kernel/vmlinux.lds.=
S
index 570607b..6f6d5d0 100644
--- a/arch/mips/kernel/vmlinux.lds.S
+++ b/arch/mips/kernel/vmlinux.lds.S
@@ -74,6 +74,7 @@ SECTIONS
 =09=09INIT_TASK_DATA(PAGE_SIZE)
 =09=09NOSAVE_DATA
 =09=09CACHELINE_ALIGNED_DATA(1 << CONFIG_MIPS_L1_CACHE_SHIFT)
+=09=09READ_MOSTLY_DATA(1 << CONFIG_MIPS_L1_CACHE_SHIFT)
 =09=09DATA_DATA
 =09=09CONSTRUCTORS
 =09}

> unreferenced object 0x8f072000 (size 4096):
>   comm "swapper", pid 1, jiffies 4294937680 (age 463.840s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<801ba3d8>] __kmalloc+0x130/0x180
>     [<805461bc>] flow_cache_cpu_prepare+0x50/0xa8
>     [<8053746c>] flow_cache_init_global+0x90/0x138
>     [<80100584>] do_one_initcall+0x174/0x1e0
>     [<8051f348>] kernel_init+0xe4/0x174
>     [<80103d4c>] kernel_thread_helper+0x10/0x18

Same here, flow_cachep pointer is __read_mostly.

--=20
Catalin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
