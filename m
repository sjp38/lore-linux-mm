Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0946B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 10:24:51 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so322621wgh.26
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 07:24:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id wd7si26512418wjc.60.2014.07.03.07.24.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 07:24:50 -0700 (PDT)
Date: Thu, 3 Jul 2014 10:24:42 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [mmotm:master 289/396] undefined reference to
 `crypto_alloc_shash'
Message-ID: <20140703142442.GC21156@redhat.com>
References: <53b49bda.Alc8D1c/m4kIm3gZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53b49bda.Alc8D1c/m4kIm3gZ%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Thu, Jul 03, 2014 at 07:55:06AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   82b56f797fa200a5e9feac3a93cb6496909b9670
> commit: 025d75374c9c08274f60da5802381a8ef7490388 [289/396] kexec: load and relocate purgatory at kernel load time
> config: make ARCH=s390 allnoconfig
> 
> All error/warnings:
> 
>    kernel/built-in.o: In function `sys_kexec_file_load':
>    (.text+0x32314): undefined reference to `crypto_shash_final'
>    kernel/built-in.o: In function `sys_kexec_file_load':
>    (.text+0x32328): undefined reference to `crypto_shash_update'
>    kernel/built-in.o: In function `sys_kexec_file_load':
> >> (.text+0x32338): undefined reference to `crypto_alloc_shash'
> 

Hi,

I think following patch should fix this issue.

Thanks
Vivek

Subject: kexec: set CRYPTO=y and CRYPTO_SHA256=y for all arch supporting kexec

Generic kexec implementation now makes use of crypto API to calculate the
sha256 digest of loaded kernel segments (for new syscall kexec_file_load()).

That means one need to enforce that CRYPTO and CRYPTO_SHA256 are built in
for kexec to compile and for new syscall to work.

I created this dependency for x86 but forgot to do for other arches
supporting kexec. And ran into compilation failure reports from kbuild
test robot.

   kernel/built-in.o: In function `sys_kexec_file_load':
   (.text+0x32314): undefined reference to `crypto_shash_final'
   kernel/built-in.o: In function `sys_kexec_file_load':
   (.text+0x32328): undefined reference to `crypto_shash_update'
   kernel/built-in.o: In function `sys_kexec_file_load':
>> (.text+0x32338): undefined reference to `crypto_alloc_shash'

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
---
 arch/arm/Kconfig     |    2 ++
 arch/ia64/Kconfig    |    2 ++
 arch/m68k/Kconfig    |    2 ++
 arch/mips/Kconfig    |    2 ++
 arch/powerpc/Kconfig |    2 ++
 arch/s390/Kconfig    |    2 ++
 arch/sh/Kconfig      |    2 ++
 arch/tile/Kconfig    |    2 ++
 8 files changed, 16 insertions(+)

Index: linux-2.6/arch/s390/Kconfig
===================================================================
--- linux-2.6.orig/arch/s390/Kconfig	2014-07-03 09:32:29.866684834 -0400
+++ linux-2.6/arch/s390/Kconfig	2014-07-03 09:41:40.918646043 -0400
@@ -48,6 +48,8 @@ config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 
 config KEXEC
 	def_bool y
+	select CRYPTO
+	select CRYPTO_SHA256
 
 config AUDIT_ARCH
 	def_bool y
Index: linux-2.6/arch/powerpc/Kconfig
===================================================================
--- linux-2.6.orig/arch/powerpc/Kconfig	2014-07-03 09:32:29.866684834 -0400
+++ linux-2.6/arch/powerpc/Kconfig	2014-07-03 09:41:40.918646043 -0400
@@ -397,6 +397,8 @@ config PPC64_SUPPORTS_MEMORY_FAILURE
 config KEXEC
 	bool "kexec system call"
 	depends on (PPC_BOOK3S || FSL_BOOKE || (44x && !SMP))
+	select CRYPTO
+	select CRYPTO_SHA256
 	help
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot
Index: linux-2.6/arch/arm/Kconfig
===================================================================
--- linux-2.6.orig/arch/arm/Kconfig	2014-07-03 09:32:29.866684834 -0400
+++ linux-2.6/arch/arm/Kconfig	2014-07-03 09:41:40.919646043 -0400
@@ -2050,6 +2050,8 @@ config XIP_PHYS_ADDR
 config KEXEC
 	bool "Kexec system call (EXPERIMENTAL)"
 	depends on (!SMP || PM_SLEEP_SMP)
+	select CRYPTO
+	select CRYPTO_SHA256
 	help
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot
Index: linux-2.6/arch/m68k/Kconfig
===================================================================
--- linux-2.6.orig/arch/m68k/Kconfig	2014-07-03 09:32:29.866684834 -0400
+++ linux-2.6/arch/m68k/Kconfig	2014-07-03 09:41:40.919646043 -0400
@@ -91,6 +91,8 @@ config MMU_SUN3
 config KEXEC
 	bool "kexec system call"
 	depends on M68KCLASSIC
+	select CRYPTO
+	select CRYPTO_SHA256
 	help
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot
Index: linux-2.6/arch/ia64/Kconfig
===================================================================
--- linux-2.6.orig/arch/ia64/Kconfig	2014-06-24 15:56:04.045803541 -0400
+++ linux-2.6/arch/ia64/Kconfig	2014-07-03 09:51:00.615606643 -0400
@@ -547,6 +547,8 @@ source "drivers/sn/Kconfig"
 config KEXEC
 	bool "kexec system call"
 	depends on !IA64_HP_SIM && (!SMP || HOTPLUG_CPU)
+	select CRYPTO
+	select CRYPTO_SHA256
 	help
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot
Index: linux-2.6/arch/mips/Kconfig
===================================================================
--- linux-2.6.orig/arch/mips/Kconfig	2014-06-30 16:17:09.974221907 -0400
+++ linux-2.6/arch/mips/Kconfig	2014-07-03 09:54:49.371590540 -0400
@@ -2392,6 +2392,8 @@ source "kernel/Kconfig.preempt"
 
 config KEXEC
 	bool "Kexec system call"
+	select CRYPTO
+	select CRYPTO_SHA256
 	help
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot
Index: linux-2.6/arch/sh/Kconfig
===================================================================
--- linux-2.6.orig/arch/sh/Kconfig	2014-06-24 15:56:04.906803481 -0400
+++ linux-2.6/arch/sh/Kconfig	2014-07-03 09:59:31.849570655 -0400
@@ -596,6 +596,8 @@ source kernel/Kconfig.hz
 config KEXEC
 	bool "kexec system call (EXPERIMENTAL)"
 	depends on SUPERH32 && MMU
+	select CRYPTO
+	select CRYPTO_SHA256
 	help
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot
Index: linux-2.6/arch/tile/Kconfig
===================================================================
--- linux-2.6.orig/arch/tile/Kconfig	2014-06-24 15:56:05.086803468 -0400
+++ linux-2.6/arch/tile/Kconfig	2014-07-03 10:02:45.223557043 -0400
@@ -192,6 +192,8 @@ source "kernel/Kconfig.hz"
 
 config KEXEC
 	bool "kexec system call"
+	select CRYPTO
+	select CRYPTO_SHA256
 	---help---
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
