Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 792956B026A
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:50 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z14so4290980wrb.12
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor5143063wrf.69.2017.11.21.10.26.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:49 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 09/10] S.A.R.A. WX Protection procattr interface
Date: Tue, 21 Nov 2017 19:26:11 +0100
Message-Id: <1511288772-19308-10-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

This allow threads to get current WX Protection flags for themselves or
for other threads (if they have CAP_MAC_ADMIN).
It also allow a thread to set itself flags to a stricter set of rules than
the current one.
Via a new wxprot flag (SARA_WXP_FORCE_WXORX) is it possible to ask the
kernel to rescan the memory and remove the VM_WRITE flag from any area
that is marked both writable and executable.
Protections that prevent the runtime creation of executable code
can be troublesome for all those programs that actually need to do it
e.g. programs shipping with a JIT compiler built-in.
This feature can be use to run the JIT compiler with few restrictions while
enforcing full WX Protection in the rest of the program.
To simplify access to this interface a CC0 licensed library is available
here: https://github.com/smeso/libsara

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 security/sara/wxprot.c | 150 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 150 insertions(+)

diff --git a/security/sara/wxprot.c b/security/sara/wxprot.c
index 68203f2..c14ad27 100644
--- a/security/sara/wxprot.c
+++ b/security/sara/wxprot.c
@@ -12,6 +12,7 @@
 #ifdef CONFIG_SECURITY_SARA_WXPROT
 
 #include <linux/binfmts.h>
+#include <linux/capability.h>
 #include <linux/cred.h>
 #include <linux/elf.h>
 #include <linux/kref.h>
@@ -39,6 +40,7 @@
 #define SARA_WXP_COMPLAIN	0x0010
 #define SARA_WXP_VERBOSE	0x0020
 #define SARA_WXP_MMAP		0x0040
+#define SARA_WXP_FORCE_WXORX	0x0080
 #define SARA_WXP_EMUTRAMP	0x0100
 #define SARA_WXP_TRANSFER	0x0200
 #define SARA_WXP_NONE		0x0000
@@ -487,6 +489,152 @@ static int sara_pagefault_handler(struct pt_regs *regs,
 }
 #endif
 
+static int sara_getprocattr(struct task_struct *p, char *name, char **value)
+{
+	int ret;
+	u16 flags;
+	char *buf;
+
+	ret = -EINVAL;
+	if (strcmp(name, "wxprot") != 0)
+		goto out;
+
+	ret = -EACCES;
+	if (unlikely(current != p &&
+		     !capable(CAP_MAC_ADMIN)))
+		goto out;
+
+	ret = -ENOMEM;
+	buf = kzalloc(8, GFP_KERNEL);
+	if (unlikely(buf == NULL))
+		goto out;
+
+	if (!sara_enabled || !wxprot_enabled) {
+		flags = 0x0;
+	} else {
+		rcu_read_lock();
+		flags = get_sara_wxp_flags(__task_cred(p));
+		rcu_read_unlock();
+	}
+
+	snprintf(buf, 8, "0x%04x\n", flags);
+	ret = strlen(buf);
+	*value = buf;
+
+out:
+	return ret;
+}
+
+static int sara_setprocattr(const char *name, void *value, size_t size)
+{
+	int ret;
+	struct vm_area_struct *vma;
+	struct cred *new = prepare_creds();
+	u16 cur_flags;
+	u16 req_flags;
+	char *buf = NULL;
+
+	ret = -EINVAL;
+	if (!sara_enabled || !wxprot_enabled)
+		goto error;
+	if (unlikely(new == NULL))
+		return -ENOMEM;
+	if (strcmp(name, "wxprot") != 0)
+		goto error;
+	if (unlikely(value == NULL || size == 0 || size > 7))
+		goto error;
+	ret = -ENOMEM;
+	buf = kmalloc(size+1, GFP_KERNEL);
+	if (unlikely(buf == NULL))
+		goto error;
+	buf[size] = '\0';
+	memcpy(buf, value, size);
+	ret = -EINVAL;
+	if (unlikely(strlen(buf) != size))
+		goto error;
+	if (unlikely(kstrtou16(buf, 0, &req_flags) != 0))
+		goto error;
+	/*
+	 * SARA_WXP_FORCE_WXORX is a procattr only flag with a special
+	 * meaning and it isn't recognized by are_flags_valid
+	 */
+	if (unlikely(!are_flags_valid(req_flags & ~SARA_WXP_FORCE_WXORX)))
+		goto error;
+	/*
+	 * Extra checks on requested flags:
+	 *   - SARA_WXP_FORCE_WXORX requires SARA_WXP_WXORX
+	 *   - SARA_WXP_MMAP can only be activated if the program
+	 *     has a relro section
+	 *   - COMPLAIN mode can only be requested if it was already
+	 *     on (procattr can only be used to make protection stricter)
+	 *   - EMUTRAMP can only be activated if it was already on or
+	 *     if MPROTECT and WXORX weren't already on (procattr can
+	 *     only be used to make protection stricter)
+	 *   - VERBOSITY request is ignored
+	 */
+	if (unlikely(req_flags & SARA_WXP_FORCE_WXORX &&
+		     !(req_flags & SARA_WXP_WXORX)))
+		goto error;
+	if (unlikely(!get_current_sara_relro_page_found() &&
+		     req_flags & SARA_WXP_MMAP))
+		goto error;
+	cur_flags = get_current_sara_wxp_flags();
+	if (unlikely((req_flags & SARA_WXP_COMPLAIN) &&
+		     !(cur_flags & SARA_WXP_COMPLAIN)))
+		goto error;
+	if (unlikely((req_flags & SARA_WXP_EMUTRAMP) &&
+		     !(cur_flags & SARA_WXP_EMUTRAMP) &&
+		     (cur_flags & (SARA_WXP_MPROTECT |
+				   SARA_WXP_WXORX))))
+		goto error;
+	if (cur_flags & SARA_WXP_VERBOSE)
+		req_flags |= SARA_WXP_VERBOSE;
+	else
+		req_flags &= ~SARA_WXP_VERBOSE;
+	/*
+	 * Except SARA_WXP_COMPLAIN and SARA_WXP_EMUTRAMP,
+	 * any other flag can't be removed (procattr can
+	 * only be used to make protection stricter).
+	 */
+	if (unlikely(cur_flags & (req_flags ^ cur_flags) &
+		     ~(SARA_WXP_COMPLAIN|SARA_WXP_EMUTRAMP)))
+		goto error;
+	ret = -EINTR;
+	/*
+	 * When SARA_WXP_FORCE_WXORX is on we traverse all the
+	 * memory and remove the write permission from any area
+	 * that is both writable and executable.
+	 */
+	if (req_flags & SARA_WXP_FORCE_WXORX) {
+		if (down_write_killable(&current->mm->mmap_sem))
+			goto error;
+		for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+			if (vma->vm_flags & VM_EXEC &&
+			    vma->vm_flags & VM_WRITE) {
+				vma->vm_flags &= ~VM_WRITE;
+				vma_set_page_prot(vma);
+				change_protection(vma,
+						  vma->vm_start,
+						  vma->vm_end,
+						  vma->vm_page_prot,
+						  0,
+						  0);
+			}
+		}
+		up_write(&current->mm->mmap_sem);
+	}
+	get_sara_wxp_flags(new) = req_flags & ~SARA_WXP_FORCE_WXORX;
+	commit_creds(new);
+	ret = size;
+	goto out;
+
+error:
+	abort_creds(new);
+out:
+	kfree(buf);
+	return ret;
+}
+
 static struct security_hook_list wxprot_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(bprm_set_creds, sara_bprm_set_creds),
 	LSM_HOOK_INIT(check_vmflags, sara_check_vmflags),
@@ -494,6 +642,8 @@ static int sara_pagefault_handler(struct pt_regs *regs,
 #ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
 	LSM_HOOK_INIT(pagefault_handler, sara_pagefault_handler),
 #endif
+	LSM_HOOK_INIT(getprocattr, sara_getprocattr),
+	LSM_HOOK_INIT(setprocattr, sara_setprocattr),
 };
 
 struct binary_config_header {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
