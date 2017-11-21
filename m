Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB8F86B025E
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:38 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r2so3666344wra.4
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n23sor5072769wra.8.2017.11.21.10.26.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:37 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 03/10] Creation of "check_vmflags" LSM hook
Date: Tue, 21 Nov 2017 19:26:05 +0100
Message-Id: <1511288772-19308-4-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

Creation of a new LSM hook to check if a given configuration of vmflags,
for a new memory allocation request, should be allowed or not.
It's placed in "do_mmap", "do_brk_flags", "__install_special_mapping"
and "setup_arg_pages".
When loading an ELF, this hook is also used to determine what to do
with an RWE PT_GNU_STACK header. This allows LSM to force the loader
to silently ignore executable stack markings, which is useful a thing to
do when trampoline emulation is available.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 fs/binfmt_elf.c           |  3 ++-
 fs/binfmt_elf_fdpic.c     |  3 ++-
 fs/exec.c                 |  4 ++++
 include/linux/lsm_hooks.h |  7 +++++++
 include/linux/security.h  |  6 ++++++
 mm/mmap.c                 | 13 +++++++++++++
 security/security.c       |  5 +++++
 7 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 83732fe..a935087 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -803,7 +803,8 @@ static int load_elf_binary(struct linux_binprm *bprm)
 	for (i = 0; i < loc->elf_ex.e_phnum; i++, elf_ppnt++)
 		switch (elf_ppnt->p_type) {
 		case PT_GNU_STACK:
-			if (elf_ppnt->p_flags & PF_X)
+			if (elf_ppnt->p_flags & PF_X &&
+			    !security_check_vmflags(VM_EXEC|VM_READ|VM_WRITE))
 				executable_stack = EXSTACK_ENABLE_X;
 			else
 				executable_stack = EXSTACK_DISABLE_X;
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 429326b..647dfae 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -167,7 +167,8 @@ static int elf_fdpic_fetch_phdrs(struct elf_fdpic_params *params,
 		if (phdr->p_type != PT_GNU_STACK)
 			continue;
 
-		if (phdr->p_flags & PF_X)
+		if (phdr->p_flags & PF_X &&
+		    !security_check_vmflags(VM_EXEC|VM_READ|VM_WRITE))
 			params->flags |= ELF_FDPIC_FLAG_EXEC_STACK;
 		else
 			params->flags |= ELF_FDPIC_FLAG_NOEXEC_STACK;
diff --git a/fs/exec.c b/fs/exec.c
index 1d6243d..ba5a4da 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -748,6 +748,10 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	vm_flags |= mm->def_flags;
 	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
 
+	ret = security_check_vmflags(vm_flags);
+	if (ret)
+		goto out_unlock;
+
 	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
 			vm_flags);
 	if (ret)
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 8298e75..8d7ccbd 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -484,6 +484,11 @@
  *	@reqprot contains the protection requested by the application.
  *	@prot contains the protection that will be applied by the kernel.
  *	Return 0 if permission is granted.
+ * @check_vmflags:
+ *	Check if the requested @vmflags are allowed.
+ *	@vmflags contains the requested vmflags.
+ *	Return 0 if the operation is allowed to continue otherwise return
+ *	the appropriate error code.
  * @file_lock:
  *	Check permission before performing file locking operations.
  *	Note: this hook mediates both flock and fcntl style locks.
@@ -1525,6 +1530,7 @@
 				unsigned long prot, unsigned long flags);
 	int (*file_mprotect)(struct vm_area_struct *vma, unsigned long reqprot,
 				unsigned long prot);
+	int (*check_vmflags)(vm_flags_t vmflags);
 	int (*file_lock)(struct file *file, unsigned int cmd);
 	int (*file_fcntl)(struct file *file, unsigned int cmd,
 				unsigned long arg);
@@ -1812,6 +1818,7 @@ struct security_hook_heads {
 	struct list_head mmap_addr;
 	struct list_head mmap_file;
 	struct list_head file_mprotect;
+	struct list_head check_vmflags;
 	struct list_head file_lock;
 	struct list_head file_fcntl;
 	struct list_head file_set_fowner;
diff --git a/include/linux/security.h b/include/linux/security.h
index 73f1ef6..ac16262 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -311,6 +311,7 @@ int security_mmap_file(struct file *file, unsigned long prot,
 int security_mmap_addr(unsigned long addr);
 int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
 			   unsigned long prot);
+int security_check_vmflags(vm_flags_t vmflags);
 int security_file_lock(struct file *file, unsigned int cmd);
 int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
 void security_file_set_fowner(struct file *file);
@@ -845,6 +846,11 @@ static inline int security_file_mprotect(struct vm_area_struct *vma,
 	return 0;
 }
 
+static inline int security_check_vmflags(vm_flags_t vmflags)
+{
+	return 0;
+}
+
 static inline int security_file_lock(struct file *file, unsigned int cmd)
 {
 	return 0;
diff --git a/mm/mmap.c b/mm/mmap.c
index 924839f..88d6953 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1326,6 +1326,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 {
 	struct mm_struct *mm = current->mm;
 	int pkey = 0;
+	int error;
 
 	*populate = 0;
 
@@ -1378,6 +1379,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	error = security_check_vmflags(vm_flags);
+	if (error)
+		return error;
+
 	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
 			return -EPERM;
@@ -2888,6 +2893,10 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 		return -EINVAL;
 	flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
 
+	error = security_check_vmflags(flags);
+	if (error)
+		return error;
+
 	error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
 	if (offset_in_page(error))
 		return error;
@@ -3284,6 +3293,10 @@ static struct vm_area_struct *__install_special_mapping(
 	int ret;
 	struct vm_area_struct *vma;
 
+	ret = security_check_vmflags(vm_flags);
+	if (ret)
+		return ERR_PTR(ret);
+
 	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (unlikely(vma == NULL))
 		return ERR_PTR(-ENOMEM);
diff --git a/security/security.c b/security/security.c
index b0562b6..0df8988 100644
--- a/security/security.c
+++ b/security/security.c
@@ -939,6 +939,11 @@ int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
 	return call_int_hook(file_mprotect, 0, vma, reqprot, prot);
 }
 
+int security_check_vmflags(vm_flags_t vmflags)
+{
+	return call_int_hook(check_vmflags, 0, vmflags);
+}
+
 int security_file_lock(struct file *file, unsigned int cmd)
 {
 	return call_int_hook(file_lock, 0, file, cmd);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
