Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id DE1FC6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 18:19:17 -0500 (EST)
Received: by wmww144 with SMTP id w144so80059263wmw.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 15:19:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bv6si21604572wjc.97.2015.12.04.15.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 15:19:16 -0800 (PST)
Date: Fri, 4 Dec 2015 15:19:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 4174/4356] kernel/built-in.o:undefined
 reference to `mmap_rnd_bits'
Message-Id: <20151204151913.166e5cb795359ff1a53d26ac@linux-foundation.org>
In-Reply-To: <20151204151424.e73641da44c61f20f10d93e9@linux-foundation.org>
References: <201512050045.l2G9WhTi%fengguang.wu@intel.com>
	<20151204151424.e73641da44c61f20f10d93e9@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Daniel Cashman <dcashman@google.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 4 Dec 2015 15:14:24 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> There's also the matter of CONFIG_MMU=n.

ah, Arnd already fixed this one.  I guess I'll retain the patches
for now.



From: Arnd Bergmann <arnd@arndb.de>
Subject: ARM: avoid ARCH_MMAP_RND_BITS for NOMMU

ARM kernels with MMU disabled fail to build because of CONFIG_ARCH_MMAP_RND_BITS:

kernel/built-in.o:(.data+0x754): undefined reference to `mmap_rnd_bits'
kernel/built-in.o:(.data+0x76c): undefined reference to `mmap_rnd_bits_min'
kernel/built-in.o:(.data+0x770): undefined reference to `mmap_rnd_bits_max'

This changes the newly added line to only select this allow for
MMU-enabled kernels.

Fixes: 14570b3fd31a ("arm: mm: support ARCH_MMAP_RND_BITS")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Cashman <dcashman@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/arm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/arm/Kconfig~arm-mm-support-arch_mmap_rnd_bits-fix arch/arm/Kconfig
--- a/arch/arm/Kconfig~arm-mm-support-arch_mmap_rnd_bits-fix
+++ a/arch/arm/Kconfig
@@ -35,7 +35,7 @@ config ARM
 	select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32
 	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32
-	select HAVE_ARCH_MMAP_RND_BITS
+	select HAVE_ARCH_MMAP_RND_BITS if MMU
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_BPF_JIT
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
