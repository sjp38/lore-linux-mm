Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 983656B0315
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 12:44:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w91so4249391wrb.13
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:42 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id x66si580201wmb.38.2017.06.15.09.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 09:44:41 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id f90so792698wmh.0
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:41 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v2 8/9] Allowing for stacking procattr support in S.A.R.A.
Date: Thu, 15 Jun 2017 18:42:55 +0200
Message-Id: <1497544976-7856-9-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, x86@kernel.org, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

This allow S.A.R.A. to use the procattr interface without interfering
with other LSMs.
This part should be reimplemented as soon as upstream procattr stacking
support is available.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 fs/proc/base.c      | 38 ++++++++++++++++++++++++++++++++++++++
 security/security.c | 20 ++++++++++++++++++--
 2 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index f1e1927..6d0fd1c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2515,6 +2515,40 @@ static ssize_t proc_pid_attr_write(struct file * file, const char __user * buf,
 	.llseek		= generic_file_llseek,
 };
 
+#ifdef CONFIG_SECURITY_SARA
+static const struct pid_entry sara_attr_dir_stuff[] = {
+	REG("wxprot", 0666, proc_pid_attr_operations),
+};
+
+static int proc_sara_attr_dir_readdir(struct file *file,
+				      struct dir_context *ctx)
+{
+	return proc_pident_readdir(file, ctx,
+				   sara_attr_dir_stuff,
+				   ARRAY_SIZE(sara_attr_dir_stuff));
+}
+
+static const struct file_operations proc_sara_attr_dir_ops = {
+	.read		= generic_read_dir,
+	.iterate_shared	= proc_sara_attr_dir_readdir,
+	.llseek		= generic_file_llseek,
+};
+
+static struct dentry *proc_sara_attr_dir_lookup(struct inode *dir,
+				struct dentry *dentry, unsigned int flags)
+{
+	return proc_pident_lookup(dir, dentry,
+				  sara_attr_dir_stuff,
+				  ARRAY_SIZE(sara_attr_dir_stuff));
+};
+
+static const struct inode_operations proc_sara_attr_dir_inode_ops = {
+	.lookup		= proc_sara_attr_dir_lookup,
+	.getattr	= pid_getattr,
+	.setattr	= proc_setattr,
+};
+#endif /* CONFIG_SECURITY_SARA */
+
 static const struct pid_entry attr_dir_stuff[] = {
 	REG("current",    S_IRUGO|S_IWUGO, proc_pid_attr_operations),
 	REG("prev",       S_IRUGO,	   proc_pid_attr_operations),
@@ -2522,6 +2556,10 @@ static ssize_t proc_pid_attr_write(struct file * file, const char __user * buf,
 	REG("fscreate",   S_IRUGO|S_IWUGO, proc_pid_attr_operations),
 	REG("keycreate",  S_IRUGO|S_IWUGO, proc_pid_attr_operations),
 	REG("sockcreate", S_IRUGO|S_IWUGO, proc_pid_attr_operations),
+#ifdef CONFIG_SECURITY_SARA
+	DIR("sara", 0555, proc_sara_attr_dir_inode_ops,
+				proc_sara_attr_dir_ops),
+#endif
 };
 
 static int proc_attr_dir_readdir(struct file *file, struct dir_context *ctx)
diff --git a/security/security.c b/security/security.c
index f7df697..c6c78dd 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1239,12 +1239,28 @@ void security_d_instantiate(struct dentry *dentry, struct inode *inode)
 
 int security_getprocattr(struct task_struct *p, char *name, char **value)
 {
-	return call_int_hook(getprocattr, -EINVAL, p, name, value);
+	struct security_hook_list *hp;
+	int rc;
+
+	list_for_each_entry(hp, &security_hook_heads.getprocattr, list) {
+		rc = hp->hook.getprocattr(p, name, value);
+		if (rc != -EINVAL)
+			return rc;
+	}
+	return -EINVAL;
 }
 
 int security_setprocattr(const char *name, void *value, size_t size)
 {
-	return call_int_hook(setprocattr, -EINVAL, name, value, size);
+	struct security_hook_list *hp;
+	int rc;
+
+	list_for_each_entry(hp, &security_hook_heads.setprocattr, list) {
+		rc = hp->hook.setprocattr(name, value, size);
+		if (rc != -EINVAL)
+			return rc;
+	}
+	return -EINVAL;
 }
 
 int security_netlink_send(struct sock *sk, struct sk_buff *skb)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
