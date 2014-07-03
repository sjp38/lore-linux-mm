Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 804F96B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 10:29:51 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so2419689wib.9
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 07:29:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z2si35663922wjz.98.2014.07.03.07.29.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 07:29:43 -0700 (PDT)
Date: Thu, 3 Jul 2014 10:29:29 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [mmotm:master 298/396] kernel/kexec.c:2181: undefined reference
 to `crypto_alloc_shash'
Message-ID: <20140703142929.GD21156@redhat.com>
References: <53b4f07a.xCByfd0BkPuAXJCu%fengguang.wu@intel.com>
 <1404368018.14741.31.camel@joe-AO725>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404368018.14741.31.camel@joe-AO725>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Wed, Jul 02, 2014 at 11:13:38PM -0700, Joe Perches wrote:
> On Thu, 2014-07-03 at 13:56 +0800, kbuild test robot wrote:
> > Hi Joe,
> 
> Hi Fengguang.
> 
> > It's probably a bug fix that unveils the link errors.
> 
> I don't understand how the typedef removal matters here.
> Is this some sort of bisect false positive?
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   82b56f797fa200a5e9feac3a93cb6496909b9670
> > commit: f192fb3c695b607044d4476c822783a8ae10ce75 [298/396] sysctl-remove-now-unused-typedef-ctl_table-fix
> > config: make ARCH=arm prima2_defconfig
> > 
> > All error/warnings:
> > 
> >    kernel/built-in.o: In function `kexec_calculate_store_digests':
> > >> kernel/kexec.c:2181: undefined reference to `crypto_alloc_shash'
> > >> kernel/kexec.c:2223: undefined reference to `crypto_shash_update'
> > >> kernel/kexec.c:2238: undefined reference to `crypto_shash_update'
> > >> kernel/kexec.c:2253: undefined reference to `crypto_shash_final'

I think these errors are happening because of kexe changes. Now kexec
requires CRYPTO and CRYPTO_SHA256. I did the change for x86 but not
for other arches supporting kexec. Just now I sent a patch to fix
these errors.

Inlining same patch here again for reference. I think this patch
should fix it.

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

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
