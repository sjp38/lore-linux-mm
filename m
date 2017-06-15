Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A54A6B0313
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 12:44:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b15so3801430wrb.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:39 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id f57si591192wrf.148.2017.06.15.09.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 09:44:37 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id x23so4289796wrb.0
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:36 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v2 5/9] S.A.R.A. WX Protection
Date: Thu, 15 Jun 2017 18:42:52 +0200
Message-Id: <1497544976-7856-6-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, x86@kernel.org, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

Introduction of S.A.R.A. WX Protection.
It aims to improve user-space programs security by applying:
- W^X enforcement
- W!->X (once writable never executable) mprotect restriction
- Executable MMAP prevention

All of the above features can be enabled or disabled both system wide
or on a per executable basis through the use of configuration.
W^X enforcement works by blocking any memory allocation or mprotect
invocation with both the WRITE and the EXEC flags enabled.
W!->X restriction works by preventing any mprotect invocation that makes
executable any page that is flagged VM_MAYWRITE.
This feature can be configured separately for stack, heap and other
allocations.
Executable MMAP prevention works by preventing any new executable
allocation after the dynamic libraries have been loaded. It works under the
assumption that, when the dynamic libraries have been finished loading, the
RELRO section will be marked read only.

Parts of WX Protection are inspired by some of the features available in
PaX.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 security/sara/Kconfig          |  75 +++++
 security/sara/Makefile         |   1 +
 security/sara/include/wxprot.h |  27 ++
 security/sara/main.c           |   6 +
 security/sara/wxprot.c         | 646 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 755 insertions(+)
 create mode 100644 security/sara/include/wxprot.h
 create mode 100644 security/sara/wxprot.c

diff --git a/security/sara/Kconfig b/security/sara/Kconfig
index 5b61020..6c74069 100644
--- a/security/sara/Kconfig
+++ b/security/sara/Kconfig
@@ -39,4 +39,79 @@ config SECURITY_SARA_NO_RUNTIME_ENABLE
 
 	  If unsure, answer Y.
 
+config SECURITY_SARA_WXPROT
+	bool "WX Protection: W^X and W!->X protections"
+	depends on SECURITY_SARA
+	default y
+	help
+	  WX Protection aims to improve user-space programs security by applying:
+	    - W^X memory restriction
+	    - W!->X (once writable never executable) mprotect restriction
+	    - Executable MMAP prevention
+	  See Documentation/security/SARA.rst. for further information.
+
+	  If unsure, answer Y.
+
+choice
+	prompt "Default action for W^X and W!->X protections"
+	depends on SECURITY_SARA
+	depends on SECURITY_SARA_WXPROT
+	default SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_COMPLAIN_VERBOSE
+
+        help
+	  Choose the default behaviour of WX Protection when no config
+	  rule matches or no rule is loaded.
+	  For further information on available flags and their meaning
+	  see Documentation/security/SARA.rst.
+
+	config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_COMPLAIN_VERBOSE
+		bool "Protections enabled but not enforced."
+		help
+		  All features enabled except "Executable MMAP prevention",
+		  verbose reporting, but no actual enforce: it just complains.
+		  Its numeric value is 0x3f, for more information see
+		  Documentation/security/SARA.rst.
+
+        config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE_VERBOSE
+		bool "Full protection, verbose."
+		help
+		  All features enabled except "Executable MMAP prevention".
+		  The enabled features will be enforced with verbose reporting.
+		  Its numeric value is 0x2f, for more information see
+		  Documentation/security/SARA.rst.
+
+        config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE
+		bool "Full protection, quiet."
+		help
+		  All features enabled except "Executable MMAP prevention".
+		  The enabled features will be enforced quietly.
+		  Its numeric value is 0xf, for more information see
+		  Documentation/security/SARA.rst.
+
+	config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_NONE
+		bool "No protection at all."
+		help
+		  All features disabled.
+		  Its numeric value is 0, for more information see
+		  Documentation/security/SARA.rst.
+endchoice
+
+config SECURITY_SARA_WXPROT_DISABLED
+	bool "WX protection will be disabled at boot."
+	depends on SECURITY_SARA_WXPROT
+	default n
+	help
+	  If you say Y here WX protection won't be enabled at startup. You can
+	  override this option via user-space utilities or at boot time via
+	  "sara_wxprot=[0|1]" kernel parameter.
+
+	  If unsure, answer N.
+
+config SECURITY_SARA_WXPROT_DEFAULT_FLAGS
+	hex
+	default "0x3f" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_COMPLAIN_VERBOSE
+	default "0x2f" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE_VERBOSE
+	default "0xf" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE
+	default "0" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_NONE
+
 endmenu
diff --git a/security/sara/Makefile b/security/sara/Makefile
index 14bf7a8..74a3338 100644
--- a/security/sara/Makefile
+++ b/security/sara/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_SECURITY_SARA) := sara.o
 
 sara-y := main.o securityfs.o utils.o sara_data.o
+sara-$(CONFIG_SECURITY_SARA_WXPROT) += wxprot.o
diff --git a/security/sara/include/wxprot.h b/security/sara/include/wxprot.h
new file mode 100644
index 0000000..23b8a7b
--- /dev/null
+++ b/security/sara/include/wxprot.h
@@ -0,0 +1,27 @@
+/*
+ * S.A.R.A. Linux Security Module
+ *
+ * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#ifndef __SARA_WXPROT_H
+#define __SARA_WXPROT_H
+
+#ifdef CONFIG_SECURITY_SARA_WXPROT
+
+#include <linux/init.h>
+int sara_wxprot_init(void) __init;
+
+#else /* CONFIG_SECURITY_SARA_WXPROT */
+inline int sara_wxprot_init(void)
+{
+	return 0;
+}
+#endif /* CONFIG_SECURITY_SARA_WXPROT */
+
+#endif /* __SARA_WXPROT_H */
diff --git a/security/sara/main.c b/security/sara/main.c
index 644ff6d..2512560 100644
--- a/security/sara/main.c
+++ b/security/sara/main.c
@@ -16,6 +16,7 @@
 #include "include/sara.h"
 #include "include/sara_data.h"
 #include "include/securityfs.h"
+#include "include/wxprot.h"
 
 static const int sara_version = SARA_VERSION;
 
@@ -86,6 +87,11 @@ void __init sara_init(void)
 		goto error;
 	}
 
+	if (sara_wxprot_init()) {
+		pr_crit("impossible to initialize WX protections.\n");
+		goto error;
+	}
+
 	pr_debug("initialized.\n");
 
 	if (sara_enabled)
diff --git a/security/sara/wxprot.c b/security/sara/wxprot.c
new file mode 100644
index 0000000..f9233a5
--- /dev/null
+++ b/security/sara/wxprot.c
@@ -0,0 +1,646 @@
+/*
+ * S.A.R.A. Linux Security Module
+ *
+ * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#ifdef CONFIG_SECURITY_SARA_WXPROT
+
+#include <linux/binfmts.h>
+#include <linux/cred.h>
+#include <linux/elf.h>
+#include <linux/kref.h>
+#include <linux/lsm_hooks.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/printk.h>
+#include <linux/ratelimit.h>
+#include <linux/spinlock.h>
+
+#include "include/sara.h"
+#include "include/sara_data.h"
+#include "include/utils.h"
+#include "include/securityfs.h"
+#include "include/wxprot.h"
+
+#define SARA_WXPROT_CONFIG_VERSION 0
+
+#define SARA_WXP_HEAP		0x0001
+#define SARA_WXP_STACK		0x0002
+#define SARA_WXP_OTHER		0x0004
+#define SARA_WXP_WXORX		0x0008
+#define SARA_WXP_COMPLAIN	0x0010
+#define SARA_WXP_VERBOSE	0x0020
+#define SARA_WXP_MMAP		0x0040
+#define SARA_WXP_TRANSFER	0x0200
+#define SARA_WXP_NONE		0x0000
+#define SARA_WXP_MPROTECT	(SARA_WXP_HEAP	| \
+				SARA_WXP_STACK	| \
+				SARA_WXP_OTHER)
+#define __SARA_WXP_ALL		(SARA_WXP_MPROTECT	| \
+				SARA_WXP_MMAP		| \
+				SARA_WXP_WXORX		| \
+				SARA_WXP_COMPLAIN	| \
+				SARA_WXP_VERBOSE)
+#define SARA_WXP_ALL		__SARA_WXP_ALL
+
+struct wxprot_rule {
+	char *path;
+	u16 flags;
+	bool exact;
+};
+
+struct wxprot_config_container {
+	u32 rules_size;
+	struct wxprot_rule *rules;
+	size_t buf_len;
+	struct kref refcount;
+	char hash[SARA_CONFIG_HASH_LEN];
+};
+
+static struct wxprot_config_container __rcu *wxprot_config;
+
+static const int wxprot_config_version = SARA_WXPROT_CONFIG_VERSION;
+static bool wxprot_enabled __read_mostly = true;
+static DEFINE_SPINLOCK(wxprot_config_lock);
+
+static u16 default_flags __ro_after_init =
+				CONFIG_SECURITY_SARA_WXPROT_DEFAULT_FLAGS;
+
+static const bool wxprot_emutramp;
+
+static void pr_wxp(char *msg)
+{
+	char *buf, *path;
+
+	path = get_current_path(&buf);
+	pr_notice_ratelimited("WXP: %s in '%s' (%d).\n",
+			      msg, path, current->pid);
+	kvfree(buf);
+}
+
+static bool are_flags_valid(u16 flags)
+{
+	flags &= ~SARA_WXP_TRANSFER;
+	if (unlikely((flags & SARA_WXP_ALL) != flags))
+		return false;
+	if (unlikely(flags & SARA_WXP_MPROTECT &&
+		     !(flags & SARA_WXP_WXORX)))
+		return false;
+	if (unlikely(flags & (SARA_WXP_COMPLAIN | SARA_WXP_VERBOSE) &&
+		     !(flags & (SARA_WXP_MPROTECT |
+				SARA_WXP_WXORX |
+				SARA_WXP_MMAP))))
+		return false;
+	return true;
+}
+
+static int __init sara_wxprot_enabled_setup(char *str)
+{
+	if (str[0] == '1' && str[1] == '\0')
+		wxprot_enabled = true;
+	else
+		wxprot_enabled = false;
+	return 1;
+}
+__setup("sara_wxprot=", sara_wxprot_enabled_setup);
+
+static int __init sara_wxprot_default_setup(char *str)
+{
+	u16 flags = default_flags;
+
+	if (kstrtou16(str, 0, &flags) != 0 || !are_flags_valid(flags))
+		return 1;
+	default_flags = flags;
+	return 1;
+}
+__setup("sara_wxprot_default_flags=", sara_wxprot_default_setup);
+
+
+/*
+ * MMAP exec restriction
+ */
+#define PT_GNU_RELRO (PT_LOOS + 0x474e552)
+
+union elfh {
+	struct elf32_hdr c32;
+	struct elf64_hdr c64;
+};
+
+union elfp {
+	struct elf32_phdr c32;
+	struct elf64_phdr c64;
+};
+
+#define find_relro_section(ELFH, ELFP, FILE, RELRO, FOUND) do {		\
+	unsigned long i;						\
+	int _tmp;							\
+	if (ELFH.e_type == ET_DYN || ELFH.e_type == ET_EXEC) {		\
+		for (i = 0; i < ELFH.e_phnum; ++i) {			\
+			_tmp = kernel_read(FILE,			\
+				ELFH.e_phoff + i*sizeof(ELFP),		\
+				(char *)&ELFP,				\
+				sizeof(ELFP));				\
+			if (_tmp != sizeof(ELFP))			\
+				break;					\
+			if (ELFP.p_type == PT_GNU_RELRO) {		\
+				RELRO = ELFP.p_offset >> PAGE_SHIFT;	\
+				FOUND = true;				\
+				break;					\
+			}						\
+		}							\
+	}								\
+} while (0)
+
+static int set_relro_page(struct linux_binprm *bprm)
+{
+	union elfh elf_h;
+	union elfp elf_p;
+	unsigned long relro_page = 0;
+	bool relro_page_found = false;
+	int ret;
+
+	ret = kernel_read(bprm->file, 0,
+			(char *)&elf_h,
+			sizeof(elf_h));
+	if (ret == sizeof(elf_h) &&
+	    strncmp(elf_h.c32.e_ident, ELFMAG, SELFMAG) == 0) {
+		if (elf_h.c32.e_ident[EI_CLASS] == ELFCLASS32) {
+			find_relro_section(elf_h.c32,
+					   elf_p.c32,
+					   bprm->file,
+					   relro_page,
+					   relro_page_found);
+		} else if (IS_ENABLED(CONFIG_X86_64) &&
+			   elf_h.c64.e_ident[EI_CLASS] == ELFCLASS64) {
+			find_relro_section(elf_h.c64,
+					   elf_p.c64,
+					   bprm->file,
+					   relro_page,
+					   relro_page_found);
+		}
+	}
+	get_sara_relro_page(bprm->cred) = relro_page;
+	get_sara_relro_page_found(bprm->cred) = relro_page_found;
+	if (relro_page_found)
+		return 0;
+	else
+		return 1;
+}
+
+static inline int is_relro_page(const struct vm_area_struct *vma)
+{
+	if (get_current_sara_relro_page_found() &&
+	    get_current_sara_relro_page() == vma->vm_pgoff)
+		return 1;
+	return 0;
+}
+
+/*
+ * LSM hooks
+ */
+static int sara_bprm_set_creds(struct linux_binprm *bprm)
+{
+	int i;
+	struct wxprot_config_container *c;
+	u16 sara_wxp_flags = default_flags;
+	char *buf = NULL;
+	char *path = NULL;
+
+	sara_wxp_flags = get_sara_wxp_flags(bprm->cred);
+	get_sara_mmap_blocked(bprm->cred) = false;
+	get_sara_relro_page_found(bprm->cred) = false;
+	get_sara_wxp_flags(bprm->cred) = SARA_WXP_NONE;
+
+	if (!sara_enabled || !wxprot_enabled)
+		return 0;
+
+	if (!(sara_wxp_flags & SARA_WXP_TRANSFER)) {
+		sara_wxp_flags = default_flags;
+		path = get_absolute_path(&bprm->file->f_path, &buf);
+		if (IS_ERR(path)) {
+			path = (char *) bprm->interp;
+			if (PTR_ERR(path) == -ENAMETOOLONG)
+				pr_warn_ratelimited("WXP: path too long for '%s'. Default flags will be used.\n",
+						path);
+			else
+				pr_warn_ratelimited("WXP: can't find path for '%s'. Default flags will be used.\n",
+						path);
+			goto skip_flags;
+		}
+		SARA_CONFIG_GET_RCU(c, wxprot_config);
+		for (i = 0; i < c->rules_size; ++i) {
+			if ((c->rules[i].exact &&
+			strcmp(c->rules[i].path, path) == 0) ||
+			(!c->rules[i].exact &&
+			strncmp(c->rules[i].path,
+				path,
+				strlen(c->rules[i].path)) == 0)) {
+				sara_wxp_flags = c->rules[i].flags;
+				/* most specific path always come first */
+				break;
+			}
+		}
+		SARA_CONFIG_PUT_RCU(c);
+	} else
+		path = (char *) bprm->interp;
+
+	if (sara_wxp_flags != default_flags &&
+	    sara_wxp_flags & SARA_WXP_VERBOSE)
+		pr_info_ratelimited("WXP: '%s' run with flags '0x%x'.\n",
+				    path, sara_wxp_flags);
+
+skip_flags:
+	if (set_relro_page(bprm)) {
+		if (sara_wxp_flags & SARA_WXP_VERBOSE &&
+		    sara_wxp_flags & SARA_WXP_MMAP)
+			pr_notice_ratelimited("WXP: failed to find RELRO section in '%s'.\n",
+					      path);
+		sara_wxp_flags &= ~SARA_WXP_MMAP;
+	}
+	kvfree(buf);
+	get_sara_wxp_flags(bprm->cred) = sara_wxp_flags;
+	return 0;
+}
+
+static int sara_check_vmflags(vm_flags_t vm_flags)
+{
+	u16 sara_wxp_flags = get_current_sara_wxp_flags();
+
+	if (sara_enabled && wxprot_enabled) {
+		if (sara_wxp_flags & SARA_WXP_WXORX &&
+		    vm_flags & VM_WRITE &&
+		    vm_flags & VM_EXEC) {
+			if ((sara_wxp_flags & SARA_WXP_VERBOSE))
+				pr_wxp("W^X");
+			if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
+				return -EPERM;
+		}
+		if (sara_wxp_flags & SARA_WXP_MMAP &&
+		    (vm_flags & VM_EXEC ||
+		     (!(vm_flags & VM_MAYWRITE) && (vm_flags & VM_MAYEXEC))) &&
+		    get_current_sara_mmap_blocked()) {
+			if ((sara_wxp_flags & SARA_WXP_VERBOSE))
+				pr_wxp("executable mmap");
+			if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
+				return -EPERM;
+		}
+	}
+
+	return 0;
+}
+
+static int sara_file_mprotect(struct vm_area_struct *vma,
+				unsigned long reqprot,
+				unsigned long prot)
+{
+	u16 sara_wxp_flags = get_current_sara_wxp_flags();
+
+	if (!sara_enabled || !wxprot_enabled)
+		return 0;
+
+	if (sara_wxp_flags & SARA_WXP_MPROTECT &&
+	    prot & PROT_EXEC &&
+	    !(vma->vm_flags & VM_EXEC) &&
+	    vma->vm_flags & VM_MAYWRITE) {
+		if ((sara_wxp_flags & SARA_WXP_MPROTECT) == SARA_WXP_MPROTECT &&
+		    !(sara_wxp_flags & SARA_WXP_COMPLAIN) &&
+		    !(sara_wxp_flags & SARA_WXP_VERBOSE))
+			return -EACCES;
+		else if (vma->vm_file) {
+			if (sara_wxp_flags & SARA_WXP_OTHER) {
+				if ((sara_wxp_flags & SARA_WXP_VERBOSE))
+					pr_wxp("mprotect on file mmap");
+				if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
+					return -EACCES;
+			}
+		} else if (vma->vm_start >= vma->vm_mm->start_brk &&
+			vma->vm_end <= vma->vm_mm->brk) {
+			if (sara_wxp_flags & SARA_WXP_HEAP) {
+				if ((sara_wxp_flags & SARA_WXP_VERBOSE))
+					pr_wxp("mprotect on heap");
+				if (!(sara_wxp_flags &
+					SARA_WXP_COMPLAIN))
+					return -EACCES;
+			}
+		} else if ((vma->vm_start <= vma->vm_mm->start_stack &&
+			    vma->vm_end >= vma->vm_mm->start_stack) ||
+			   vma_is_stack_for_current(vma)) {
+			if (sara_wxp_flags & SARA_WXP_STACK) {
+				if ((sara_wxp_flags &
+					SARA_WXP_VERBOSE))
+					pr_wxp("mprotect on stack");
+				if (!(sara_wxp_flags &
+					SARA_WXP_COMPLAIN))
+					return -EACCES;
+			}
+		} else if (sara_wxp_flags & SARA_WXP_OTHER) {
+			if ((sara_wxp_flags & SARA_WXP_VERBOSE))
+				pr_wxp("mprotect on anon mmap");
+			if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
+				return -EACCES;
+		}
+	}
+
+	if (sara_wxp_flags & SARA_WXP_WXORX &&
+	    prot & PROT_EXEC &&
+	    prot & PROT_WRITE &&
+	    (!(vma->vm_flags & VM_EXEC) ||
+	     !(vma->vm_flags & VM_WRITE))) {
+		if ((sara_wxp_flags & SARA_WXP_VERBOSE))
+			pr_wxp("W^X");
+		if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
+			return -EACCES;
+	}
+
+	if (vma->vm_flags & VM_WRITE &&
+	    !(prot & PROT_WRITE) &&
+	    is_relro_page(vma))
+		get_current_sara_mmap_blocked() = true;
+
+	return 0;
+}
+
+static struct security_hook_list wxprot_hooks[] __ro_after_init = {
+	LSM_HOOK_INIT(bprm_set_creds, sara_bprm_set_creds),
+	LSM_HOOK_INIT(check_vmflags, sara_check_vmflags),
+	LSM_HOOK_INIT(file_mprotect, sara_file_mprotect),
+};
+
+struct binary_config_header {
+	char magic[8];
+	__le32 version;
+	__le32 rules_size;
+	char hash[SARA_CONFIG_HASH_LEN];
+} __packed;
+
+struct binary_config_rule {
+	__le16 path_len;
+	__le16 flags;
+	u8 exact;
+} __packed;
+
+static void config_free(struct wxprot_config_container *data)
+{
+	int i;
+
+	for (i = 0; i < data->rules_size; ++i)
+		kfree(data->rules[i].path);
+	kvfree(data->rules);
+	kfree(data);
+}
+
+static int config_load(const char *buf, size_t buf_len)
+{
+	int ret;
+	int i;
+	int path_len;
+	size_t inc;
+	size_t last_path_len = SARA_PATH_MAX;
+	bool last_exact = true;
+	const char *pos;
+	struct wxprot_config_container *new;
+	struct binary_config_header *h;
+	struct binary_config_rule *r;
+
+	ret = -EINVAL;
+	if (unlikely(buf_len < sizeof(*h)))
+		goto out;
+
+	h = (struct binary_config_header *) buf;
+	pos = buf + sizeof(*h);
+
+	ret = -EINVAL;
+	if (unlikely(memcmp(h->magic, "SARAWXPR", 8) != 0))
+		goto out;
+	if (unlikely(le32_to_cpu(h->version) != wxprot_config_version))
+		goto out;
+
+	ret = -ENOMEM;
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (unlikely(new == NULL))
+		goto out;
+	kref_init(&new->refcount);
+	new->rules_size = le32_to_cpu(h->rules_size);
+	BUILD_BUG_ON(sizeof(new->hash) != sizeof(h->hash));
+	memcpy(new->hash, h->hash, sizeof(new->hash));
+	if (unlikely(new->rules_size == 0)) {
+		new->rules = NULL;
+		goto replace;
+	}
+
+	ret = -ENOMEM;
+	new->rules = sara_kvcalloc(new->rules_size,
+				   sizeof(*new->rules));
+	if (unlikely(new->rules == NULL))
+		goto out_new;
+	for (i = 0; i < new->rules_size; ++i) {
+		r = (struct binary_config_rule *) pos;
+		pos += sizeof(*r);
+		inc = pos-buf;
+		path_len = le16_to_cpu(r->path_len);
+		new->rules[i].flags = le16_to_cpu(r->flags);
+		new->rules[i].exact = r->exact;
+
+		ret = -EINVAL;
+		if (unlikely(inc + path_len > buf_len))
+			goto out_rules;
+		if (unlikely(path_len > last_path_len))
+			goto out_rules;
+		if (unlikely((int) new->rules[i].exact != 0 &&
+			     (int) new->rules[i].exact != 1))
+			goto out_rules;
+		if (unlikely(path_len == last_path_len &&
+			     new->rules[i].exact &&
+			     !last_exact))
+			goto out_rules;
+		if (!are_flags_valid(new->rules[i].flags))
+			goto out_rules;
+
+		ret = -ENOMEM;
+		new->rules[i].path = kmalloc(path_len+1, GFP_KERNEL);
+		if (unlikely(new->rules[i].path == NULL))
+			goto out_rules;
+		memcpy(new->rules[i].path, pos, path_len);
+		new->rules[i].path[path_len] = '\0';
+		if (i > 0 &&
+		    unlikely(new->rules[i].exact == new->rules[i-1].exact &&
+			     strcmp(new->rules[i].path,
+				    new->rules[i-1].path) == 0))
+			goto out_rules;
+		pos += path_len;
+		last_path_len = path_len;
+		last_exact = new->rules[i].exact;
+	}
+	new->buf_len = (size_t) (pos-buf);
+
+replace:
+	SARA_CONFIG_REPLACE(wxprot_config,
+			    new,
+			    config_free,
+			    &wxprot_config_lock);
+	pr_notice("WXP: new rules loaded.\n");
+	return 0;
+
+out_rules:
+	for (i = 0; i < new->rules_size; ++i)
+		kfree(new->rules[i].path);
+	kvfree(new->rules);
+out_new:
+	kfree(new);
+out:
+	pr_notice("WXP: failed to load rules.\n");
+	return ret;
+}
+
+static ssize_t config_dump(char **buf)
+{
+	int i;
+	ssize_t ret;
+	size_t buf_len;
+	char *pos;
+	char *mybuf;
+	u16 path_len;
+	int rulen;
+	struct wxprot_config_container *c;
+	struct wxprot_rule *rc;
+	struct binary_config_header *h;
+	struct binary_config_rule *r;
+
+	ret = -ENOMEM;
+	SARA_CONFIG_GET(c, wxprot_config);
+	buf_len = c->buf_len;
+	mybuf = sara_kvmalloc(buf_len);
+	if (unlikely(mybuf == NULL))
+		goto out;
+	rulen = c->rules_size;
+	h = (struct binary_config_header *) mybuf;
+	memcpy(h->magic, "SARAWXPR", 8);
+	h->version = cpu_to_le32(SARA_WXPROT_CONFIG_VERSION);
+	h->rules_size = cpu_to_le32(rulen);
+	BUILD_BUG_ON(sizeof(c->hash) != sizeof(h->hash));
+	memcpy(h->hash, c->hash, sizeof(h->hash));
+	pos = mybuf + sizeof(*h);
+	for (i = 0; i < rulen; ++i) {
+		r = (struct binary_config_rule *) pos;
+		pos += sizeof(*r);
+		if (buf_len < (pos - mybuf))
+			goto out;
+		rc = &c->rules[i];
+		r->flags = cpu_to_le16(rc->flags);
+		r->exact = (u8) rc->exact;
+		path_len = strlen(rc->path);
+		r->path_len = cpu_to_le16(path_len);
+		if (buf_len < ((pos - mybuf) + path_len))
+			goto out;
+		memcpy(pos, rc->path, path_len);
+		pos += path_len;
+	}
+	ret = (ssize_t) (pos - mybuf);
+	*buf = mybuf;
+out:
+	SARA_CONFIG_PUT(c, config_free);
+	return ret;
+}
+
+static int config_hash(char **buf)
+{
+	int ret;
+	struct wxprot_config_container *config;
+
+	ret = -ENOMEM;
+	*buf = kzalloc(sizeof(config->hash), GFP_KERNEL);
+	if (unlikely(*buf == NULL))
+		goto out;
+
+	SARA_CONFIG_GET_RCU(config, wxprot_config);
+	memcpy(*buf, config->hash, sizeof(config->hash));
+	SARA_CONFIG_PUT_RCU(config);
+
+	ret = 0;
+out:
+	return ret;
+}
+
+static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_enabled_data,
+				   wxprot_enabled);
+
+static struct sara_secfs_fptrs fptrs __ro_after_init = {
+	.load = config_load,
+	.dump = config_dump,
+	.hash = config_hash,
+};
+
+static const struct sara_secfs_node wxprot_fs[] __initconst = {
+	{
+		.name = "enabled",
+		.type = SARA_SECFS_BOOL,
+		.data = (void *) &wxprot_enabled_data,
+	},
+	{
+		.name = "version",
+		.type = SARA_SECFS_READONLY_INT,
+		.data = (int *) &wxprot_config_version,
+	},
+	{
+		.name = "default_flags",
+		.type = SARA_SECFS_READONLY_INT,
+		.data = &default_flags,
+	},
+	{
+		.name = "emutramp_available",
+		.type = SARA_SECFS_READONLY_INT,
+		.data = (int *) &wxprot_emutramp,
+	},
+	{
+		.name = ".load",
+		.type = SARA_SECFS_CONFIG_LOAD,
+		.data = &fptrs,
+	},
+	{
+		.name = ".dump",
+		.type = SARA_SECFS_CONFIG_DUMP,
+		.data = &fptrs,
+	},
+	{
+		.name = "hash",
+		.type = SARA_SECFS_CONFIG_HASH,
+		.data = &fptrs,
+	},
+};
+
+
+int __init sara_wxprot_init(void)
+{
+	int ret;
+	struct wxprot_config_container *tmpc;
+
+	ret = -EINVAL;
+	if (!are_flags_valid(default_flags))
+		goto out_fail;
+	ret = -ENOMEM;
+	tmpc = kzalloc(sizeof(*tmpc), GFP_KERNEL);
+	if (unlikely(tmpc == NULL))
+		goto out_fail;
+	tmpc->buf_len = sizeof(struct binary_config_header);
+	kref_init(&tmpc->refcount);
+	wxprot_config = (struct wxprot_config_container __rcu *) tmpc;
+	ret = sara_secfs_subtree_register("wxprot",
+					  wxprot_fs,
+					  ARRAY_SIZE(wxprot_fs));
+	if (unlikely(ret))
+		goto out_fail;
+	security_add_hooks(wxprot_hooks, ARRAY_SIZE(wxprot_hooks), "sara");
+	return 0;
+
+out_fail:
+	kfree(tmpc);
+	return ret;
+}
+
+#endif /* CONFIG_SECURITY_SARA_WXPROT */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
