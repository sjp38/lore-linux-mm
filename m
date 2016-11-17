Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA09A6B0369
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:53:16 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o1so1739142ito.7
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:53:16 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id d20si1904585iod.13.2016.11.17.14.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 14:53:15 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <87inrmavax.fsf_-_@xmission.com>
	<20161117204707.GB10421@1wt.eu>
	<CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw@mail.gmail.com>
	<20161117213258.GA10839@1wt.eu> <874m3522sy.fsf@xmission.com>
Date: Thu, 17 Nov 2016 16:50:35 -0600
In-Reply-To: <874m3522sy.fsf@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Nov 2016 15:51:09 -0600")
Message-ID: <87shqpzpok.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [REVIEW][PATCH 2/3] ptrace: Don't allow accessing an undumpable mm
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Kees Cook <keescook@chromium.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Andy Lutomirski <luto@amacapital.net>


It is the reasonable expectation that if an executable file is not
readable there will be no way for a user without special privileges to
read the file.  This is enforced in ptrace_attach but if ptrace
is already attached before exec there is no enforcement for read-only
executables.

As the only way to read such an mm is through access_process_vm
spin a variant called ptrace_access_vm that will fail if the
target process is not being ptraced by the current process, or
the current process did not have sufficient privileges when ptracing
began to read the target processes mm.

In the ptrace implementations replace access_process_vm by
ptrace_access_vm.  There remain several ptrace sites that still use
access_process_vm as they are reading the target executables
instructions (for kernel consumption) or register stacks.  As such it
does not appear necessary to add a permission check to those calls.

This bug has always existed in Linux.

Fixes: v1.0
Cc: stable@vger.kernel.org
Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 arch/alpha/kernel/ptrace.c         |  2 +-
 arch/blackfin/kernel/ptrace.c      |  4 ++--
 arch/cris/arch-v32/kernel/ptrace.c |  2 +-
 arch/ia64/kernel/ptrace.c          |  2 +-
 arch/mips/kernel/ptrace32.c        |  4 ++--
 arch/powerpc/kernel/ptrace32.c     |  4 ++--
 include/linux/mm.h                 |  2 ++
 include/linux/ptrace.h             |  3 +++
 kernel/ptrace.c                    | 41 ++++++++++++++++++++++++++++++++------
 mm/memory.c                        |  2 +-
 mm/nommu.c                         |  2 +-
 11 files changed, 51 insertions(+), 17 deletions(-)

diff --git a/arch/alpha/kernel/ptrace.c b/arch/alpha/kernel/ptrace.c
index d9ee81769899..619d8b4bc890 100644
--- a/arch/alpha/kernel/ptrace.c
+++ b/arch/alpha/kernel/ptrace.c
@@ -281,7 +281,7 @@ long arch_ptrace(struct task_struct *child, long request,
 	/* When I and D space are separate, these will need to be fixed.  */
 	case PTRACE_PEEKTEXT: /* read word at location addr. */
 	case PTRACE_PEEKDATA:
-		copied = access_process_vm(child, addr, &tmp, sizeof(tmp), 0);
+		copied = ptrace_access_vm(child, addr, &tmp, sizeof(tmp), 0);
 		ret = -EIO;
 		if (copied != sizeof(tmp))
 			break;
diff --git a/arch/blackfin/kernel/ptrace.c b/arch/blackfin/kernel/ptrace.c
index 8b8fe671b1a6..7d8ece6a93fb 100644
--- a/arch/blackfin/kernel/ptrace.c
+++ b/arch/blackfin/kernel/ptrace.c
@@ -270,7 +270,7 @@ long arch_ptrace(struct task_struct *child, long request,
 			switch (bfin_mem_access_type(addr, to_copy)) {
 			case BFIN_MEM_ACCESS_CORE:
 			case BFIN_MEM_ACCESS_CORE_ONLY:
-				copied = access_process_vm(child, addr, &tmp,
+				copied = ptrace_access_vm(child, addr, &tmp,
 				                           to_copy, 0);
 				if (copied)
 					break;
@@ -323,7 +323,7 @@ long arch_ptrace(struct task_struct *child, long request,
 			switch (bfin_mem_access_type(addr, to_copy)) {
 			case BFIN_MEM_ACCESS_CORE:
 			case BFIN_MEM_ACCESS_CORE_ONLY:
-				copied = access_process_vm(child, addr, &data,
+				copied = ptrace_access_vm(child, addr, &data,
 				                           to_copy, 1);
 				break;
 			case BFIN_MEM_ACCESS_DMA:
diff --git a/arch/cris/arch-v32/kernel/ptrace.c b/arch/cris/arch-v32/kernel/ptrace.c
index f085229cf870..04251c6cb5f9 100644
--- a/arch/cris/arch-v32/kernel/ptrace.c
+++ b/arch/cris/arch-v32/kernel/ptrace.c
@@ -147,7 +147,7 @@ long arch_ptrace(struct task_struct *child, long request,
 				/* The trampoline page is globally mapped, no page table to traverse.*/
 				tmp = *(unsigned long*)addr;
 			} else {
-				copied = access_process_vm(child, addr, &tmp, sizeof(tmp), 0);
+				copied = ptrace_access_vm(child, addr, &tmp, sizeof(tmp), 0);
 
 				if (copied != sizeof(tmp))
 					break;
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 6f54d511cc50..4c46672f3ac1 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1156,7 +1156,7 @@ arch_ptrace (struct task_struct *child, long request,
 	case PTRACE_PEEKTEXT:
 	case PTRACE_PEEKDATA:
 		/* read word at location addr */
-		if (access_process_vm(child, addr, &data, sizeof(data), 0)
+		if (ptrace_access_vm(child, addr, &data, sizeof(data), 0)
 		    != sizeof(data))
 			return -EIO;
 		/* ensure return value is not mistaken for error code */
diff --git a/arch/mips/kernel/ptrace32.c b/arch/mips/kernel/ptrace32.c
index 283b5a1967d1..114b577c5a51 100644
--- a/arch/mips/kernel/ptrace32.c
+++ b/arch/mips/kernel/ptrace32.c
@@ -69,7 +69,7 @@ long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
 		if (get_user(addrOthers, (u32 __user * __user *) (unsigned long) addr) != 0)
 			break;
 
-		copied = access_process_vm(child, (u64)addrOthers, &tmp,
+		copied = ptrace_access_vm(child, (u64)addrOthers, &tmp,
 				sizeof(tmp), 0);
 		if (copied != sizeof(tmp))
 			break;
@@ -178,7 +178,7 @@ long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
 		if (get_user(addrOthers, (u32 __user * __user *) (unsigned long) addr) != 0)
 			break;
 		ret = 0;
-		if (access_process_vm(child, (u64)addrOthers, &data,
+		if (ptrace_access_vm(child, (u64)addrOthers, &data,
 					sizeof(data), 1) == sizeof(data))
 			break;
 		ret = -EIO;
diff --git a/arch/powerpc/kernel/ptrace32.c b/arch/powerpc/kernel/ptrace32.c
index f52b7db327c8..2e4f01dc9d64 100644
--- a/arch/powerpc/kernel/ptrace32.c
+++ b/arch/powerpc/kernel/ptrace32.c
@@ -73,7 +73,7 @@ long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
 		if (get_user(addrOthers, (u32 __user * __user *)addr) != 0)
 			break;
 
-		copied = access_process_vm(child, (u64)addrOthers, &tmp,
+		copied = ptrace_access_vm(child, (u64)addrOthers, &tmp,
 				sizeof(tmp), 0);
 		if (copied != sizeof(tmp))
 			break;
@@ -178,7 +178,7 @@ long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
 		if (get_user(addrOthers, (u32 __user * __user *)addr) != 0)
 			break;
 		ret = 0;
-		if (access_process_vm(child, (u64)addrOthers, &tmp,
+		if (ptrace_access_vm(child, (u64)addrOthers, &tmp,
 					sizeof(tmp), 1) == sizeof(tmp))
 			break;
 		ret = -EIO;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e9caec6a51e9..f49727403cce 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1269,6 +1269,8 @@ static inline int fixup_user_fault(struct task_struct *tsk,
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, int write);
+extern int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+			      unsigned long addr, void *buf, int len, int write);
 
 long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		      unsigned long start, unsigned long nr_pages,
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index e13bfdf7f314..7ef2f2b0a02e 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -8,6 +8,9 @@
 #include <linux/pid_namespace.h>	/* For task_active_pid_ns.  */
 #include <uapi/linux/ptrace.h>
 
+extern int ptrace_access_vm(struct task_struct *tsk, unsigned long addr,
+			    void *buf, int len, int write);
+
 /*
  * Ptrace flags
  *
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 982505497680..20288a3b3796 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -27,6 +27,35 @@
 #include <linux/cn_proc.h>
 #include <linux/compat.h>
 
+/*
+ * Access another process' address space via ptrace.
+ * Source/target buffer must be kernel space,
+ * Do not walk the page table directly, use get_user_pages
+ */
+int ptrace_access_vm(struct task_struct *tsk, unsigned long addr,
+		     void *buf, int len, int write)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	mm = get_task_mm(tsk);
+	if (!mm)
+		return 0;
+
+	if (!tsk->ptrace ||
+	    (current != tsk->parent) ||
+	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
+	     !ptracer_capable(tsk, mm->user_ns))) {
+		mmput(mm);
+		return 0;
+	}
+
+	ret = __access_remote_vm(tsk, mm, addr, buf, len, write);
+	mmput(mm);
+
+	return ret;
+}
+
 
 /*
  * ptrace a task: make the debugger its new parent and
@@ -535,7 +564,7 @@ int ptrace_readdata(struct task_struct *tsk, unsigned long src, char __user *dst
 		int this_len, retval;
 
 		this_len = (len > sizeof(buf)) ? sizeof(buf) : len;
-		retval = access_process_vm(tsk, src, buf, this_len, 0);
+		retval = ptrace_access_vm(tsk, src, buf, this_len, 0);
 		if (!retval) {
 			if (copied)
 				break;
@@ -562,7 +591,7 @@ int ptrace_writedata(struct task_struct *tsk, char __user *src, unsigned long ds
 		this_len = (len > sizeof(buf)) ? sizeof(buf) : len;
 		if (copy_from_user(buf, src, this_len))
 			return -EFAULT;
-		retval = access_process_vm(tsk, dst, buf, this_len, 1);
+		retval = ptrace_access_vm(tsk, dst, buf, this_len, 1);
 		if (!retval) {
 			if (copied)
 				break;
@@ -1125,7 +1154,7 @@ int generic_ptrace_peekdata(struct task_struct *tsk, unsigned long addr,
 	unsigned long tmp;
 	int copied;
 
-	copied = access_process_vm(tsk, addr, &tmp, sizeof(tmp), 0);
+	copied = ptrace_access_vm(tsk, addr, &tmp, sizeof(tmp), 0);
 	if (copied != sizeof(tmp))
 		return -EIO;
 	return put_user(tmp, (unsigned long __user *)data);
@@ -1136,7 +1165,7 @@ int generic_ptrace_pokedata(struct task_struct *tsk, unsigned long addr,
 {
 	int copied;
 
-	copied = access_process_vm(tsk, addr, &data, sizeof(data), 1);
+	copied = ptrace_access_vm(tsk, addr, &data, sizeof(data), 1);
 	return (copied == sizeof(data)) ? 0 : -EIO;
 }
 
@@ -1153,7 +1182,7 @@ int compat_ptrace_request(struct task_struct *child, compat_long_t request,
 	switch (request) {
 	case PTRACE_PEEKTEXT:
 	case PTRACE_PEEKDATA:
-		ret = access_process_vm(child, addr, &word, sizeof(word), 0);
+		ret = ptrace_access_vm(child, addr, &word, sizeof(word), 0);
 		if (ret != sizeof(word))
 			ret = -EIO;
 		else
@@ -1162,7 +1191,7 @@ int compat_ptrace_request(struct task_struct *child, compat_long_t request,
 
 	case PTRACE_POKETEXT:
 	case PTRACE_POKEDATA:
-		ret = access_process_vm(child, addr, &data, sizeof(data), 1);
+		ret = ptrace_access_vm(child, addr, &data, sizeof(data), 1);
 		ret = (ret != sizeof(data) ? -EIO : 0);
 		break;
 
diff --git a/mm/memory.c b/mm/memory.c
index fc1987dfd8cc..87bed1520690 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3868,7 +3868,7 @@ EXPORT_SYMBOL_GPL(generic_access_phys);
  * Access another process' address space as given in mm.  If non-NULL, use the
  * given task for page fault accounting.
  */
-static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, int write)
 {
 	struct vm_area_struct *vma;
diff --git a/mm/nommu.c b/mm/nommu.c
index 95daf81a4855..281d5adda9ef 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1816,7 +1816,7 @@ void filemap_map_pages(struct fault_env *fe,
 }
 EXPORT_SYMBOL(filemap_map_pages);
 
-static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, int write)
 {
 	struct vm_area_struct *vma;
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
