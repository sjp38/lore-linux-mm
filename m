Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 885986B025F
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 4so8349715wrt.8
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4sor5168624wrb.61.2017.11.21.10.26.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:39 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 04/10] S.A.R.A. cred blob management
Date: Tue, 21 Nov 2017 19:26:06 +0100
Message-Id: <1511288772-19308-5-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

Creation of the S.A.R.A. cred blob management "API".
In order to allow S.A.R.A. to be stackable with other LSMs, it doesn't use
the "security" field of struct cred, instead it uses an ad hoc field named
security_sara.
This solution is probably not acceptable for upstream, so this part will
be modified as soon as the LSM stackable cred blob management will be
available.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 include/linux/cred.h              |  3 ++
 security/sara/Makefile            |  2 +-
 security/sara/include/sara_data.h | 55 +++++++++++++++++++++++++++
 security/sara/main.c              |  6 +++
 security/sara/sara_data.c         | 79 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 144 insertions(+), 1 deletion(-)
 create mode 100644 security/sara/include/sara_data.h
 create mode 100644 security/sara/sara_data.c

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 099058e..b65b666 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -141,6 +141,9 @@ struct cred {
 #ifdef CONFIG_SECURITY
 	void		*security;	/* subjective LSM security */
 #endif
+#ifdef CONFIG_SECURITY_SARA
+	void		*security_sara;
+#endif
 	struct user_struct *user;	/* real user ID subscription */
 	struct user_namespace *user_ns; /* user_ns the caps and keyrings are relative to. */
 	struct group_info *group_info;	/* supplementary groups for euid/fsgid */
diff --git a/security/sara/Makefile b/security/sara/Makefile
index 8acd291..14bf7a8 100644
--- a/security/sara/Makefile
+++ b/security/sara/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SECURITY_SARA) := sara.o
 
-sara-y := main.o securityfs.o utils.o
+sara-y := main.o securityfs.o utils.o sara_data.o
diff --git a/security/sara/include/sara_data.h b/security/sara/include/sara_data.h
new file mode 100644
index 0000000..248f57b
--- /dev/null
+++ b/security/sara/include/sara_data.h
@@ -0,0 +1,55 @@
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
+#ifndef __SARA_DATA_H
+#define __SARA_DATA_H
+
+#include <linux/init.h>
+
+int sara_data_init(void) __init;
+
+#ifdef CONFIG_SECURITY_SARA_WXPROT
+
+struct sara_data {
+	unsigned long	relro_page;
+	struct file	*relro_file;
+	u16		wxp_flags;
+	u16		execve_flags;
+	bool		relro_page_found;
+	bool		mmap_blocked;
+};
+
+#define get_sara_data_leftvalue(X) ((X)->security_sara)
+#define get_sara_data(X) ((struct sara_data *) (X)->security_sara)
+#define get_current_sara_data() get_sara_data(current_cred())
+
+#define get_sara_wxp_flags(X) (get_sara_data((X))->wxp_flags)
+#define get_current_sara_wxp_flags() get_sara_wxp_flags(current_cred())
+
+#define get_sara_execve_flags(X) (get_sara_data((X))->execve_flags)
+#define get_current_sara_execve_flags() get_sara_execve_flags(current_cred())
+
+#define get_sara_relro_page(X) (get_sara_data((X))->relro_page)
+#define get_current_sara_relro_page() get_sara_relro_page(current_cred())
+
+#define get_sara_relro_file(X) (get_sara_data((X))->relro_file)
+#define get_current_sara_relro_file() get_sara_relro_file(current_cred())
+
+#define get_sara_relro_page_found(X) (get_sara_data((X))->relro_page_found)
+#define get_current_sara_relro_page_found() \
+	get_sara_relro_page_found(current_cred())
+
+#define get_sara_mmap_blocked(X) (get_sara_data((X))->mmap_blocked)
+#define get_current_sara_mmap_blocked() get_sara_mmap_blocked(current_cred())
+
+#endif
+
+#endif /* __SARA_H */
diff --git a/security/sara/main.c b/security/sara/main.c
index aaddd32..0fc1761 100644
--- a/security/sara/main.c
+++ b/security/sara/main.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 
 #include "include/sara.h"
+#include "include/sara_data.h"
 #include "include/securityfs.h"
 
 static const int sara_version = SARA_VERSION;
@@ -90,6 +91,11 @@ void __init sara_init(void)
 		goto error;
 	}
 
+	if (sara_data_init()) {
+		pr_crit("impossible to initialize creds.\n");
+		goto error;
+	}
+
 	pr_debug("initialized.\n");
 
 	if (sara_enabled)
diff --git a/security/sara/sara_data.c b/security/sara/sara_data.c
new file mode 100644
index 0000000..8f11cd1
--- /dev/null
+++ b/security/sara/sara_data.c
@@ -0,0 +1,79 @@
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
+#include "include/sara_data.h"
+
+#ifdef CONFIG_SECURITY_SARA_WXPROT
+#include <linux/cred.h>
+#include <linux/lsm_hooks.h>
+#include <linux/mm.h>
+
+static int sara_cred_alloc_blank(struct cred *cred, gfp_t gfp)
+{
+	struct sara_data *d;
+
+	d = kzalloc(sizeof(*d), gfp);
+	if (d == NULL)
+		return -ENOMEM;
+	get_sara_data_leftvalue(cred) = d;
+	return 0;
+}
+
+static void sara_cred_free(struct cred *cred)
+{
+	struct sara_data *d;
+
+	d = get_sara_data(cred);
+	if (d != NULL) {
+		kfree(d);
+		get_sara_data_leftvalue(cred) = NULL;
+	}
+}
+
+static int sara_cred_prepare(struct cred *new, const struct cred *old,
+			     gfp_t gfp)
+{
+	struct sara_data *d;
+
+	d = kmemdup(get_sara_data(old), sizeof(*d), gfp);
+	if (d == NULL)
+		return -ENOMEM;
+	get_sara_data_leftvalue(new) = d;
+	return 0;
+}
+
+static void sara_cred_transfer(struct cred *new, const struct cred *old)
+{
+	*get_sara_data(new) = *get_sara_data(old);
+}
+
+static struct security_hook_list data_hooks[] __ro_after_init = {
+	LSM_HOOK_INIT(cred_alloc_blank, sara_cred_alloc_blank),
+	LSM_HOOK_INIT(cred_free, sara_cred_free),
+	LSM_HOOK_INIT(cred_prepare, sara_cred_prepare),
+	LSM_HOOK_INIT(cred_transfer, sara_cred_transfer),
+};
+
+int __init sara_data_init(void)
+{
+	security_add_hooks(data_hooks, ARRAY_SIZE(data_hooks), "sara");
+	return sara_cred_alloc_blank((struct cred *) current->real_cred,
+				     GFP_KERNEL);
+}
+
+#else /* CONFIG_SECURITY_SARA_WXPROT */
+
+int __init sara_data_init(void)
+{
+	return 0;
+}
+
+#endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
