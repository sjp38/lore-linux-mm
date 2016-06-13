Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 461AD6B0271
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 15:46:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so34048086wmz.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:46:57 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id k4si265266wmg.70.2016.06.13.12.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 12:46:56 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id m124so17259662wme.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:46:56 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [RFC 08/18] limits: track RLIMIT_DATA actual max
Date: Mon, 13 Jun 2016 22:44:15 +0300
Message-Id: <1465847065-3577-9-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Mateusz Guzik <mguzik@redhat.com>, John Stultz <john.stultz@linaro.org>, Ben Segall <bsegall@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "open list:FILESYSTEMS VFS and infrastructure" <linux-fsdevel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum size of data VM, presented in /proc/self/limits.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 arch/x86/ia32/ia32_aout.c | 1 +
 fs/binfmt_aout.c          | 1 +
 fs/binfmt_flat.c          | 1 +
 kernel/sys.c              | 2 ++
 mm/mmap.c                 | 6 +++++-
 5 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index cb26f18..8a7d502 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -398,6 +398,7 @@ beyond_if:
 	regs->r8 = regs->r9 = regs->r10 = regs->r11 =
 	regs->r12 = regs->r13 = regs->r14 = regs->r15 = 0;
 	set_fs(USER_DS);
+	bump_limit(RLIMIT_DATA, ex.a_data + ex.a_bss);
 	return 0;
 }
 
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index ae1b540..86c6548 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -330,6 +330,7 @@ beyond_if:
 	regs->gp = ex.a_gpvalue;
 #endif
 	start_thread(regs, ex.a_entry, current->mm->start_stack);
+	bump_limit(RLIMIT_DATA, ex.a_data + ex.a_bss);
 	return 0;
 }
 
diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
index caf9e39..e309dad 100644
--- a/fs/binfmt_flat.c
+++ b/fs/binfmt_flat.c
@@ -792,6 +792,7 @@ static int load_flat_file(struct linux_binprm * bprm,
 			libinfo->lib_list[id].start_brk) +	/* start brk */
 			stack_len);
 
+	bump_limit(RLIMIT_DATA, data_len + bss_len);
 	return 0;
 err:
 	return ret;
diff --git a/kernel/sys.c b/kernel/sys.c
index 89d5be4..6629f6f 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1896,6 +1896,8 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
+	bump_limit(RLIMIT_DATA, mm->end_data - mm->start_data);
+
 	up_write(&mm->mmap_sem);
 	return 0;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index de2c176..61867de 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -228,6 +228,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 		goto out;
 
 set_brk:
+	bump_rlimit(RLIMIT_DATA, (brk - mm->start_brk) +
+		    (mm->end_data - mm->start_data));
 	mm->brk = brk;
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
 	up_write(&mm->mmap_sem);
@@ -2924,8 +2926,10 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->exec_vm += npages;
 	else if (is_stack_mapping(flags))
 		mm->stack_vm += npages;
-	else if (is_data_mapping(flags))
+	else if (is_data_mapping(flags)) {
 		mm->data_vm += npages;
+		bump_rlimit(RLIMIT_DATA, mm->data_vm << PAGE_SHIFT);
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
