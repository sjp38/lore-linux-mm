Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B7B27828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:34 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id o185so41179777pfb.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:34 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id l9si2100720pfi.44.2016.01.29.10.17.12
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:13 -0800 (PST)
Subject: [PATCH 21/31] x86, pkeys: dump PKRU with other kernel registers
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:12 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181712.EEDD7B1F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Protection Keys never affect kernel mappings.  But, they can
affect whether the kernel will fault when it touches a user
mapping.  The kernel doesn't touch user mappings without some
careful choreography and these accesses don't generally result in
oopses.  But, if one does, we definitely want to have PKRU
available so we can figure out if protection keys played a role.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/kernel/process_64.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps arch/x86/kernel/process_64.c
--- a/arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps	2016-01-28 15:52:25.978661494 -0800
+++ b/arch/x86/kernel/process_64.c	2016-01-28 15:52:25.981661632 -0800
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
