Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A60296B0257
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:34:02 -0500 (EST)
Received: by pacej9 with SMTP id ej9so94323650pac.2
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:02 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id ps2si14917466pbb.23.2015.11.19.14.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 14:33:56 -0800 (PST)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJMTVJY012933
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:55 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y9nywgawk-8
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:55 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 9d3b3f0a8f0d11e5b9600002c99293a0-495fa230 for <linux-mm@kvack.org>;	Thu, 19
 Nov 2015 14:33:53 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 7/8] userfaultfd: fault try one more time
Date: Thu, 19 Nov 2015 14:33:52 -0800
Message-ID: <07f86ce80ddfc38fbf8247287e5b6475b1cd436d.1447964595.git.shli@fb.com>
In-Reply-To: <cover.1447964595.git.shli@fb.com>
References: <cover.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

For a swapin memory write fault, fault handler already retry once to
read the page in. userfaultfd can't do the retry again and fail. Give
another retry for userfaultfd in such case. gup isn't fixed yet, so will
return -EBUSY.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 arch/alpha/mm/fault.c      | 8 +++++++-
 arch/arc/mm/fault.c        | 8 +++++++-
 arch/arm/mm/fault.c        | 8 +++++++-
 arch/arm64/mm/fault.c      | 8 +++++++-
 arch/avr32/mm/fault.c      | 8 +++++++-
 arch/cris/mm/fault.c       | 8 +++++++-
 arch/hexagon/mm/vm_fault.c | 8 +++++++-
 arch/ia64/mm/fault.c       | 8 +++++++-
 arch/m68k/mm/fault.c       | 8 +++++++-
 arch/metag/mm/fault.c      | 8 +++++++-
 arch/microblaze/mm/fault.c | 8 +++++++-
 arch/mips/mm/fault.c       | 8 +++++++-
 arch/mn10300/mm/fault.c    | 8 +++++++-
 arch/nios2/mm/fault.c      | 8 +++++++-
 arch/openrisc/mm/fault.c   | 8 +++++++-
 arch/parisc/mm/fault.c     | 8 +++++++-
 arch/powerpc/mm/fault.c    | 8 +++++++-
 arch/s390/mm/fault.c       | 9 ++++++++-
 arch/sh/mm/fault.c         | 8 +++++++-
 arch/sparc/mm/fault_32.c   | 8 +++++++-
 arch/sparc/mm/fault_64.c   | 8 +++++++-
 arch/tile/mm/fault.c       | 8 +++++++-
 arch/um/kernel/trap.c      | 8 +++++++-
 arch/unicore32/mm/fault.c  | 8 +++++++-
 arch/x86/mm/fault.c        | 9 ++++++++-
 arch/xtensa/mm/fault.c     | 8 +++++++-
 fs/userfaultfd.c           | 5 +++--
 include/linux/mm.h         | 3 ++-
 28 files changed, 189 insertions(+), 29 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 4a905bd..ba5de3e 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -88,7 +88,8 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	const struct exception_table_entry *fixup;
 	int fault, si_code = SEGV_MAPERR;
 	siginfo_t info;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
 	   (or is suppressed by the PALcode).  Support that for older CPUs
@@ -178,6 +179,11 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index af63f4a..7dc8f791 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -68,7 +68,8 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	siginfo_t info;
 	int fault, ret;
 	int write = regs->ecr_cause & ECR_C_PROTV_STORE;  /* ST/EX */
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	/*
 	 * We fault-in kernel-space virtual memory on-demand. The
@@ -168,6 +169,11 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 				goto retry;
 			}
 		}
+		if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+		    (fault & VM_FAULT_UFFD_RETRY)) {
+			flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+			goto retry;
+		}
 
 		/* Fault Handled Gracefully */
 		up_read(&mm->mmap_sem);
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index daafcf1..59c1f64 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -260,7 +260,8 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, sig, code;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	if (notify_page_fault(regs, fsr))
 		return 0;
@@ -342,6 +343,11 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 			goto retry;
 		}
 	}
+	if (!(fault & VM_FAULT_ERROR) && (flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 19211c4..d66dfbc 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -199,7 +199,8 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	struct mm_struct *mm;
 	int fault, sig, code;
 	unsigned long vm_flags = VM_READ | VM_WRITE | VM_EXEC;
-	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+				FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	tsk = current;
 	mm  = tsk->mm;
@@ -291,6 +292,11 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 			goto retry;
 		}
 	}
+	if ((mm_flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		mm_flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index c035339..d15f7ef 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -64,7 +64,8 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_regs *regs)
 	long signr;
 	int code;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	if (notify_page_fault(regs, ecr))
 		return;
@@ -166,6 +167,11 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_regs *regs)
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 3066d40..62dde48 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -58,7 +58,8 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	struct vm_area_struct * vma;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	D(printk(KERN_DEBUG
 		 "Page fault for %lX on %X at %lX, prot %d write %d\n",
@@ -201,6 +202,11 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 8704c93..9046ffd 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -53,7 +53,8 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	int si_code = SEGV_MAPERR;
 	int fault;
 	const struct exception_table_entry *fixup;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	/*
 	 * If we're in an interrupt or have no user context,
@@ -119,6 +120,11 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 				goto retry;
 			}
 		}
+		if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+		    (fault & VM_FAULT_UFFD_RETRY)) {
+			flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+			goto retry;
+		}
 
 		up_read(&mm->mmap_sem);
 		return;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 70b40d1..ca3008d 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -85,7 +85,8 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	struct siginfo si;
 	unsigned long mask;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	mask = ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
 		| (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WRITE_BIT));
@@ -198,6 +199,11 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 6a94cdd..ecaf9fb 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -72,7 +72,8 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	pr_debug("do page fault:\nregs->sr=%#x, regs->pc=%#lx, address=%#lx, %ld, %p\n",
 		regs->sr, regs->pc, address, error_code, mm ? mm->pgd : NULL);
@@ -177,6 +178,11 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return 0;
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
index f57edca..be053cf 100644
--- a/arch/metag/mm/fault.c
+++ b/arch/metag/mm/fault.c
@@ -53,7 +53,8 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct vm_area_struct *vma, *prev_vma;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	tsk = current;
 
@@ -165,6 +166,11 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return 0;
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 177dfc0..2121910 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -92,7 +92,8 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	int code = SEGV_MAPERR;
 	int is_write = error_code & ESR_S;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	regs->ear = address;
 	regs->esr = error_code;
@@ -249,6 +250,11 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 4b88fa0..f7cd73a 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -45,7 +45,8 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	const int field = sizeof(unsigned long) * 2;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	static DEFINE_RATELIMIT_STATE(ratelimit_state, 5 * HZ, 10);
 
@@ -191,6 +192,11 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 4a1d181..2ea4ec7 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -124,7 +124,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 	unsigned long page;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 #ifdef CONFIG_GDBSTUB
 	/* handle GDB stub causing a fault */
@@ -284,6 +285,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index b51878b..0166754 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -47,7 +47,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	struct mm_struct *mm = tsk->mm;
 	int code = SEGV_MAPERR;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	cause >>= 2;
 
@@ -171,6 +172,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 230ac20..e6049e4 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -54,7 +54,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct vm_area_struct *vma;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	tsk = current;
 
@@ -196,6 +197,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index a762864..8b98cb2 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -215,7 +215,8 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	if (!mm)
 		goto no_context;
 
-	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+		FAULT_FLAG_ALLOW_UFFD_RETRY;
 	if (user_mode(regs))
 		flags |= FAULT_FLAG_USER;
 
@@ -279,6 +280,11 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index a67c6d7..e84b4ef2 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -211,7 +211,8 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned long address,
 	enum ctx_state prev_state = exception_enter();
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 	int code = SEGV_MAPERR;
 	int is_write = 0;
 	int trap = TRAP(regs);
@@ -474,6 +475,11 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned long address,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	goto bail;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index ec1a30d..a5e34cb 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -405,7 +405,8 @@ static inline int do_exception(struct pt_regs *regs, int access)
 
 	address = trans_exc_code & __FAIL_ADDR_MASK;
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
-	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+		FAULT_FLAG_ALLOW_UFFD_RETRY;
 	if (user_mode(regs))
 		flags |= FAULT_FLAG_USER;
 	if (access == VM_WRITE || (trans_exc_code & store_indication) == 0x400)
@@ -498,6 +499,12 @@ static inline int do_exception(struct pt_regs *regs, int access)
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		down_read(&mm->mmap_sem);
+		goto retry;
+	}
 #ifdef CONFIG_PGSTE
 	if (gmap) {
 		address =  __gmap_link(gmap, current->thread.gmap_addr,
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 79d8276..a4b19cf 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -403,7 +403,8 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -515,6 +516,11 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 }
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index c399e7b..024b798 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -174,7 +174,8 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	unsigned long g2;
 	int from_user = !(regs->psr & PSR_PS);
 	int fault, code;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	if (text_fault)
 		address = regs->pc;
@@ -278,6 +279,11 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	return;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index dbabe57..453b975 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -287,7 +287,8 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 	unsigned int insn = 0;
 	int si_code, fault_code, fault;
 	unsigned long address, mm_rss;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	fault_code = get_thread_fault_code();
 
@@ -476,6 +477,11 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 	up_read(&mm->mmap_sem);
 
 	mm_rss = get_mm_rss(mm);
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 13eac59..39b2dce 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -278,7 +278,8 @@ static int handle_page_fault(struct pt_regs *regs,
 	if (!is_page_fault)
 		write = 1;
 
-	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+		FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	is_kernel_mode = !user_mode(regs);
 
@@ -466,6 +467,11 @@ static int handle_page_fault(struct pt_regs *regs,
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 #if CHIP_HAS_TILE_DMA()
 	/* If this was a DMA TLB fault, restart the DMA engine. */
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 98783dd..0bb4f3d 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -31,7 +31,8 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	pmd_t *pmd;
 	pte_t *pte;
 	int err = -EFAULT;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	*code_out = SEGV_MAPERR;
 
@@ -101,6 +102,11 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 				goto retry;
 			}
 		}
+		if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+		    (fault & VM_FAULT_UFFD_RETRY)) {
+			flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+			goto retry;
+		}
 
 		pgd = pgd_offset(mm, address);
 		pud = pud_offset(pgd, address);
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index afccef552..546e7dc 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -209,7 +209,8 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, sig, code;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -272,6 +273,11 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 			goto retry;
 		}
 	}
+	if (!(fault & VM_FAULT_ERROR) && (flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index eef44d9..4732f60 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1062,7 +1062,8 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, major = 0;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1251,6 +1252,12 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 			if (!fatal_signal_pending(tsk))
 				goto retry;
 		}
+		if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+		    (fault & VM_FAULT_UFFD_RETRY)) {
+			flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+			if (!fatal_signal_pending(tsk))
+				goto retry;
+		}
 
 		/* User mode? Just return to handle the fatal exception */
 		if (flags & FAULT_FLAG_USER)
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index c9784c1..b6c19ce 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -45,7 +45,8 @@ void do_page_fault(struct pt_regs *regs)
 
 	int is_write, is_exec;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
+			     FAULT_FLAG_ALLOW_UFFD_RETRY;
 
 	info.si_code = SEGV_MAPERR;
 
@@ -141,6 +142,11 @@ void do_page_fault(struct pt_regs *regs)
 			goto retry;
 		}
 	}
+	if ((flags & FAULT_FLAG_ALLOW_UFFD_RETRY) &&
+	    (fault & VM_FAULT_UFFD_RETRY)) {
+		flags &= ~FAULT_FLAG_ALLOW_UFFD_RETRY;
+		goto retry;
+	}
 
 	up_read(&mm->mmap_sem);
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index c79a3fd..bbf0ef2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -298,7 +298,8 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 * without first stopping userland access to the memory. For
 	 * VM_UFFD_MISSING userfaults this is enough for now.
 	 */
-	if (unlikely(!(flags & FAULT_FLAG_ALLOW_RETRY))) {
+	if (unlikely(!(flags & (FAULT_FLAG_ALLOW_RETRY |
+			FAULT_FLAG_ALLOW_UFFD_RETRY)))) {
 		/*
 		 * Validate the invariant that nowait must allow retry
 		 * to be sure not to return SIGBUS erroneously on
@@ -357,7 +358,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 		    !fatal_signal_pending(current)))) {
 		wake_up_poll(&ctx->fd_wqh, POLLIN);
 		schedule();
-		ret |= VM_FAULT_MAJOR;
+		ret |= VM_FAULT_MAJOR | VM_FAULT_UFFD_RETRY;
 	}
 
 	__set_current_state(TASK_RUNNING);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad77..b4c6e44 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -219,6 +219,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x20	/* Second try */
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
+#define FAULT_FLAG_ALLOW_UFFD_RETRY 0x80/* userfault retry */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
@@ -1027,7 +1028,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
 #define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
 #define VM_FAULT_SIGSEGV 0x0040
-
+#define VM_FAULT_UFFD_RETRY 0x0080
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
