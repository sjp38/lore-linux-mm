Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 826936B0311
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 12:44:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b184so549259wme.14
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:36 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 21si612412wrt.177.2017.06.15.09.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 09:44:35 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id d17so792140wme.3
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:34 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v2 4/9] S.A.R.A. cred blob management
Date: Thu, 15 Jun 2017 18:42:51 +0200
Message-Id: <1497544976-7856-5-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, x86@kernel.org, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

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
 security/sara/include/sara_data.h | 47 +++++++++++++++++++++++
 security/sara/main.c              |  6 +++
 security/sara/sara_data.c         | 79 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 136 insertions(+), 1 deletion(-)
 create mode 100644 security/sara/include/sara_data.h
 create mode 100644 security/sara/sara_data.c

diff --git a/include/linux/cred.h b/include/linux/cred.h
index b03e7d0..007feb5 100644
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
index 0000000..7ed04fd
--- /dev/null
+++ b/security/sara/include/sara_data.h
@@ -0,0 +1,47 @@
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
+	u16		wxp_flags;
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
+#define get_sara_relro_page(X) (get_sara_data((X))->relro_page)
+#define get_current_sara_relro_page() get_sara_relro_page(current_cred())
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
index 2007735..644ff6d 100644
--- a/security/sara/main.c
+++ b/security/sara/main.c
@@ -14,6 +14,7 @@
 #include <linux/printk.h>
 
 #include "include/sara.h"
+#include "include/sara_data.h"
 #include "include/securityfs.h"
 
 static const int sara_version = SARA_VERSION;
@@ -80,6 +81,11 @@ void __init sara_init(void)
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
