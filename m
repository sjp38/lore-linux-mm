Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFA2F6B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:23:20 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id n2so9324319pgs.0
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:23:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f89sor5071163plb.112.2018.01.09.12.23.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:23:19 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 2/3] exec: Introduce finalize_exec() before start_thread()
Date: Tue,  9 Jan 2018 12:23:02 -0800
Message-Id: <1515529383-35695-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1515529383-35695-1-git-send-email-keescook@chromium.org>
References: <1515529383-35695-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@redhat.com>, Greg KH <greg@kroah.com>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Provide a final call back into fs/exec.c before start_thread() takes
over, to handle any last-minute changes, like the coming restoration of
the stack limit.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/binfmt_aout.c        | 1 +
 fs/binfmt_elf.c         | 1 +
 fs/binfmt_elf_fdpic.c   | 1 +
 fs/binfmt_flat.c        | 1 +
 fs/exec.c               | 6 ++++++
 include/linux/binfmts.h | 1 +
 6 files changed, 11 insertions(+)

diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index ce1824f47ba6..c3deb2e35f20 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -330,6 +330,7 @@ static int load_aout_binary(struct linux_binprm * bprm)
 #ifdef __alpha__
 	regs->gp = ex.a_gpvalue;
 #endif
+	finalize_exec(bprm);
 	start_thread(regs, ex.a_entry, current->mm->start_stack);
 	return 0;
 }
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 83732fef510d..b9055ff1c70e 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1155,6 +1155,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
 	ELF_PLAT_INIT(regs, reloc_func_desc);
 #endif
 
+	finalize_exec(bprm);
 	start_thread(regs, elf_entry, bprm->p);
 	retval = 0;
 out:
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 429326b6e2e7..d90993adeffa 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -463,6 +463,7 @@ static int load_elf_fdpic_binary(struct linux_binprm *bprm)
 			    dynaddr);
 #endif
 
+	finalize_exec(bprm);
 	/* everything is now ready... get the userspace context ready to roll */
 	entryaddr = interp_params.entry_addr ?: exec_params.entry_addr;
 	start_thread(regs, entryaddr, current->mm->start_stack);
diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
index 5d6b94475f27..82a48e830018 100644
--- a/fs/binfmt_flat.c
+++ b/fs/binfmt_flat.c
@@ -994,6 +994,7 @@ static int load_flat_binary(struct linux_binprm *bprm)
 	FLAT_PLAT_INIT(regs);
 #endif
 
+	finalize_exec(bprm);
 	pr_debug("start_thread(regs=0x%p, entry=0x%lx, start_stack=0x%lx)\n",
 		 regs, start_addr, current->mm->start_stack);
 	start_thread(regs, start_addr, current->mm->start_stack);
diff --git a/fs/exec.c b/fs/exec.c
index 7074913ad2e7..e4ae20ff6278 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1384,6 +1384,12 @@ void setup_new_exec(struct linux_binprm * bprm)
 }
 EXPORT_SYMBOL(setup_new_exec);
 
+/* Runs immediately before start_thread() takes over. */
+void finalize_exec(struct linux_binprm *bprm)
+{
+}
+EXPORT_SYMBOL(finalize_exec);
+
 /*
  * Prepare credentials and lock ->cred_guard_mutex.
  * install_exec_creds() commits the new creds and drops the lock.
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index b0abe21d6cc9..40e52afbb2b0 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -118,6 +118,7 @@ extern int __must_check remove_arg_zero(struct linux_binprm *);
 extern int search_binary_handler(struct linux_binprm *);
 extern int flush_old_exec(struct linux_binprm * bprm);
 extern void setup_new_exec(struct linux_binprm * bprm);
+extern void finalize_exec(struct linux_binprm *bprm);
 extern void would_dump(struct linux_binprm *, struct file *);
 
 extern int suid_dumpable;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
