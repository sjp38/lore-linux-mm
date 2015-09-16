Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62DA06B027A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:57:23 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so215811365pac.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:57:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id gk11si31520258pbd.34.2015.09.16.10.49.09
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:09 -0700 (PDT)
Subject: [PATCH 16/26] x86, pkeys: dump PKRU with other kernel registers
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:08 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174908.2B86AE47@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


I'm a bit ambivalent about whether this is needed or not.

Protection Keys never affect kernel mappings.  But, they can
affect whether the kernel will fault when it touches a user
mapping.  But, the kernel doesn't touch user mappings without
some careful choreography and these accesses don't generally
result in oopses.

Should we dump out PKRU like this in our oopses?

---

 b/arch/x86/kernel/process_64.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps arch/x86/kernel/process_64.c
--- a/arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps	2015-09-16 10:48:18.424290612 -0700
+++ b/arch/x86/kernel/process_64.c	2015-09-16 10:48:18.427290748 -0700
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
