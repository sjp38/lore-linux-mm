Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD1E6B0069
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id q127so1522545wmd.1
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor5121988wrb.7.2017.11.21.10.26.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:35 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 02/10] S.A.R.A. framework creation
Date: Tue, 21 Nov 2017 19:26:04 +0100
Message-Id: <1511288772-19308-3-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

Initial S.A.R.A. framework setup.
Creation of a simplified interface to securityfs API to store and retrieve
configurations and flags from user-space.
Creation of some generic functions and macros to handle concurrent access
to configurations, memory allocation and path resolution.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 include/linux/lsm_hooks.h          |   5 +
 security/Kconfig                   |   1 +
 security/Makefile                  |   2 +
 security/sara/Kconfig              |  40 +++
 security/sara/Makefile             |   3 +
 security/sara/include/sara.h       |  29 ++
 security/sara/include/securityfs.h |  59 ++++
 security/sara/include/utils.h      |  69 +++++
 security/sara/main.c               | 105 +++++++
 security/sara/securityfs.c         | 563 +++++++++++++++++++++++++++++++++++++
 security/sara/utils.c              | 151 ++++++++++
 security/security.c                |   1 +
 12 files changed, 1028 insertions(+)
 create mode 100644 security/sara/Kconfig
 create mode 100644 security/sara/Makefile
 create mode 100644 security/sara/include/sara.h
 create mode 100644 security/sara/include/securityfs.h
 create mode 100644 security/sara/include/utils.h
 create mode 100644 security/sara/main.c
 create mode 100644 security/sara/securityfs.c
 create mode 100644 security/sara/utils.c

diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 7161d8e..8298e75 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -2025,5 +2025,10 @@ static inline void __init yama_add_hooks(void) { }
 #else
 static inline void loadpin_add_hooks(void) { };
 #endif
+#ifdef CONFIG_SECURITY_SARA
+void __init sara_init(void);
+#else
+static inline void __init sara_init(void) { };
+#endif
 
 #endif /* ! __LINUX_LSM_HOOKS_H */
diff --git a/security/Kconfig b/security/Kconfig
index e8e4494..85d8a47 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -211,6 +211,7 @@ source security/tomoyo/Kconfig
 source security/apparmor/Kconfig
 source security/loadpin/Kconfig
 source security/yama/Kconfig
+source security/sara/Kconfig
 
 source security/integrity/Kconfig
 
diff --git a/security/Makefile b/security/Makefile
index 4d2d378..d1d3bfc 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -10,6 +10,7 @@ subdir-$(CONFIG_SECURITY_TOMOYO)        += tomoyo
 subdir-$(CONFIG_SECURITY_APPARMOR)	+= apparmor
 subdir-$(CONFIG_SECURITY_YAMA)		+= yama
 subdir-$(CONFIG_SECURITY_LOADPIN)	+= loadpin
+subdir-$(CONFIG_SECURITY_SARA)		+= sara
 
 # always enable default capabilities
 obj-y					+= commoncap.o
@@ -25,6 +26,7 @@ obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/
 obj-$(CONFIG_SECURITY_APPARMOR)		+= apparmor/
 obj-$(CONFIG_SECURITY_YAMA)		+= yama/
 obj-$(CONFIG_SECURITY_LOADPIN)		+= loadpin/
+obj-$(CONFIG_SECURITY_SARA)		+= sara/
 obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
 
 # Object integrity file lists
diff --git a/security/sara/Kconfig b/security/sara/Kconfig
new file mode 100644
index 0000000..0456220
--- /dev/null
+++ b/security/sara/Kconfig
@@ -0,0 +1,40 @@
+menuconfig SECURITY_SARA
+	bool "S.A.R.A."
+	depends on SECURITY
+	select SECURITYFS
+	default n
+	help
+	  This selects S.A.R.A. LSM which aims to collect heterogeneous
+	  security measures providing a common interface to manage them.
+	  This LSM will always be stacked with the selected primary LSM and
+	  other stacked LSMs.
+	  Further information can be found in
+	  Documentation/admin-guide/LSM/SARA.rst.
+
+	  If unsure, answer N.
+
+config SECURITY_SARA_DEFAULT_DISABLED
+	bool "S.A.R.A. will be disabled at boot."
+	depends on SECURITY_SARA
+	default n
+	help
+	  If you say Y here, S.A.R.A. will not be enabled at startup. You can
+	  override this option at boot time via "sara.enabled=[1|0]" kernel
+	  parameter or via user-space utilities.
+	  This option is useful for distro kernels.
+
+	  If unsure, answer N.
+
+config SECURITY_SARA_NO_RUNTIME_ENABLE
+	bool "S.A.R.A. can be turn on only at boot time."
+	depends on SECURITY_SARA_DEFAULT_DISABLED
+	default y
+	help
+	  By enabling this option it won't be possible to turn on S.A.R.A.
+	  at runtime via user-space utilities. However it can still be
+	  turned on at boot time via the "sara.enabled=1" kernel parameter.
+	  This option is functionally equivalent to "sara.enabled=0" kernel
+	  parameter. This option is useful for distro kernels.
+
+	  If unsure, answer Y.
+
diff --git a/security/sara/Makefile b/security/sara/Makefile
new file mode 100644
index 0000000..8acd291
--- /dev/null
+++ b/security/sara/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SECURITY_SARA) := sara.o
+
+sara-y := main.o securityfs.o utils.o
diff --git a/security/sara/include/sara.h b/security/sara/include/sara.h
new file mode 100644
index 0000000..1001a8a
--- /dev/null
+++ b/security/sara/include/sara.h
@@ -0,0 +1,29 @@
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
+#ifndef __SARA_H
+#define __SARA_H
+
+#include <linux/types.h>
+#include <uapi/linux/limits.h>
+
+#define SARA_VERSION 0
+#define SARA_PATH_MAX PATH_MAX
+
+#undef pr_fmt
+#define pr_fmt(fmt) "SARA: " fmt
+
+extern bool sara_config_locked __read_mostly;
+extern bool sara_enabled __read_mostly;
+
+void sara_init(void) __init;
+
+#endif /* __SARA_H */
diff --git a/security/sara/include/securityfs.h b/security/sara/include/securityfs.h
new file mode 100644
index 0000000..57e6306
--- /dev/null
+++ b/security/sara/include/securityfs.h
@@ -0,0 +1,59 @@
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
+#ifndef __SARA_SECURITYFS_H
+#define __SARA_SECURITYFS_H
+
+#include <linux/init.h>
+
+#define SARA_SUBTREE_NN_LEN 24
+#define SARA_CONFIG_HASH_LEN 20
+
+struct sara_secfs_node;
+
+int sara_secfs_init(void) __init;
+int sara_secfs_subtree_register(const char *subtree_name,
+				const struct sara_secfs_node *nodes,
+				size_t size) __init;
+
+enum sara_secfs_node_type {
+	SARA_SECFS_BOOL,
+	SARA_SECFS_READONLY_INT,
+	SARA_SECFS_CONFIG_LOAD,
+	SARA_SECFS_CONFIG_DUMP,
+	SARA_SECFS_CONFIG_HASH,
+};
+
+struct sara_secfs_node {
+	const enum sara_secfs_node_type type;
+	void *const data;
+	const size_t dir_contents_len;
+	const char name[SARA_SUBTREE_NN_LEN];
+};
+
+struct sara_secfs_fptrs {
+	int (*const load)(const char *, size_t);
+	ssize_t (*const dump)(char **);
+	int (*const hash)(char **);
+};
+
+struct sara_secfs_bool_flag {
+	const char notice_line[SARA_SUBTREE_NN_LEN];
+	bool *const flag;
+};
+
+#define DEFINE_SARA_SECFS_BOOL_FLAG(NAME, VAR)		\
+const struct sara_secfs_bool_flag NAME = {		\
+	.notice_line = #VAR,				\
+	.flag = &VAR,					\
+}
+
+#endif /* __SARA_SECURITYFS_H */
diff --git a/security/sara/include/utils.h b/security/sara/include/utils.h
new file mode 100644
index 0000000..166b9ed
--- /dev/null
+++ b/security/sara/include/utils.h
@@ -0,0 +1,69 @@
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
+#ifndef __SARA_UTILS_H
+#define __SARA_UTILS_H
+
+#include <linux/kref.h>
+#include <linux/rcupdate.h>
+#include <linux/spinlock.h>
+
+char *get_absolute_path(const struct path *spath, char **buf);
+char *get_current_path(char **buf);
+void *sara_kvmalloc(size_t size) __attribute__((malloc));
+void *sara_kvcalloc(size_t n, size_t size) __attribute__((malloc));
+
+static inline void release_entry(struct kref *ref)
+{
+	/* All work is done after the return from kref_put(). */
+}
+
+#define SARA_CONFIG_GET_RCU(DEST, CONFIG) do {	\
+	rcu_read_lock();			\
+	DEST = rcu_dereference(CONFIG);		\
+} while (0)
+
+#define SARA_CONFIG_PUT_RCU(DATA) do {		\
+	rcu_read_unlock();			\
+	DATA = NULL;				\
+} while (0)
+
+#define SARA_CONFIG_GET(DEST, CONFIG) do {				\
+	rcu_read_lock();						\
+	do {								\
+		DEST = rcu_dereference(CONFIG);				\
+	} while (DEST && !kref_get_unless_zero(&DEST->refcount));	\
+	rcu_read_unlock();						\
+} while (0)
+
+#define SARA_CONFIG_PUT(DATA, FREE) do {		\
+	if (kref_put(&DATA->refcount, release_entry)) {	\
+		synchronize_rcu();			\
+		FREE(DATA);				\
+	}						\
+	DATA = NULL;					\
+} while (0)
+
+#define SARA_CONFIG_REPLACE(CONFIG, NEW, FREE, LOCK) do {	\
+	typeof(NEW) tmp;					\
+	spin_lock(LOCK);					\
+	tmp = rcu_dereference_protected(CONFIG,			\
+					lockdep_is_held(LOCK));	\
+	rcu_assign_pointer(CONFIG, NEW);			\
+	if (kref_put(&tmp->refcount, release_entry)) {		\
+		spin_unlock(LOCK);				\
+		synchronize_rcu();				\
+		FREE(tmp);					\
+	} else							\
+		spin_unlock(LOCK);				\
+} while (0)
+
+#endif /* __SARA_UTILS_H */
diff --git a/security/sara/main.c b/security/sara/main.c
new file mode 100644
index 0000000..aaddd32
--- /dev/null
+++ b/security/sara/main.c
@@ -0,0 +1,105 @@
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
+#include <linux/bug.h>
+#include <linux/kernel.h>
+#include <linux/printk.h>
+#include <linux/module.h>
+
+#include "include/sara.h"
+#include "include/securityfs.h"
+
+static const int sara_version = SARA_VERSION;
+
+#ifdef CONFIG_SECURITY_SARA_NO_RUNTIME_ENABLE
+bool sara_config_locked __read_mostly = true;
+#else
+bool sara_config_locked __read_mostly;
+#endif
+
+#ifdef CONFIG_SECURITY_SARA_DEFAULT_DISABLED
+bool sara_enabled __read_mostly;
+#else
+bool sara_enabled __read_mostly = true;
+#endif
+
+static DEFINE_SARA_SECFS_BOOL_FLAG(sara_enabled_data, sara_enabled);
+static DEFINE_SARA_SECFS_BOOL_FLAG(sara_config_locked_data, sara_config_locked);
+
+static int param_set_senabled(const char *val, const struct kernel_param *kp)
+{
+	if (!val)
+		return 0;
+	if (strtobool(val, kp->arg))
+		return -EINVAL;
+	/* config must by locked when S.A.R.A. is disabled at boot
+	 * and unlocked when it's enabled
+	 */
+	sara_config_locked = !(*(bool *) kp->arg);
+	return 0;
+}
+
+static struct kernel_param_ops param_ops_senabled = {
+	.set = param_set_senabled,
+};
+
+#define param_check_senabled(name, p) __param_check(name, p, bool)
+
+module_param_named(enabled, sara_enabled, senabled, 0000);
+MODULE_PARM_DESC(enabled, "Disable or enable S.A.R.A. at boot time. If disabled this way S.A.R.A. can't be enabled again.");
+
+static const struct sara_secfs_node main_fs[] __initconst = {
+	{
+		.name = "enabled",
+		.type = SARA_SECFS_BOOL,
+		.data = (void *) &sara_enabled_data,
+	},
+	{
+		.name = "locked",
+		.type = SARA_SECFS_BOOL,
+		.data = (void *) &sara_config_locked_data,
+	},
+	{
+		.name = "version",
+		.type = SARA_SECFS_READONLY_INT,
+		.data = (int *) &sara_version,
+	},
+};
+
+void __init sara_init(void)
+{
+	if (!sara_enabled && sara_config_locked) {
+		pr_notice("permanently disabled.\n");
+		return;
+	}
+
+	pr_debug("initializing...\n");
+
+	if (sara_secfs_subtree_register("main",
+					main_fs,
+					ARRAY_SIZE(main_fs))) {
+		pr_crit("impossible to register main fs.\n");
+		goto error;
+	}
+
+	pr_debug("initialized.\n");
+
+	if (sara_enabled)
+		pr_info("enabled\n");
+	else
+		pr_notice("disabled\n");
+	return;
+
+error:
+	sara_enabled = false;
+	sara_config_locked = true;
+	pr_crit("permanently disabled.\n");
+}
diff --git a/security/sara/securityfs.c b/security/sara/securityfs.c
new file mode 100644
index 0000000..d2bbf96
--- /dev/null
+++ b/security/sara/securityfs.c
@@ -0,0 +1,563 @@
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
+#include <linux/capability.h>
+#include <linux/ctype.h>
+#include <linux/mm.h>
+#include <linux/printk.h>
+#include <linux/security.h>
+#include <linux/seq_file.h>
+#include <linux/spinlock.h>
+#include <linux/uaccess.h>
+
+#include "include/sara.h"
+#include "include/utils.h"
+#include "include/securityfs.h"
+
+#define __SARA_STR_HELPER(x) #x
+#define SARA_STR(x) __SARA_STR_HELPER(x)
+
+static struct dentry *fs_root;
+
+static inline bool check_config_write_access(void)
+{
+	if (unlikely(sara_config_locked)) {
+		pr_warn("config write access blocked.\n");
+		return false;
+	}
+	return true;
+}
+
+static bool check_config_access(const struct file *file)
+{
+	if (!capable(CAP_MAC_ADMIN))
+		return false;
+	if (file->f_flags & O_WRONLY || file->f_flags & O_RDWR)
+		if (unlikely(!check_config_write_access()))
+			return false;
+	return true;
+}
+
+static int file_flag_show(struct seq_file *seq, void *v)
+{
+	bool *flag = ((struct sara_secfs_bool_flag *)seq->private)->flag;
+
+	seq_printf(seq, "%d\n", *flag);
+	return 0;
+}
+
+static ssize_t file_flag_write(struct file *file,
+				const char __user *ubuf,
+				size_t buf_size,
+				loff_t *offset)
+{
+	struct sara_secfs_bool_flag *bool_flag =
+		((struct seq_file *) file->private_data)->private;
+	char kbuf[2] = {'A', '\n'};
+	bool nf;
+
+	if (unlikely(*offset != 0))
+		return -ESPIPE;
+
+	if (unlikely(buf_size != 1 && buf_size != 2))
+		return -EPERM;
+
+	if (unlikely(copy_from_user(kbuf, ubuf, buf_size)))
+		return -EFAULT;
+
+	if (unlikely(kbuf[1] != '\n'))
+		return -EPERM;
+
+	switch (kbuf[0]) {
+	case '0':
+		nf = false;
+		break;
+	case '1':
+		nf = true;
+		break;
+	default:
+		return -EPERM;
+	}
+
+	*bool_flag->flag = nf;
+
+	if (strlen(bool_flag->notice_line) > 0)
+		pr_notice("flag \"%s\" set to %d\n",
+			  bool_flag->notice_line,
+			  nf);
+
+	return buf_size;
+}
+
+static int file_flag_open(struct inode *inode, struct file *file)
+{
+	if (unlikely(!check_config_access(file)))
+		return -EACCES;
+	return single_open(file, file_flag_show, inode->i_private);
+}
+
+static const struct file_operations file_flag = {
+	.owner		= THIS_MODULE,
+	.open		= file_flag_open,
+	.write		= file_flag_write,
+	.read		= seq_read,
+	.release	= single_release,
+};
+
+static int file_readonly_int_show(struct seq_file *seq, void *v)
+{
+	int *flag = seq->private;
+
+	seq_printf(seq, "%d\n", *flag);
+	return 0;
+}
+
+static int file_readonly_int_open(struct inode *inode, struct file *file)
+{
+	if (unlikely(!check_config_access(file)))
+		return -EACCES;
+	return single_open(file, file_readonly_int_show, inode->i_private);
+}
+
+static const struct file_operations file_readonly_int = {
+	.owner		= THIS_MODULE,
+	.open		= file_readonly_int_open,
+	.read		= seq_read,
+	.release	= single_release,
+};
+
+static ssize_t file_config_loader_write(struct file *file,
+					const char __user *ubuf,
+					size_t buf_size,
+					loff_t *offset)
+{
+	const struct sara_secfs_fptrs *fptrs = file->private_data;
+	char *kbuf = NULL;
+	ssize_t ret;
+
+	ret = -ESPIPE;
+	if (unlikely(*offset != 0))
+		goto out;
+
+	ret = -ENOMEM;
+	kbuf = sara_kvmalloc(buf_size);
+	if (unlikely(kbuf == NULL))
+		goto out;
+
+	ret = -EFAULT;
+	if (unlikely(copy_from_user(kbuf, ubuf, buf_size)))
+		goto out;
+
+	ret = fptrs->load(kbuf, buf_size);
+
+	if (unlikely(ret))
+		goto out;
+
+	ret = buf_size;
+
+out:
+	kvfree(kbuf);
+	return ret;
+}
+
+static int file_config_loader_open(struct inode *inode, struct file *file)
+{
+	if (unlikely(!check_config_access(file)))
+		return -EACCES;
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static const struct file_operations file_config_loader = {
+	.owner		= THIS_MODULE,
+	.open		= file_config_loader_open,
+	.write		= file_config_loader_write,
+};
+
+static int file_config_show(struct seq_file *seq, void *v)
+{
+	const struct sara_secfs_fptrs *fptrs = seq->private;
+	char *buf = NULL;
+	ssize_t ret;
+
+	ret = fptrs->dump(&buf);
+	if (unlikely(ret <= 0))
+		goto out;
+	seq_write(seq, buf, ret);
+	kvfree(buf);
+	ret = 0;
+out:
+	return ret;
+}
+
+static int file_dumper_open(struct inode *inode, struct file *file)
+{
+	if (unlikely(!check_config_access(file)))
+		return -EACCES;
+	return single_open(file, file_config_show, inode->i_private);
+}
+
+static const struct file_operations file_config_dumper = {
+	.owner		= THIS_MODULE,
+	.open		= file_dumper_open,
+	.read		= seq_read,
+	.release	= single_release,
+};
+
+static int file_hash_show(struct seq_file *seq, void *v)
+{
+	const struct sara_secfs_fptrs *fptrs = seq->private;
+	char *buf = NULL;
+	int ret;
+
+	ret = fptrs->hash(&buf);
+	if (unlikely(ret))
+		goto out;
+	seq_printf(seq, "%" SARA_STR(SARA_CONFIG_HASH_LEN) "phN\n", buf);
+	kvfree(buf);
+	ret = 0;
+out:
+	return ret;
+}
+
+static int file_hash_open(struct inode *inode, struct file *file)
+{
+	if (unlikely(!check_config_access(file)))
+		return -EACCES;
+	return single_open(file, file_hash_show, inode->i_private);
+}
+
+static const struct file_operations file_hash = {
+	.owner		= THIS_MODULE,
+	.open		= file_hash_open,
+	.read		= seq_read,
+	.release	= single_release,
+};
+
+static int mk_dir(struct dentry *parent,
+		const char *dir_name,
+		struct dentry **dir_out)
+{
+	int ret = 0;
+
+	*dir_out = securityfs_create_dir(dir_name, parent);
+	if (IS_ERR(*dir_out)) {
+		ret = -PTR_ERR(*dir_out);
+		*dir_out = NULL;
+	}
+	return ret;
+}
+
+static int mk_bool_flag(struct dentry *parent,
+			const char *file_name,
+			struct dentry **dir_out,
+			void *flag)
+{
+	int ret = 0;
+
+	*dir_out = securityfs_create_file(file_name,
+					0600,
+					parent,
+					flag,
+					&file_flag);
+	if (IS_ERR(*dir_out)) {
+		ret = -PTR_ERR(*dir_out);
+		*dir_out = NULL;
+	}
+	return 0;
+}
+
+static int mk_readonly_int(struct dentry *parent,
+			const char *file_name,
+			struct dentry **dir_out,
+			void *readonly_int)
+{
+	int ret = 0;
+
+	*dir_out = securityfs_create_file(file_name,
+					0400,
+					parent,
+					readonly_int,
+					&file_readonly_int);
+	if (IS_ERR(*dir_out)) {
+		ret = -PTR_ERR(*dir_out);
+		*dir_out = NULL;
+	}
+	return 0;
+}
+
+static int mk_config_loader(struct dentry *parent,
+			const char *file_name,
+			struct dentry **dir_out,
+			void *fptrs)
+{
+	int ret = 0;
+
+	*dir_out = securityfs_create_file(file_name,
+					0200,
+					parent,
+					fptrs,
+					&file_config_loader);
+	if (IS_ERR(*dir_out)) {
+		ret = -PTR_ERR(*dir_out);
+		*dir_out = NULL;
+	}
+	return 0;
+}
+
+static int mk_config_dumper(struct dentry *parent,
+				const char *file_name,
+				struct dentry **dir_out,
+				void *fptrs)
+{
+	int ret = 0;
+
+	*dir_out = securityfs_create_file(file_name,
+					0400,
+					parent,
+					fptrs,
+					&file_config_dumper);
+	if (IS_ERR(*dir_out)) {
+		ret = -PTR_ERR(*dir_out);
+		*dir_out = NULL;
+	}
+	return 0;
+}
+
+static int mk_config_hash(struct dentry *parent,
+			const char *file_name,
+			struct dentry **dir_out,
+			void *fptrs)
+{
+	int ret = 0;
+
+	*dir_out = securityfs_create_file(file_name,
+					0400,
+					parent,
+					fptrs,
+					&file_hash);
+	if (IS_ERR(*dir_out)) {
+		ret = -PTR_ERR(*dir_out);
+		*dir_out = NULL;
+	}
+	return 0;
+}
+
+struct sara_secfs_subtree {
+	char name[SARA_SUBTREE_NN_LEN];
+	size_t size;
+	struct dentry **nodes;
+	const struct sara_secfs_node *nodes_description;
+	struct list_head subtree_list;
+};
+
+static LIST_HEAD(subtree_list);
+
+int __init sara_secfs_subtree_register(const char *subtree_name,
+				const struct sara_secfs_node *nodes,
+				size_t size)
+{
+	int ret;
+	struct sara_secfs_subtree *subtree = NULL;
+
+	ret = -EINVAL;
+	if (unlikely(size < 1))
+		goto error;
+	ret = -ENOMEM;
+	subtree = kmalloc(sizeof(*subtree), GFP_KERNEL);
+	if (unlikely(subtree == NULL))
+		goto error;
+	strncpy(subtree->name,
+		subtree_name,
+		sizeof(subtree->name));
+	subtree->name[sizeof(subtree->name)-1] = '\0';
+	subtree->size = size+1;
+	subtree->nodes = kcalloc(subtree->size,
+				sizeof(*subtree->nodes),
+				GFP_KERNEL);
+	if (unlikely(subtree->nodes == NULL))
+		goto error;
+	subtree->nodes_description = nodes;
+	INIT_LIST_HEAD(&subtree->subtree_list);
+	list_add(&subtree->subtree_list, &subtree_list);
+	return 0;
+
+error:
+	kfree(subtree);
+	pr_warn("SECFS: Impossible to register '%s' (%d).\n",
+		subtree_name, ret);
+	return ret;
+}
+
+static inline int __init create_node(enum sara_secfs_node_type type,
+					struct dentry *parent,
+					const char *name,
+					struct dentry **output,
+					void *data)
+{
+	switch (type) {
+	case SARA_SECFS_BOOL:
+		return mk_bool_flag(parent, name, output, data);
+	case SARA_SECFS_READONLY_INT:
+		return mk_readonly_int(parent, name, output, data);
+	case SARA_SECFS_CONFIG_LOAD:
+		return mk_config_loader(parent, name, output, data);
+	case SARA_SECFS_CONFIG_DUMP:
+		return mk_config_dumper(parent, name, output, data);
+	case SARA_SECFS_CONFIG_HASH:
+		return mk_config_hash(parent, name, output, data);
+	default:
+		return -EINVAL;
+	}
+}
+
+static void subtree_unplug(struct sara_secfs_subtree *subtree)
+{
+	int i;
+
+	for (i = 0; i < subtree->size; ++i) {
+		if (subtree->nodes[i] != NULL) {
+			securityfs_remove(subtree->nodes[i]);
+			subtree->nodes[i] = NULL;
+		}
+	}
+}
+
+static int __init subtree_plug(struct sara_secfs_subtree *subtree)
+{
+	int ret;
+	int i;
+	const struct sara_secfs_node *nodes = subtree->nodes_description;
+
+	ret = -EINVAL;
+	if (unlikely(fs_root == NULL))
+		goto out;
+	ret = mk_dir(fs_root,
+			subtree->name,
+			&subtree->nodes[subtree->size-1]);
+	if (unlikely(ret))
+		goto out_unplug;
+	for (i = 0; i < subtree->size-1; ++i) {
+		ret = create_node(nodes[i].type,
+				  subtree->nodes[subtree->size-1],
+				  nodes[i].name,
+				  &subtree->nodes[i],
+				  nodes[i].data);
+		if (unlikely(ret))
+			goto out_unplug;
+	}
+	return 0;
+
+out_unplug:
+	subtree_unplug(subtree);
+out:
+	pr_warn("SECFS: Impossible to plug '%s' (%d).\n", subtree->name, ret);
+	return ret;
+}
+
+static int __init subtree_plug_all(void)
+{
+	int ret;
+	struct list_head *position;
+	struct sara_secfs_subtree *subtree;
+
+	ret = -EINVAL;
+	if (unlikely(fs_root == NULL))
+		goto out;
+	ret = 0;
+	list_for_each(position, &subtree_list) {
+		subtree = list_entry(position,
+					struct sara_secfs_subtree,
+					subtree_list);
+		if (subtree->nodes[0] == NULL) {
+			ret = subtree_plug(subtree);
+			if (unlikely(ret))
+				goto out;
+		}
+	}
+out:
+	if (unlikely(ret))
+		pr_warn("SECFS: Impossible to plug subtrees (%d).\n", ret);
+	return ret;
+}
+
+static void __init subtree_free_all(bool unplug)
+{
+	struct list_head *position;
+	struct list_head *next;
+	struct sara_secfs_subtree *subtree;
+
+	list_for_each_safe(position, next, &subtree_list) {
+		subtree = list_entry(position,
+					struct sara_secfs_subtree,
+					subtree_list);
+		list_del(position);
+		if (unplug)
+			subtree_unplug(subtree);
+		kfree(subtree->nodes);
+		kfree(subtree);
+	}
+}
+
+static int mk_root(void)
+{
+	int ret = -1;
+
+	if (fs_root == NULL)
+		ret = mk_dir(NULL, "sara", &fs_root);
+	if (unlikely(ret || fs_root == NULL))
+		pr_warn("SECFS: Impossible to create root (%d).\n", ret);
+	return ret;
+}
+
+static inline void rm_root(void)
+{
+	if (likely(fs_root != NULL)) {
+		securityfs_remove(fs_root);
+		fs_root = NULL;
+	}
+}
+
+static inline void __init sara_secfs_destroy(void)
+{
+	subtree_free_all(true);
+	rm_root();
+}
+
+int __init sara_secfs_init(void)
+{
+	int ret;
+
+	if (!sara_enabled && sara_config_locked)
+		return 0;
+
+	fs_root = NULL;
+
+	ret = mk_root();
+	if (unlikely(ret))
+		goto error;
+
+	ret = subtree_plug_all();
+	if (unlikely(ret))
+		goto error;
+
+	subtree_free_all(false);
+
+	pr_debug("securityfs initilaized.\n");
+	return 0;
+
+error:
+	sara_secfs_destroy();
+	pr_crit("impossible to build securityfs.\n");
+	return ret;
+}
+
+fs_initcall(sara_secfs_init);
diff --git a/security/sara/utils.c b/security/sara/utils.c
new file mode 100644
index 0000000..9250b7b
--- /dev/null
+++ b/security/sara/utils.c
@@ -0,0 +1,151 @@
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
+#include <linux/dcache.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+
+#include "include/sara.h"
+#include "include/utils.h"
+
+/**
+ * get_absolute_path - return the absolute path for a struct path
+ * @spath: the struct path to report
+ * @buf: double pointer where the newly allocated buffer will be placed
+ *
+ * Returns a pointer into @buf or an error code.
+ *
+ * The caller MUST kvfree @buf when finished using it.
+ */
+char *get_absolute_path(const struct path *spath, char **buf)
+{
+	size_t size = 128;
+	char *work_buf = NULL;
+	char *path = NULL;
+
+	do {
+		kvfree(work_buf);
+		work_buf = NULL;
+		if (size > SARA_PATH_MAX) {
+			path = ERR_PTR(-ENAMETOOLONG);
+			goto error;
+		}
+		work_buf = sara_kvmalloc(size);
+		if (unlikely(work_buf == NULL)) {
+			path = ERR_PTR(-ENOMEM);
+			goto error;
+		}
+		path = d_absolute_path(spath, work_buf, size);
+		size *= 2;
+	} while (PTR_ERR(path) == -ENAMETOOLONG);
+	if (!IS_ERR(path))
+		goto out;
+
+error:
+	kvfree(work_buf);
+	work_buf = NULL;
+out:
+	*buf = work_buf;
+	return path;
+}
+
+/**
+ * get_current_path - return the absolute path for the exe_file
+ *		      in the current task_struct, falling back
+ *		      to the contents of the comm field.
+ * @buf: double pointer where the newly allocated buffer will be placed
+ *
+ * Returns a pointer into @buf or an error code.
+ *
+ * The caller MUST kvfree @buf when finished using it.
+ */
+char *get_current_path(char **buf)
+{
+	struct file *exe_file;
+	char *path = NULL;
+
+	exe_file = get_task_exe_file(current);
+	if (exe_file) {
+		path = get_absolute_path(&exe_file->f_path, buf);
+		fput(exe_file);
+	}
+	if (IS_ERR_OR_NULL(path)) {
+		*buf = kzalloc(sizeof(current->comm), GFP_KERNEL);
+		get_task_comm(*buf, current);
+		path = *buf;
+	}
+	return path;
+}
+
+/**
+ * sara_kvmalloc - do allocation preferring kmalloc but falling back to vmalloc
+ * @size: how many bytes of memory are required
+ *
+ * Return: allocated buffer or NULL if failed
+ *
+ * It is possible that ruleset being loaded from the user is larger than
+ * what can be allocated by kmalloc, in those cases fall back to vmalloc.
+ *
+ * Nearly identical copy of AppArmor's __aa_kvmalloc.
+ */
+void *__attribute__((malloc)) sara_kvmalloc(size_t size)
+{
+	void *buffer = NULL;
+
+	__might_sleep(__FILE__, __LINE__, 0);
+
+	if (size == 0)
+		return NULL;
+
+	/* do not attempt kmalloc if we need more than 16 pages at once */
+	if (size <= (16*PAGE_SIZE))
+		buffer = kmalloc(size, GFP_KERNEL | __GFP_NORETRY |
+				 __GFP_NOWARN);
+	if (!buffer)
+		buffer = vmalloc(size);
+
+	return buffer;
+}
+
+/**
+ * sara_kvcalloc - do allocation preferring kcalloc but falling back to vmalloc
+ * @size: number of object to allocate
+ * @size: how many bytes of memory are required per each object
+ *
+ * Return: allocated buffer or NULL if failed
+ *
+ * It is possible that ruleset being loaded from the user is larger than
+ * what can be allocated by kcalloc, in those cases fall back to vmalloc.
+ *
+ * Nearly identical copy of AppArmor's __aa_kvmalloc.
+ */
+void *__attribute__((malloc)) sara_kvcalloc(size_t n, size_t size)
+{
+	void *buffer = NULL;
+
+	__might_sleep(__FILE__, __LINE__, 0);
+
+	if (size == 0)
+		return NULL;
+
+	/* do not attempt kmalloc if we need more than 16 pages at once */
+	if (size <= (16*PAGE_SIZE))
+		buffer = kcalloc(n, size, GFP_KERNEL | __GFP_NORETRY |
+				 __GFP_NOWARN);
+	if (!buffer)
+		buffer = vzalloc(n*size);
+
+	return buffer;
+}
diff --git a/security/security.c b/security/security.c
index 1cd8526..b0562b6 100644
--- a/security/security.c
+++ b/security/security.c
@@ -74,6 +74,7 @@ int __init security_init(void)
 	capability_add_hooks();
 	yama_add_hooks();
 	loadpin_add_hooks();
+	sara_init();
 
 	/*
 	 * Load all the remaining security modules.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
