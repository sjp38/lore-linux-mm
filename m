Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D9C6C0650E
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBFD121670
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gy5TPt6/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBFD121670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 720806B0008; Sat,  6 Jul 2019 06:55:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D3BE8E0003; Sat,  6 Jul 2019 06:55:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 526EA8E0001; Sat,  6 Jul 2019 06:55:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3CEF6B0008
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 06:55:17 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b1so5020183wru.4
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 03:55:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=BW+8xpyQbi7Tl8ElYIH8BHwSiQojAb3nUmPsO54K1pU=;
        b=QLDvR/mr0B9fpGyRmFVen0UpHS0vGT3lPI5to+dgbKIa3xcM6rvtIuc2IQBnfF6L80
         eWMYclSZO296I11Q2HnnAKMndid/9AW3Kb4u7Hq0CUrxOzwaV5OQSYMvCHL5T9LOzhFG
         QORj3gTS73sLr0cWnJYyEjvo/QFiwJOkSBpp3uHLlSsShk+BLtCkQYKXvrRj56KdvCMJ
         9qCsDn49gQyqa1PM20QEa8GlMBrSLG0yiHda47HxPFRCJyO1/p8AfIFZpwltFanv4ayd
         La1/RBtrG5FwnHFRkERJX+TtUvK5kIoaEEnqJvpHTiB2G1IV6K1LUAkTSXycqHDD2DY3
         dqNw==
X-Gm-Message-State: APjAAAVqNW73ZGW03GzQa0JJs1Vzth6pHO6I1cqmsyceSaBwgde7oufl
	rmvr8k8zvqiCq0+eY4VLlxV2HkavVVSaC4XUjPq2QukKCyLGaSA9bKq8P7qty7zH75z49BMwfp8
	o/ue4KDok9KqXDPv9AJ1xaBGMyvLf9CUCgVx7TbBs4oXPuExnWuqAvoyJ2ZMvkkcFhQ==
X-Received: by 2002:a7b:cc04:: with SMTP id f4mr8027692wmh.125.1562410517407;
        Sat, 06 Jul 2019 03:55:17 -0700 (PDT)
X-Received: by 2002:a7b:cc04:: with SMTP id f4mr8027469wmh.125.1562410514746;
        Sat, 06 Jul 2019 03:55:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562410514; cv=none;
        d=google.com; s=arc-20160816;
        b=Jn/vjDpac6NKt5ay7iCJk+issvNaD0Lgmh3hNdMp4y616FfaUJTK28k7pr92Hg7Iz8
         SJc4JfQPp+Vh0P5wsgLmO5kavL+jgy/GhYd+SCKimhZNRUh1sszljpZqHRkhN7Sk0lt9
         0lqYxmyEKZWoZwKE/BmKvGA81ad7drvEzbH5z5YVlh+xOYOvzhzwq7qufmfc1kk9jCGU
         foeIhXzQcRER1QWJC+pgG6VK879wDXYcS9R3x1zHGZod0+Ax65t8To4egxGB+Dd5lgid
         zCFnWShbPm/wtU+uy/APRS6eCJI1IebDN/A0gSSEVOBZvL5hdROMmDKd3cyFLgK8gUm5
         Ilow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=BW+8xpyQbi7Tl8ElYIH8BHwSiQojAb3nUmPsO54K1pU=;
        b=OmHtxloDh/JuEqTXnpmOPOc5wQAtdd45RbWpwIzGavQPpCS8qYFdPsYQs2A1BUiBbp
         0KaJGPnAiLHw772Hbk8BxgeK1HwoJD7ebsK5W8QvP7ar7KRQAapD1XYHwv1OkUe47yey
         VB10Iv9HjH5+c0ZUexKNGQ0by96pfmKIUq2tGZvl6wvQ0ki2vDEuzXfhKTGs2zqAR/X3
         irUrDFFuvd6/htlNwToBmYfyFIvyHG8z8LTWAalcRjlYfgHcFRvCGgDnUdLnR9yHiFkV
         AkXzPlhSnjE9/3MGvUxP2ee2nmYyErZ+GDnZo0yAYjODCK9nEXydWIXv3sqN1aslrAy+
         002Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Gy5TPt6/";
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14sor8520936wro.49.2019.07.06.03.55.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 03:55:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Gy5TPt6/";
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=BW+8xpyQbi7Tl8ElYIH8BHwSiQojAb3nUmPsO54K1pU=;
        b=Gy5TPt6/txGbLsMhEqym/m39JJLOPOcUp33pKsBXIoOfib1/thpFoahS2bYRfcTk3z
         YNCV71Qgi/dESSZ5Cid+OeLB1kL5AdVmRTO1vtsKAzliLqu7E7guphMsmUBivmlCBN9g
         xXzIOQiEkfK/fwXB37ZloNWywr4ijHxf18F1oIlU9mdS91Ib1dAwG4QSrlNu3fnRfpnt
         3p7hdKEu8kHcCxudsUWLovvcISlvkL1gmsmZp3MnaoXR7hhnPpsk7hzk0La7U/SOhyJv
         xup3QV0T0CwQ7M6Z2iZnyYkyuKJsml23601/JLFeKW/SNDL3jpiboPC6IzfY0EGKVst3
         ko2g==
X-Google-Smtp-Source: APXvYqy1ogO8dZ6NgaXXKK6DDQbYjudAU/lxFkXrHqpSoq4/f+IV71mZjPvf6fXPReqkMC7l8mLNCQ==
X-Received: by 2002:a5d:468a:: with SMTP id u10mr8850925wrq.177.1562410514014;
        Sat, 06 Jul 2019 03:55:14 -0700 (PDT)
Received: from localhost (net-93-71-3-102.cust.vodafonedsl.it. [93.71.3.102])
        by smtp.gmail.com with ESMTPSA id h11sm12578794wrx.93.2019.07.06.03.55.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 06 Jul 2019 03:55:13 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Brad Spengler <spender@grsecurity.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Morris <james.l.morris@oracle.com>,
	Jann Horn <jannh@google.com>,
	Kees Cook <keescook@chromium.org>,
	PaX Team <pageexec@freemail.hu>,
	Salvatore Mesoraca <s.mesoraca16@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH v5 02/12] S.A.R.A.: create framework
Date: Sat,  6 Jul 2019 12:54:43 +0200
Message-Id: <1562410493-8661-3-git-send-email-s.mesoraca16@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Initial S.A.R.A. framework setup.
Creation of a simplified interface to securityfs API to store and retrieve
configurations and flags from user-space.
Creation of some generic functions and macros to handle concurrent access
to configurations, memory allocation and path resolution.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 security/Kconfig                   |  11 +-
 security/Makefile                  |   2 +
 security/sara/Kconfig              |  40 +++
 security/sara/Makefile             |   3 +
 security/sara/include/sara.h       |  29 ++
 security/sara/include/securityfs.h |  61 ++++
 security/sara/include/utils.h      |  80 ++++++
 security/sara/main.c               | 115 ++++++++
 security/sara/securityfs.c         | 565 +++++++++++++++++++++++++++++++++++++
 security/sara/utils.c              |  92 ++++++
 10 files changed, 993 insertions(+), 5 deletions(-)
 create mode 100644 security/sara/Kconfig
 create mode 100644 security/sara/Makefile
 create mode 100644 security/sara/include/sara.h
 create mode 100644 security/sara/include/securityfs.h
 create mode 100644 security/sara/include/utils.h
 create mode 100644 security/sara/main.c
 create mode 100644 security/sara/securityfs.c
 create mode 100644 security/sara/utils.c

diff --git a/security/Kconfig b/security/Kconfig
index 466cc1f..4cae0ec 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -237,6 +237,7 @@ source "security/apparmor/Kconfig"
 source "security/loadpin/Kconfig"
 source "security/yama/Kconfig"
 source "security/safesetid/Kconfig"
+source "security/sara/Kconfig"
 
 source "security/integrity/Kconfig"
 
@@ -276,11 +277,11 @@ endchoice
 
 config LSM
 	string "Ordered list of enabled LSMs"
-	default "yama,loadpin,safesetid,integrity,smack,selinux,tomoyo,apparmor" if DEFAULT_SECURITY_SMACK
-	default "yama,loadpin,safesetid,integrity,apparmor,selinux,smack,tomoyo" if DEFAULT_SECURITY_APPARMOR
-	default "yama,loadpin,safesetid,integrity,tomoyo" if DEFAULT_SECURITY_TOMOYO
-	default "yama,loadpin,safesetid,integrity" if DEFAULT_SECURITY_DAC
-	default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
+	default "yama,loadpin,safesetid,integrity,sara,smack,selinux,tomoyo,apparmor" if DEFAULT_SECURITY_SMACK
+	default "yama,loadpin,safesetid,integrity,sara,apparmor,selinux,smack,tomoyo" if DEFAULT_SECURITY_APPARMOR
+	default "yama,loadpin,safesetid,integrity,sara,tomoyo" if DEFAULT_SECURITY_TOMOYO
+	default "yama,loadpin,safesetid,integrity,sara" if DEFAULT_SECURITY_DAC
+	default "yama,loadpin,safesetid,integrity,sara,selinux,smack,tomoyo,apparmor"
 	help
 	  A comma-separated list of LSMs, in initialization order.
 	  Any LSMs left off this list will be ignored. This can be
diff --git a/security/Makefile b/security/Makefile
index c598b90..4b0fd11 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -11,6 +11,7 @@ subdir-$(CONFIG_SECURITY_APPARMOR)	+= apparmor
 subdir-$(CONFIG_SECURITY_YAMA)		+= yama
 subdir-$(CONFIG_SECURITY_LOADPIN)	+= loadpin
 subdir-$(CONFIG_SECURITY_SAFESETID)    += safesetid
+subdir-$(CONFIG_SECURITY_SARA)		+= sara
 
 # always enable default capabilities
 obj-y					+= commoncap.o
@@ -27,6 +28,7 @@ obj-$(CONFIG_SECURITY_APPARMOR)		+= apparmor/
 obj-$(CONFIG_SECURITY_YAMA)		+= yama/
 obj-$(CONFIG_SECURITY_LOADPIN)		+= loadpin/
 obj-$(CONFIG_SECURITY_SAFESETID)       += safesetid/
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
index 0000000..cd12f52
--- /dev/null
+++ b/security/sara/include/sara.h
@@ -0,0 +1,29 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
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
+extern int sara_config_locked __read_mostly;
+extern int sara_enabled __read_mostly;
+
+#endif /* __SARA_H */
diff --git a/security/sara/include/securityfs.h b/security/sara/include/securityfs.h
new file mode 100644
index 0000000..92d6180
--- /dev/null
+++ b/security/sara/include/securityfs.h
@@ -0,0 +1,61 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
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
+	int *const flag;
+};
+
+#define DEFINE_SARA_SECFS_BOOL_FLAG(NAME, VAR)		\
+const struct sara_secfs_bool_flag NAME = {		\
+	.notice_line = #VAR,				\
+	.flag = &(VAR),					\
+}
+
+#endif /* __SARA_SECURITYFS_H */
diff --git a/security/sara/include/utils.h b/security/sara/include/utils.h
new file mode 100644
index 0000000..ce9d5fb
--- /dev/null
+++ b/security/sara/include/utils.h
@@ -0,0 +1,80 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
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
+
+static inline void release_entry(struct kref *ref)
+{
+	/* All work is done after the return from kref_put(). */
+}
+
+
+/*
+ * The following macros must be used to access S.A.R.A. configuration
+ * structures.
+ * They are thread-safe under the assumption that a configuration
+ * won't ever be deleted but just replaced using SARA_CONFIG_REPLACE,
+ * possibly using an empty configuration.
+ * i.e. every call to SARA_CONFIG_PUT *must* be preceded by a matching
+ * SARA_CONFIG_GET invocation.
+ */
+
+#define SARA_CONFIG_GET_RCU(DEST, CONFIG) do {	\
+	rcu_read_lock();			\
+	(DEST) = rcu_dereference(CONFIG);	\
+} while (0)
+
+#define SARA_CONFIG_PUT_RCU(DATA) do {		\
+	rcu_read_unlock();			\
+	(DATA) = NULL;				\
+} while (0)
+
+#define SARA_CONFIG_GET(DEST, CONFIG) do {				\
+	rcu_read_lock();						\
+	do {								\
+		(DEST) = rcu_dereference(CONFIG);			\
+	} while ((DEST) && !kref_get_unless_zero(&(DEST)->refcount));	\
+	rcu_read_unlock();						\
+} while (0)
+
+#define SARA_CONFIG_PUT(DATA, FREE) do {			\
+	if (kref_put(&(DATA)->refcount, release_entry)) {	\
+		synchronize_rcu();				\
+		(FREE)(DATA);					\
+	}							\
+	(DATA) = NULL;						\
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
index 0000000..52e6d18
--- /dev/null
+++ b/security/sara/main.c
@@ -0,0 +1,115 @@
+// SPDX-License-Identifier: GPL-2.0
+
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
+#include <linux/lsm_hooks.h>
+#include <linux/module.h>
+#include <linux/printk.h>
+
+#include "include/sara.h"
+#include "include/securityfs.h"
+
+static const int sara_version = SARA_VERSION;
+
+#ifdef CONFIG_SECURITY_SARA_NO_RUNTIME_ENABLE
+int sara_config_locked __read_mostly = true;
+#else
+int sara_config_locked __read_mostly;
+#endif
+
+#ifdef CONFIG_SECURITY_SARA_DEFAULT_DISABLED
+int sara_enabled __read_mostly;
+#else
+int sara_enabled __read_mostly = true;
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
+	sara_config_locked = !(*(int *) kp->arg);
+	return 0;
+}
+
+static struct kernel_param_ops param_ops_senabled = {
+	.set = param_set_senabled,
+};
+
+#define param_check_senabled(name, p) __param_check(name, p, int)
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
+static int __init sara_init(void)
+{
+	if (!sara_enabled && sara_config_locked) {
+		pr_notice("permanently disabled.\n");
+		return 0;
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
+	return 0;
+
+error:
+	sara_enabled = false;
+	sara_config_locked = true;
+	pr_crit("permanently disabled.\n");
+	return 1;
+}
+
+DEFINE_LSM(sara) = {
+	.name = "sara",
+	.enabled = &sara_enabled,
+	.init = sara_init,
+};
diff --git a/security/sara/securityfs.c b/security/sara/securityfs.c
new file mode 100644
index 0000000..f6b152c
--- /dev/null
+++ b/security/sara/securityfs.c
@@ -0,0 +1,565 @@
+// SPDX-License-Identifier: GPL-2.0
+
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
+	int *flag = ((struct sara_secfs_bool_flag *)seq->private)->flag;
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
+	int nf;
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
+	kbuf = kvmalloc(buf_size, GFP_KERNEL_ACCOUNT);
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
+	return ret;
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
+	return ret;
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
+	return ret;
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
+	return ret;
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
+	return ret;
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
index 0000000..d63febb
--- /dev/null
+++ b/security/sara/utils.c
@@ -0,0 +1,92 @@
+// SPDX-License-Identifier: GPL-2.0
+
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
+		work_buf = kvmalloc(size, GFP_KERNEL);
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
+		*buf = kzalloc(TASK_COMM_LEN, GFP_KERNEL);
+		__get_task_comm(*buf, TASK_COMM_LEN, current);
+		path = *buf;
+	}
+	return path;
+}
-- 
1.9.1

