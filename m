Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB6F86B026B
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:52 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so6229716wre.10
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor1346376wrv.39.2017.11.21.10.26.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:51 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 10/10] XATTRs support
Date: Tue, 21 Nov 2017 19:26:12 +0100
Message-Id: <1511288772-19308-11-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

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
 security/sara/wxprot.c                          | 97 +++++++++++++++++++++++++
 5 files changed, 159 insertions(+)

diff --git a/Documentation/admin-guide/LSM/SARA.rst b/Documentation/admin-guide/LSM/SARA.rst
index de41b78..a6f32e5 100644
--- a/Documentation/admin-guide/LSM/SARA.rst
+++ b/Documentation/admin-guide/LSM/SARA.rst
@@ -53,6 +53,8 @@ WX Protection. In particular:
 To extend the scope of the above features, despite the issues that they may
 cause, they are complemented by **/proc/PID/attr/sara/wxprot** interface
 and **trampoline emulation**.
+It's also possible to override the centralized configuration via `Extended
+filesystem attributes`_.
 
 At the moment, WX Protection (unless specified otherwise) should work on
 any architecture supporting the NX bit, including, but not limited to:
@@ -119,6 +121,24 @@ in your project or copy/paste parts of it.
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
index 20c9114..b58dcce 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -3841,6 +3841,22 @@
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
index b68c246..60f629f 100644
--- a/security/sara/Kconfig
+++ b/security/sara/Kconfig
@@ -113,6 +113,28 @@ config SECURITY_SARA_WXPROT_EMUTRAMP
 
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
index c14ad27..2c8ca58 100644
--- a/security/sara/wxprot.c
+++ b/security/sara/wxprot.c
@@ -23,6 +23,7 @@
 #include <linux/printk.h>
 #include <linux/ratelimit.h>
 #include <linux/spinlock.h>
+#include <linux/xattr.h>
 
 #include "include/sara.h"
 #include "include/sara_data.h"
@@ -88,6 +89,18 @@ struct wxprot_config_container {
 static const bool wxprot_emutramp;
 #endif
 
+#ifdef CONFIG_SECURITY_SARA_WXPROT_XATTRS_ENABLED
+static bool wxprot_xattrs_enabled __read_mostly = true;
+#else
+static bool wxprot_xattrs_enabled __read_mostly;
+#endif
+
+#ifdef CONFIG_SECURITY_SARA_WXPROT_XATTRS_USER
+static bool wxprot_xattrs_user __read_mostly = true;
+#else
+static bool wxprot_xattrs_user __read_mostly;
+#endif
+
 static void pr_wxp(char *msg)
 {
 	char *buf, *path;
@@ -138,6 +151,12 @@ static bool are_flags_valid(u16 flags)
 module_param(wxprot_enabled, bool, 0);
 MODULE_PARM_DESC(wxprot_enabled, "Disable or enable S.A.R.A. WX Protection at boot time.");
 
+module_param(wxprot_xattrs_enabled, bool, 0);
+MODULE_PARM_DESC(wxprot_xattrs_enabled, "Disable or enable S.A.R.A. WXP extended attributes interfaces.");
+
+module_param(wxprot_xattrs_user, bool, 0);
+MODULE_PARM_DESC(wxprot_xattrs_user, "Allow normal users to override S.A.R.A. WXP settings via extended attributes.");
+
 static int param_set_wxpflags(const char *val, const struct kernel_param *kp)
 {
 	u16 flags;
@@ -240,6 +259,65 @@ static inline int is_relro_page(const struct vm_area_struct *vma)
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
+	rc = __vfs_getxattr(d, d->d_inode, name, buffer, sizeof(buffer));
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
@@ -262,6 +340,10 @@ static int sara_bprm_set_creds(struct linux_binprm *bprm)
 	if (!sara_enabled || !wxprot_enabled)
 		return 0;
 
+	if (sara_wxprot_xattrs(bprm->file->f_path.dentry,
+			       &sara_wxp_flags) == 0)
+		goto flags_set;
+
 	/*
 	 * SARA_WXP_TRANSFER means that the parent
 	 * wants this child to inherit its flags.
@@ -295,6 +377,7 @@ static int sara_bprm_set_creds(struct linux_binprm *bprm)
 	} else
 		path = (char *) bprm->interp;
 
+flags_set:
 	if (sara_wxp_flags != default_flags &&
 	    sara_wxp_flags & SARA_WXP_VERBOSE)
 		pr_debug_ratelimited("WXP: '%s' run with flags '0x%x'.\n",
@@ -843,6 +926,10 @@ static int config_hash(char **buf)
 
 static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_enabled_data,
 				   wxprot_enabled);
+static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_xattrs_enabled_data,
+				   wxprot_xattrs_enabled);
+static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_xattrs_user_data,
+				   wxprot_xattrs_user);
 
 static struct sara_secfs_fptrs fptrs __ro_after_init = {
 	.load = config_load,
@@ -886,6 +973,16 @@ static DEFINE_SARA_SECFS_BOOL_FLAG(wxprot_enabled_data,
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
