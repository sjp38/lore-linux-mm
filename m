Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F86DC468AE
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBF2421670
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZLNuz0c2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBF2421670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E6C98E0008; Sat,  6 Jul 2019 06:55:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5710E8E0006; Sat,  6 Jul 2019 06:55:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EF038E0008; Sat,  6 Jul 2019 06:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D27828E0006
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 06:55:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i6so5006273wre.1
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 03:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=yTf2cEJ/R1sIWwnnsJBizfOJ+ZTQkKILtxUL3GoVlWE=;
        b=aeQLOLZTxmlH7UjeMQ76maTA9fY35/PbF3psy+yQFiDc6qmYB+cN7hKHsH8HRy8WjS
         1gGd5pZfsTg1lhGOapDOw+ia2VBWgBnxWdF0KqAc48RfS1w4aCiZQMfn4oI8pVXjP/SD
         gqX6M/x831Z3H19/6DyFCK3aMgOxszmKKkQ8hgbNZoWe/82ZL7FwOWN2RtwA+lvx/t7G
         cS6WN804+y+iO4c6w4wwY1RW8cCKD6Nr9rYzJPm9CgbsYvrnDyDibDCAyFvP1MK7LwJk
         jE5Kr+x3Mdx0be2VZZKShpWZve1YtzeaEbfKArsWvOMm725TSj4h/YJLdDz2VT4+P3yR
         vd+Q==
X-Gm-Message-State: APjAAAU1lJ9FsS39TvOU/5g5iMnBU7vLHaI3zVHlLL1euQorhJ07l2Ed
	5BnnE/KG4bU80FUOT1QgZYd4zjs5slYg5T/uoH6JFF1fHTqkdx9+VaCGuK44PvAzOoUTTQvoauc
	5PviLf4vFJKjWvCQWLd5mnzypi0O35U8IFqA8g81K3Tc8brj1XymYDVrfwle490qCTA==
X-Received: by 2002:adf:f686:: with SMTP id v6mr8413231wrp.238.1562410525394;
        Sat, 06 Jul 2019 03:55:25 -0700 (PDT)
X-Received: by 2002:adf:f686:: with SMTP id v6mr8413097wrp.238.1562410523678;
        Sat, 06 Jul 2019 03:55:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562410523; cv=none;
        d=google.com; s=arc-20160816;
        b=YdUVy/tJaG7JIorhN3Y1QLyLBi97C/MEojzYwSw3dvU+QVZto+IQw+8RCb8ayZ2GmE
         b2HJTrGXGGc5QCM8Togjnws6XS4yHbIa0lI9uky7Qupg3lf64585GQeB2VwPMTGE4hTz
         NCRvJ4A2z2F8IXXoAXA6TABGokVWh4c5LLKGdfVQ20lKFOdXlvOPXK/MfVAv63WG/YrH
         QnwNJRxgXcbHWQyzVyUCVfUxTybd78Udg0mNFmCIliYhp6x7S2A248tY+MQIFD1f/pf7
         0ac7bE6rcegDYMsnBciwNJQRemayayTSzDAuQi66g4oTo+K2nSJCitU4w9P2lWq03jfa
         NcLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=yTf2cEJ/R1sIWwnnsJBizfOJ+ZTQkKILtxUL3GoVlWE=;
        b=SPcejN0r7xIgnJjp0Qo5+Dwm9zX3UoO6+vVHREapnKg4e3xb/D7EixIIWnTDc3RPYB
         53/Gm+h01uFKEpEUu5/aCs+fFIoTr9RYrQ1MZqjR/MZXzWfJEJ+rUTfRu04yUb93XmTZ
         skvZGcet+l9otIvjXrDjN8dppQmNAGAcgx5GJA6ZxJS5JG/3c/+f2q4VE5uNInOUtOeh
         LABtnq+MdZZTZTnhyRkUsUpdOo1WeYZC5FH36pFEpp2DSVIcr19XqCMwWZpQ9tPjgDPX
         2ua5qyH7XpiaVg6D1MjY2gUKwI0xq99oBJFIgARFb/g2L7PnzARG/PIdKrfQ7Q6xytRs
         YgqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZLNuz0c2;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e9sor8656893wrx.37.2019.07.06.03.55.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 03:55:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZLNuz0c2;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=yTf2cEJ/R1sIWwnnsJBizfOJ+ZTQkKILtxUL3GoVlWE=;
        b=ZLNuz0c29GG+6CNJGcOAjeOlpRMP9h7O99Pi/gakDKFGU3lhhHikq8a99CInc2k/XO
         x6Aq3KQ16oEDc3jolc38IPHfVlXaurELUSiUDHn05p6lfOFDkkvsNRWEIR/u9OIqM0Iv
         HtbBQ2B/Kq1vvvG4gn4LbVxWfdc/sXmvb7bh25PrgcUiOFGqI5qzgRkWR5JJ3qB8it29
         nt6KXK7N3DC9FtosDIw8Yw2FSs9KbQjD6zMPBftq1aXOG2YvtlhuzxNjQd3NYN3DSsHP
         AO1doaXc1DmHasyn5SSmlIyHvB5/T78+l9uWIWn6bgSiY0WNtJcA4pqYF4yEJgMx128n
         jwQQ==
X-Google-Smtp-Source: APXvYqy4CMl5RxszjxSvrEAMWtejw7CVXkEcAJC69QuAF9VdqwZsgSkOM4PQR4vCXHHgIdQEtRBcQw==
X-Received: by 2002:adf:e483:: with SMTP id i3mr7749477wrm.210.1562410523298;
        Sat, 06 Jul 2019 03:55:23 -0700 (PDT)
Received: from localhost (net-93-71-3-102.cust.vodafonedsl.it. [93.71.3.102])
        by smtp.gmail.com with ESMTPSA id h11sm12578794wrx.93.2019.07.06.03.55.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 06 Jul 2019 03:55:22 -0700 (PDT)
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
Subject: [PATCH v5 10/12] S.A.R.A.: XATTRs support
Date: Sat,  6 Jul 2019 12:54:51 +0200
Message-Id: <1562410493-8661-11-git-send-email-s.mesoraca16@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adds support for extended filesystem attributes in security and user
namespaces. They can be used to override flags set via the centralized
configuration, even when S.A.R.A. configuration is locked or saractl
is not used at all.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 Documentation/admin-guide/LSM/SARA.rst          | 20 +++++
 Documentation/admin-guide/kernel-parameters.txt | 16 ++++
 include/uapi/linux/xattr.h                      |  4 +
 security/sara/Kconfig                           | 22 ++++++
 security/sara/wxprot.c                          | 99 +++++++++++++++++++++++++
 5 files changed, 161 insertions(+)

diff --git a/Documentation/admin-guide/LSM/SARA.rst b/Documentation/admin-guide/LSM/SARA.rst
index fdde04c..47d9364 100644
--- a/Documentation/admin-guide/LSM/SARA.rst
+++ b/Documentation/admin-guide/LSM/SARA.rst
@@ -55,6 +55,8 @@ WX Protection. In particular:
 To extend the scope of the above features, despite the issues that they may
 cause, they are complemented by **/proc/PID/attr/sara/wxprot** interface
 and **trampoline emulation**.
+It's also possible to override the centralized configuration via `Extended
+filesystem attributes`_.
 
 At the moment, WX Protection (unless specified otherwise) should work on
 any architecture supporting the NX bit, including, but not limited to:
@@ -123,6 +125,24 @@ in your project or copy/paste parts of it.
 To make things simpler `libsara` is the only part of S.A.R.A. released under
 *CC0 - No Rights Reserved* license.
 
+Extended filesystem attributes
+^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+When this functionality is enabled, it's possible to override
+WX Protection flags set in the main configuration via extended attributes,
+even when S.A.R.A.'s configuration is in "locked" mode.
+If the user namespace is also enabled, its attributes will override settings
+configured via the security namespace.
+The xattrs currently in use are:
+
+- security.sara.wxprot
+- user.sara.wxprot
+
+They can be manually set to the desired value as a decimal, hexadecimal or
+octal number. When this functionality is enabled, S.A.R.A. can be easily used
+without the help of its userspace tools. Though the preferred way to change
+these attributes is `sara-xattr` which is part of `saractl` [2]_.
+
+
 Trampoline emulation
 ^^^^^^^^^^^^^^^^^^^^
 Some programs need to generate part of their code at runtime. Luckily enough,
diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 3d6e86d..af40f1b 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -4254,6 +4254,22 @@
 			See S.A.R.A. documentation.
 			Default value is set via kernel config option.
 
+	sara.wxprot_xattrs_enabled= [SARA]
+			Enable support for security xattrs.
+			Format: { "0" | "1" }
+			See security/sara/Kconfig help text
+			0 -- disable.
+			1 -- enable.
+			Default value is set via kernel config option.
+
+	sara.wxprot_xattrs_user= [SARA]
+			Enable support for user xattrs.
+			Format: { "0" | "1" }
+			See security/sara/Kconfig help text
+			0 -- disable.
+			1 -- enable.
+			Default value is set via kernel config option.
+
 	serialnumber	[BUGS=X86-32]
 
 	shapers=	[NET]
diff --git a/include/uapi/linux/xattr.h b/include/uapi/linux/xattr.h
index c1395b5..45c0333 100644
--- a/include/uapi/linux/xattr.h
+++ b/include/uapi/linux/xattr.h
@@ -77,5 +77,9 @@
 #define XATTR_POSIX_ACL_DEFAULT  "posix_acl_default"
 #define XATTR_NAME_POSIX_ACL_DEFAULT XATTR_SYSTEM_PREFIX XATTR_POSIX_ACL_DEFAULT
 
+#define XATTR_SARA_SUFFIX "sara."
+#define XATTR_SARA_WXP_SUFFIX XATTR_SARA_SUFFIX "wxp"
+#define XATTR_NAME_SEC_SARA_WXP XATTR_SECURITY_PREFIX XATTR_SARA_WXP_SUFFIX
+#define XATTR_NAME_USR_SARA_WXP XATTR_USER_PREFIX XATTR_SARA_WXP_SUFFIX
 
 #endif /* _UAPI_LINUX_XATTR_H */
diff --git a/security/sara/Kconfig b/security/sara/Kconfig
index 458e0e8..773256b 100644
--- a/security/sara/Kconfig
+++ b/security/sara/Kconfig
@@ -135,6 +135,28 @@ config SECURITY_SARA_WXPROT_EMUTRAMP
 
 	  If unsure, answer y.
 
+config SECURITY_SARA_WXPROT_XATTRS_ENABLED
+	bool "xattrs support enabled by default."
+	depends on SECURITY_SARA_WXPROT
+	default n
+	help
+	  If you say Y here it will be possible to override WX protection
+	  configuration via extended attributes in the security namespace.
+	  Even when S.A.R.A.'s configuration has been locked.
+
+	  If unsure, answer N.
+
+config CONFIG_SECURITY_SARA_WXPROT_XATTRS_USER
+	bool "'user' namespace xattrs support enabled by default."
+	depends on SECURITY_SARA_WXPROT_XATTRS_ENABLED
+	default n
+	help
+	  If you say Y here it will be possible to override WX protection
+	  configuration via extended attributes in the user namespace.
+	  Even when S.A.R.A.'s configuration has been locked.
+
+	  If unsure, answer N.
+
 config SECURITY_SARA_WXPROT_DISABLED
 	bool "WX protection will be disabled at boot."
 	depends on SECURITY_SARA_WXPROT
diff --git a/security/sara/wxprot.c b/security/sara/wxprot.c
index 84f7b1e..773d1fd 100644
--- a/security/sara/wxprot.c
+++ b/security/sara/wxprot.c
@@ -25,6 +25,7 @@
 #include <linux/printk.h>
 #include <linux/ratelimit.h>
 #include <linux/spinlock.h>
+#include <linux/xattr.h>
 
 #include "include/dfa.h"
 #include "include/sara.h"
@@ -82,6 +83,18 @@ struct wxprot_config_container {
 static const bool wxprot_emutramp;
 #endif
 
+#ifdef CONFIG_SECURITY_SARA_WXPROT_XATTRS_ENABLED
+static int wxprot_xattrs_enabled __read_mostly = true;
+#else
+static int wxprot_xattrs_enabled __read_mostly;
+#endif
+
+#ifdef CONFIG_SECURITY_SARA_WXPROT_XATTRS_USER
+static int wxprot_xattrs_user __read_mostly = true;
+#else
+static int wxprot_xattrs_user __read_mostly;
+#endif
+
 static void pr_wxp(char *msg)
 {
 	char *buf, *path;
@@ -133,6 +146,14 @@ static bool are_flags_valid(u16 flags)
 MODULE_PARM_DESC(wxprot_enabled,
 		 "Disable or enable S.A.R.A. WX Protection at boot time.");
 
+module_param(wxprot_xattrs_enabled, int, 0);
+MODULE_PARM_DESC(wxprot_xattrs_enabled,
+		 "Disable or enable S.A.R.A. WXP extended attributes interfaces.");
+
+module_param(wxprot_xattrs_user, int, 0);
+MODULE_PARM_DESC(wxprot_xattrs_user,
+		 "Allow normal users to override S.A.R.A. WXP settings via extended attributes.");
+
 static int param_set_wxpflags(const char *val, const struct kernel_param *kp)
 {
 	u16 flags;
@@ -236,6 +257,65 @@ static inline int is_relro_page(const struct vm_area_struct *vma)
 }
 
 /*
+ * Extended attributes handling
+ */
+static int sara_wxprot_xattrs_name(struct dentry *d,
+				   const char *name,
+				   u16 *flags)
+{
+	int rc;
+	char buffer[10];
+	u16 tmp;
+
+	if (!(d->d_inode->i_opflags & IOP_XATTR))
+		return -EOPNOTSUPP;
+
+	rc = __vfs_getxattr(d, d->d_inode, name, buffer, sizeof(buffer) - 1);
+	if (rc > 0) {
+		buffer[rc] = '\0';
+		rc = kstrtou16(buffer, 0, &tmp);
+		if (rc)
+			return rc;
+		if (!are_flags_valid(tmp))
+			return -EINVAL;
+		*flags = tmp;
+		return 0;
+	} else if (rc < 0)
+		return rc;
+
+	return -ENODATA;
+}
+
+#define sara_xattrs_may_return(RC, XATTRNAME, FNAME) do {	\
+	if (RC == -EINVAL || RC == -ERANGE)			\
+		pr_info_ratelimited(				\
+			"WXP: malformed xattr '%s' on '%s'\n",	\
+			XATTRNAME,				\
+			FNAME);					\
+	else if (RC == 0)					\
+		return 0;					\
+} while (0)
+
+static inline int sara_wxprot_xattrs(struct dentry *d,
+				     u16 *flags)
+{
+	int rc;
+
+	if (!wxprot_xattrs_enabled)
+		return 1;
+	if (wxprot_xattrs_user) {
+		rc = sara_wxprot_xattrs_name(d, XATTR_NAME_USR_SARA_WXP,
+					     flags);
+		sara_xattrs_may_return(rc, XATTR_NAME_USR_SARA_WXP,
+				       d->d_name.name);
+	}
+	rc = sara_wxprot_xattrs_name(d, XATTR_NAME_SEC_SARA_WXP, flags);
+	sara_xattrs_may_return(rc, XATTR_NAME_SEC_SARA_WXP, d->d_name.name);
+	return 1;
+}
+
+
+/*
  * LSM hooks
  */
 static int sara_bprm_set_creds(struct linux_binprm *bprm)
@@ -259,6 +339,10 @@ static int sara_bprm_set_creds(struct linux_binprm *bprm)
 	if (!sara_enabled || !wxprot_enabled)
 		return 0;
 
+	if (sara_wxprot_xattrs(bprm->file->f_path.dentry,
+			       &sara_wxp_flags) == 0)
+		goto flags_set;
+
 	/*
 	 * SARA_WXP_TRANSFER means that the parent
 	 * wants this child to inherit its flags.
@@ -283,6 +367,7 @@ static int sara_bprm_set_creds(struct linux_binprm *bprm)
 	} else
 		path = (char *) bprm->interp;
 
+flags_set:
 	if (sara_wxp_flags != default_flags &&
 	    sara_wxp_flags & SARA_WXP_VERBOSE)
 		pr_debug_ratelimited("WXP: '%s' run with flags '0x%x'.\n",
@@ -777,6 +862,10 @@ static int config_hash(char **buf)
 
 static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_enabled_data,
 				   wxprot_enabled);
+static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_xattrs_enabled_data,
+				   wxprot_xattrs_enabled);
+static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_xattrs_user_data,
+				   wxprot_xattrs_user);
 
 static struct sara_secfs_fptrs fptrs __lsm_ro_after_init = {
 	.load = config_load,
@@ -820,6 +909,16 @@ static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_enabled_data,
 		.type = SARA_SECFS_CONFIG_HASH,
 		.data = &fptrs,
 	},
+	{
+		.name = "xattr_enabled",
+		.type = SARA_SECFS_BOOL,
+		.data = (void *) &wxprot_xattrs_enabled_data,
+	},
+	{
+		.name = "xattr_user_allowed",
+		.type = SARA_SECFS_BOOL,
+		.data = (void *) &wxprot_xattrs_user_data,
+	},
 };
 
 
-- 
1.9.1

