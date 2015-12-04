Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4325B82F6E
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:12 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so80178953pab.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:12 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 85si15475580pfn.11.2015.12.03.17.14.54
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:54 -0800 (PST)
Subject: [PATCH 21/34] x86, pkeys: dump PKRU with other kernel registers
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:53 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011453.007731D7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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
--- a/arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps	2015-12-03 16:21:27.874773264 -0800
+++ b/arch/x86/kernel/process_64.c	2015-12-03 16:21:27.877773400 -0800
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
