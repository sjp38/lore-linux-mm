Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5432982F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:24:55 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so186220038pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:24:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fn6si30682154pab.148.2015.09.28.12.18.24
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:24 -0700 (PDT)
Subject: [PATCH 17/25] x86, pkeys: dump PKRU with other kernel registers
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:24 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191824.88E91D56@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

I'm a bit ambivalent about whether this is needed or not.

Protection Keys never affect kernel mappings.  But, they can
affect whether the kernel will fault when it touches a user
mapping.  But, the kernel doesn't touch user mappings without
some careful choreography and these accesses don't generally
result in oopses.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/kernel/process_64.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps arch/x86/kernel/process_64.c
--- a/arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps	2015-09-28 11:39:48.695307824 -0700
+++ b/arch/x86/kernel/process_64.c	2015-09-28 11:39:48.698307960 -0700
@@ -116,6 +116,8 @@ void __show_regs(struct pt_regs *regs, i
 	printk(KERN_DEFAULT "DR0: %016lx DR1: %016lx DR2: %016lx\n", d0, d1, d2);
 	printk(KERN_DEFAULT "DR3: %016lx DR6: %016lx DR7: %016lx\n", d3, d6, d7);
 
+	if (boot_cpu_has(X86_FEATURE_OSPKE))
+		printk(KERN_DEFAULT "PKRU: %08x\n", read_pkru());
 }
 
 void release_thread(struct task_struct *dead_task)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
