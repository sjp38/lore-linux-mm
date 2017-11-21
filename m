Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4756B0268
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:48 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n13so828717wmc.3
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m73sor545561wmd.75.2017.11.21.10.26.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:46 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 08/10] Allowing for stacking procattr support in S.A.R.A.
Date: Tue, 21 Nov 2017 19:26:10 +0100
Message-Id: <1511288772-19308-9-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

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
index 9d357b2..a8a4164 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2560,6 +2560,40 @@ static ssize_t proc_pid_attr_write(struct file * file, const char __user * buf,
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
@@ -2567,6 +2601,10 @@ static ssize_t proc_pid_attr_write(struct file * file, const char __user * buf,
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
index 21cd07e..2d00c5e 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1273,12 +1273,28 @@ void security_d_instantiate(struct dentry *dentry, struct inode *inode)
 
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
