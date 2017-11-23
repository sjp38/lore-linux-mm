Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED7586B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:24:04 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d14so11524974wrg.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 23:24:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor6877607wrf.86.2017.11.22.23.24.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 23:24:03 -0800 (PST)
Date: Thu, 23 Nov 2017 08:23:59 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
Message-ID: <20171123072359.kyjqwp63ja2gpeek@gmail.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> Thanks, everyone for all the reviews thus far.  I hope I managed to
> address all the feedback given so far, except for the TODOs of
> course.  This is a pretty minor update compared to v1->v2.
> 
> These patches are all on this tip branch:
> 
> 	https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/log/?h=WIP.x86/mm

Note that on top of latest -tip the bzImage build fails with:

 arch/x86/boot/compressed/pagetable.o: In function `kernel_ident_mapping_init':
 pagetable.c:(.text+0x31b): undefined reference to `kaiser_enabled'
 arch/x86/boot/compressed/Makefile:109: recipe for target 'arch/x86/boot/compressed/vmlinux' failed

that's I think because the early boot code shares some code via 
kernel_ident_mapping_init() et al, and that code grew a new KAISER runtime 
variable which isn't present in the special early-boot environment.

I.e. something like the (totally untested) patch below should do the trick.

Thanks,

	Ingo

---
 arch/x86/boot/compressed/pagetable.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: tip/arch/x86/boot/compressed/pagetable.c
===================================================================
--- tip.orig/arch/x86/boot/compressed/pagetable.c
+++ tip/arch/x86/boot/compressed/pagetable.c
@@ -36,6 +36,12 @@
 /* Used by pgtable.h asm code to force instruction serialization. */
 unsigned long __force_order;
 
+/*
+ * We share the kernel_ident_mapping_init(), but the early boot version does not need
+ * the Kaiser-logic:
+ */
+int kaiser_enabled = 0;
+
 /* Used to track our page table allocation area. */
 struct alloc_pgt_data {
 	unsigned char *pgt_buf;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
