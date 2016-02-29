Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 936946B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:16 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so58399577wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:16 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 04/18] mm, aout: handle vm_brk failures
Date: Mon, 29 Feb 2016 14:26:43 +0100
Message-Id: <1456752417-9626-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>

From: Michal Hocko <mhocko@suse.com>

vm_brk is allowed to fail but load_aout_binary simply ignores the error
and happily continues. I haven't noticed any problem from that in real
life but later patches will make the failure more likely because
vm_brk will become killable (resp. mmap_sem for write waiting will become
killable) so we should be more careful now.

The error handling should be quite straightforward because there are
calls to vm_mmap which check the error properly already. The only
notable exception is set_brk which is called after beyond_if label.
But nothing indicates that we cannot move it above set_binfmt as the two
do not depend on each other and fail before we do set_binfmt and alter
reference counting.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/ia32/ia32_aout.c | 22 +++++++++++++++-------
 fs/binfmt_aout.c          |  9 +++++++--
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index ae6aad1d24f7..f5e737ff0022 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -116,13 +116,13 @@ static struct linux_binfmt aout_format = {
 	.min_coredump	= PAGE_SIZE
 };
 
-static void set_brk(unsigned long start, unsigned long end)
+static unsigned long set_brk(unsigned long start, unsigned long end)
 {
 	start = PAGE_ALIGN(start);
 	end = PAGE_ALIGN(end);
 	if (end <= start)
-		return;
-	vm_brk(start, end - start);
+		return start;
+	return vm_brk(start, end - start);
 }
 
 #ifdef CONFIG_COREDUMP
@@ -349,7 +349,10 @@ static int load_aout_binary(struct linux_binprm *bprm)
 #endif
 
 		if (!bprm->file->f_op->mmap || (fd_offset & ~PAGE_MASK) != 0) {
-			vm_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
+			error = vm_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
+			if (IS_ERR_VALUE(error))
+				return error;
+
 			read_code(bprm->file, N_TXTADDR(ex), fd_offset,
 					ex.a_text+ex.a_data);
 			goto beyond_if;
@@ -372,10 +375,13 @@ static int load_aout_binary(struct linux_binprm *bprm)
 		if (error != N_DATADDR(ex))
 			return error;
 	}
+
 beyond_if:
-	set_binfmt(&aout_format);
+	error = set_brk(current->mm->start_brk, current->mm->brk);
+	if (IS_ERR_VALUE(error))
+		return error;
 
-	set_brk(current->mm->start_brk, current->mm->brk);
+	set_binfmt(&aout_format);
 
 	current->mm->start_stack =
 		(unsigned long)create_aout_tables((char __user *)bprm->p, bprm);
@@ -434,7 +440,9 @@ static int load_aout_library(struct file *file)
 			error_time = jiffies;
 		}
 #endif
-		vm_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
+		retval = vm_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
+		if (IS_ERR_VALUE(retval))
+			goto out;
 
 		read_code(file, start_addr, N_TXTOFF(ex),
 			  ex.a_text + ex.a_data);
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index 4c556680fa74..5fb075f05706 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -297,7 +297,10 @@ static int load_aout_binary(struct linux_binprm * bprm)
 		}
 
 		if (!bprm->file->f_op->mmap||((fd_offset & ~PAGE_MASK) != 0)) {
-			vm_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
+			error = vm_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
+			if (IS_ERR_VALUE(error))
+				return error;
+
 			read_code(bprm->file, N_TXTADDR(ex), fd_offset,
 				  ex.a_text + ex.a_data);
 			goto beyond_if;
@@ -378,7 +381,9 @@ static int load_aout_library(struct file *file)
 			       "N_TXTOFF is not page aligned. Please convert library: %pD\n",
 			       file);
 		}
-		vm_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
+		retval = vm_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
+		if (IS_ERR_VALUE(retval))
+			goto out;
 		
 		read_code(file, start_addr, N_TXTOFF(ex),
 			  ex.a_text + ex.a_data);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
