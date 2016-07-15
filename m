Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3ADA96B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:37:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so12236236wme.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:20 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id fl9si57730wjb.87.2016.07.15.03.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 03:37:18 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id i5so1744043wmg.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:18 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [PATCH 04/14] resource limits: track highwater mark of VM data segment
Date: Fri, 15 Jul 2016 13:35:51 +0300
Message-Id: <1468578983-28229-5-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Ben Segall <bsegall@google.com>, Alex Thorlton <athorlton@sgi.com>, Mateusz Guzik <mguzik@redhat.com>, John Stultz <john.stultz@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "open list:FILESYSTEMS VFS and infrastructure" <linux-fsdevel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum size of data VM, to be able to configure
RLIMIT_DATA resource limits. The information is available
with taskstats and cgroupstats netlink socket.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 arch/x86/ia32/ia32_aout.c | 2 ++
 fs/binfmt_aout.c          | 2 ++
 fs/binfmt_flat.c          | 2 ++
 kernel/sys.c              | 3 +++
 mm/mmap.c                 | 7 ++++++-
 5 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index cb26f18..9236254 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -26,6 +26,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/perf_event.h>
+#include <linux/sched.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
@@ -398,6 +399,7 @@ beyond_if:
 	regs->r8 = regs->r9 = regs->r10 = regs->r11 =
 	regs->r12 = regs->r13 = regs->r14 = regs->r15 = 0;
 	set_fs(USER_DS);
+	update_resource_highwatermark(RLIMIT_DATA, ex.a_data + ex.a_bss);
 	return 0;
 }
 
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index ae1b540..49216f4 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -25,6 +25,7 @@
 #include <linux/init.h>
 #include <linux/coredump.h>
 #include <linux/slab.h>
+#include <linux/sched.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -330,6 +331,7 @@ beyond_if:
 	regs->gp = ex.a_gpvalue;
 #endif
 	start_thread(regs, ex.a_entry, current->mm->start_stack);
+	update_resource_highwatermark(RLIMIT_DATA, ex.a_data + ex.a_bss);
 	return 0;
 }
 
diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
index caf9e39..19c2212 100644
--- a/fs/binfmt_flat.c
+++ b/fs/binfmt_flat.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/flat.h>
 #include <linux/syscalls.h>
+#include <linux/sched.h>
 
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
@@ -792,6 +793,7 @@ static int load_flat_file(struct linux_binprm * bprm,
 			libinfo->lib_list[id].start_brk) +	/* start brk */
 			stack_len);
 
+	update_resource_highwatermark(RLIMIT_DATA, data_len + bss_len);
 	return 0;
 err:
 	return ret;
diff --git a/kernel/sys.c b/kernel/sys.c
index 89d5be4..d84c87e 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1896,6 +1896,9 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
+	update_resource_highwatermark(RLIMIT_DATA, mm->end_data -
+				      mm->start_data);
+
 	up_write(&mm->mmap_sem);
 	return 0;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index de2c176..0b10f56 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -228,6 +228,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 		goto out;
 
 set_brk:
+	update_resource_highwatermark(RLIMIT_DATA, (brk - mm->start_brk) +
+				      (mm->end_data - mm->start_data));
 	mm->brk = brk;
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
 	up_write(&mm->mmap_sem);
@@ -2924,8 +2926,11 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->exec_vm += npages;
 	else if (is_stack_mapping(flags))
 		mm->stack_vm += npages;
-	else if (is_data_mapping(flags))
+	else if (is_data_mapping(flags)) {
 		mm->data_vm += npages;
+		update_resource_highwatermark(RLIMIT_DATA,
+					      mm->data_vm << PAGE_SHIFT);
+	}
 }
 
 static int special_mapping_fault(struct vm_area_struct *vma,
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
