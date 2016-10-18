Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 607096B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 19:09:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g16so5512600wmg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 16:09:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ce6si51083898wjc.74.2016.10.18.16.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 16:09:58 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9IN8a2u006199
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 19:09:57 -0400
Received: from e24smtp02.br.ibm.com (e24smtp02.br.ibm.com [32.104.18.86])
	by mx0b-001b2d01.pphosted.com with ESMTP id 265r4x3ru1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 19:09:56 -0400
Received: from localhost
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Tue, 18 Oct 2016 21:09:54 -0200
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.18.232.225])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 79EAE352006C
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 19:09:25 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9IN9pIU33751286
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 21:09:51 -0200
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9IN9p4d029079
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 21:09:51 -0200
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [mmotm:master 121/157] arch/powerpc/kernel/module_64.c:463: undefined reference to `.elf64_apply_relocate_add'
Date: Tue, 18 Oct 2016 21:09:49 -0200
In-Reply-To: <201610152317.6eHiozx7%fengguang.wu@intel.com>
References: <201610152317.6eHiozx7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1526295.DW58yBHL0y@morokweng>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Am Samstag, 15. Oktober 2016, 23:14:20 BRST schrieb kbuild test robot:
>    arch/powerpc/kernel/built-in.o: In function `apply_relocate_add':
> >> arch/powerpc/kernel/module_64.c:463: undefined reference to
> >> `.elf64_apply_relocate_add'

This is because my kexec_file_load patches lost a few hunks.
The patch below fixes the issue.

Many of the problems with this patch series stem from the fact that it 
conflicted with the s/CONFIG_WORD_SIZE/BITS/ change that went into v4.9-rc1.
I will post a new version rebased on top of v4.9-rc1, this should get things 
back on track. I'll have them ready by tomorrow.

Thank you for your patience.

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 3bf8dc6ccf7d..6ff8927a8a05 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -108,8 +108,14 @@ pci64-$(CONFIG_PPC64)		+= pci_dn.o pci-hotplug.o isa-bridge.o
 obj-$(CONFIG_PCI)		+= pci_$(BITS).o $(pci64-y) \
 				   pci-common.o pci_of_scan.o
 obj-$(CONFIG_PCI_MSI)		+= msi.o
-obj-$(CONFIG_KEXEC)		+= machine_kexec.o crash.o \
+obj-$(CONFIG_KEXEC_CORE)	+= machine_kexec.o crash.o \
 				   machine_kexec_$(BITS).o
+obj-$(CONFIG_KEXEC_FILE)	+= kexec_elf_$(BITS).o
+
+ifeq ($(CONFIG_HAVE_IMA_KEXEC)$(CONFIG_IMA),yy)
+obj-y				+= ima_kexec.o
+endif
+
 obj-$(CONFIG_AUDIT)		+= audit.o
 obj64-$(CONFIG_AUDIT)		+= compat_audit.o
 
@@ -125,7 +131,7 @@ obj-y				+= iomap.o
 endif
 
 ifneq ($(CONFIG_MODULES)$(CONFIG_KEXEC_FILE),)
-ifeq ($(CONFIG_WORD_SIZE),64)
+ifeq ($(BITS),64)
 obj-y				+= elf_util.o elf_util_64.o
 endif
 endif
diff --git a/arch/powerpc/kernel/machine_kexec_64.c b/arch/powerpc/kernel/machine_kexec_64.c
index 8dbaf636c95e..86322f765b58 100644
--- a/arch/powerpc/kernel/machine_kexec_64.c
+++ b/arch/powerpc/kernel/machine_kexec_64.c
@@ -33,6 +33,16 @@
 #include <asm/smp.h>
 #include <asm/hw_breakpoint.h>
 #include <asm/asm-prototypes.h>
+#include <asm/kexec_elf_64.h>
+#include <asm/ima.h>
+
+#define SLAVE_CODE_SIZE		256
+
+#ifdef CONFIG_KEXEC_FILE
+static struct kexec_file_ops *kexec_file_loaders[] = {
+	&kexec_elf64_ops,
+};
+#endif
 
 int default_machine_kexec_prepare(struct kimage *image)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
