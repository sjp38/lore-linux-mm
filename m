Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 361C5C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 23:45:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C97A420651
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 23:45:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C97A420651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F6AB6B0007; Wed, 27 Mar 2019 19:45:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A3326B0008; Wed, 27 Mar 2019 19:45:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4937E6B000A; Wed, 27 Mar 2019 19:45:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 194586B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 19:45:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b3so18549864qtr.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:45:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=PV7wbjH0KSOOmbgNjkS9PZ0YS4nA9XNl1x0d9S54938=;
        b=hr8v2f9FflAIdSz2rmEv2OcHicuyaM3sB8NdT7bj0M9JoIr0qQSB/rMGNxhbY+x7Cf
         nooV3jufvxYz1LD180JShTMGe6nkzGO/lLZYEhX4f5VZJU7Y4XsiS+1AVvZLtkLOZrX8
         ZqvLkRRIX322/ccGBgbb61NOUBuMZy5lhmyq0ZwFu+m1G950TTup5s/v/9owHFuRKbDB
         3XOEf40mcr7BQUDhPOBDngaMV/WE4P+240AljVGs+jFaNEB555WIVLhroMKqBKKpOrnw
         j6ceJN0ePJ+Rqskk87S8WulMU4Sul/hgGJR6IDDPs5nxObaBjt2rXZ+jeOSLglchqh9X
         GsYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVnTz9KaGRto+33TNWscT+89zbU7AhTp6Bk8fH9cIGLWiWeJAAu
	cUpHt0fZv+QflElSvb+zSZoeVK3WkeiZOf/T7Obm0TNe6G80IXXpmnr+L8ONEi9JjX+dbwQx8K7
	J11Ul2xAkujhVHh/MeiTtXzqbYSHsIGyLJInrhiJmOK2SrOB2VI+oEi7T2wrkSUHuyg==
X-Received: by 2002:ac8:925:: with SMTP id t34mr17641645qth.30.1553730352777;
        Wed, 27 Mar 2019 16:45:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynI9ql3CB5nZ1xiAvFhfHHOK1blMJ+a7gECO0QSjOtBO5gwpDoDku452lCSrACLZY7pW9d
X-Received: by 2002:ac8:925:: with SMTP id t34mr17641552qth.30.1553730350764;
        Wed, 27 Mar 2019 16:45:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553730350; cv=none;
        d=google.com; s=arc-20160816;
        b=aePWEpcksVOIQSW+hPa3zgYHA2+NNxzlt0AghFQ0WS/2q2Zav+rW22qm9uMF9ZEo7P
         CQh4nd/v+nBa93i1hbhnFWu7PvCYQQywbJyDI19LqGhE7JZequs5DQCQuX2EV0uBUXTC
         BQO+O9o1eFeHNYs6bGr9O7SYxvVka4kbmsonhMwh8lQ8n7X8M+1Ui8y1dLOQBqiX26vJ
         dtTvm0mfFhMuK1QogMMk/CLpKIbATfB06vMk8WghVafclBfcUqMq0AIi1hETfDKNcFM/
         FIgLycVI9fcO/PdD4JP6AzMrYfrBGL3GBTuJIeS+1PFKxFogF2lL51Cth/pbepfScNwi
         bA9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:organization;
        bh=PV7wbjH0KSOOmbgNjkS9PZ0YS4nA9XNl1x0d9S54938=;
        b=05k8KRIn1d9Ecibx4lOMo8GpK9SU5JQ26IQb0WalgqWzEE3jQ0LOHmMUlFepAZ3flC
         nl+2Nq3GQpygSts4/Xqz8s3Y+W52fq+U9eHZ/M9ry4MwJKCKbFczj9j/pZyl48JNZK6E
         D6pnioMVLoSb/DKPiIelIuT1fjKPkFNue4r3KhJ+4CR9GTZl1NjbsHdFqBdzxJUhUYV1
         chOVWGKFaxS18F6XyEeCtSnY1mLoP6Fl3jhdmA9hI+aqxbRk49CbZCxQCSstScY80eSi
         EIXHmcM8UxsZgh578ImyYVvJTw/TPv5hrQxKWoaZE5tOp9GaSjwyMYrfmLPzdWlsmqyF
         4jAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y20si1243438qve.114.2019.03.27.16.45.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 16:45:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C71F5308FC20;
	Wed, 27 Mar 2019 23:45:44 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-98.rdu2.redhat.com [10.10.121.98])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5E5165D9C4;
	Wed, 27 Mar 2019 23:45:43 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 41/68] vfs: Convert ramfs, shmem, tmpfs, devtmpfs,
 rootfs to use the new mount API
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 dhowells@redhat.com
Date: Wed, 27 Mar 2019 23:45:42 +0000
Message-ID: <155373034262.7602.5546279678313283723.stgit@warthog.procyon.org.uk>
In-Reply-To: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
References: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 27 Mar 2019 23:45:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert the ramfs, shmem, tmpfs, devtmpfs and rootfs filesystems to the new
internal mount API as the old one will be obsoleted and removed.  This
allows greater flexibility in communication of mount parameters between
userspace, the VFS and the filesystem.

See Documentation/filesystems/mount_api.txt for more information.

Note that tmpfs is slightly tricky as it can contain embedded commas, so it
can't be trivially split up using strsep() to break on commas in
generic_parse_monolithic().  Instead, tmpfs has to supply its own generic
parser.

However, if tmpfs changes, then devtmpfs and rootfs, which are wrappers
around tmpfs or ramfs, must change too - and thus so must ramfs, so these
had to be converted also.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Hugh Dickins <hughd@google.com>
cc: linux-mm@kvack.org
---

 drivers/base/devtmpfs.c  |   16 +-
 fs/ramfs/inode.c         |  104 +++++++-----
 include/linux/ramfs.h    |    6 -
 include/linux/shmem_fs.h |    4 
 init/do_mounts.c         |   12 +
 mm/shmem.c               |  396 ++++++++++++++++++++++++++++++----------------
 6 files changed, 341 insertions(+), 197 deletions(-)

diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index 0dbc43068eeb..1f50c844c2ab 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -56,19 +56,15 @@ static int __init mount_param(char *str)
 }
 __setup("devtmpfs.mount=", mount_param);
 
-static struct dentry *dev_mount(struct file_system_type *fs_type, int flags,
-		      const char *dev_name, void *data)
-{
+static struct file_system_type dev_fs_type = {
+	.name = "devtmpfs",
 #ifdef CONFIG_TMPFS
-	return mount_single(fs_type, flags, data, shmem_fill_super);
+	.init_fs_context = shmem_init_fs_context,
+	.parameters	= &shmem_fs_parameters,
 #else
-	return mount_single(fs_type, flags, data, ramfs_fill_super);
+	.init_fs_context = ramfs_init_fs_context,
+	.parameters	= &ramfs_fs_parameters,
 #endif
-}
-
-static struct file_system_type dev_fs_type = {
-	.name = "devtmpfs",
-	.mount = dev_mount,
 	.kill_sb = kill_litter_super,
 };
 
diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index 11201b2d06b9..01170dd6c95f 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -36,6 +36,8 @@
 #include <linux/magic.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
+#include <linux/fs_context.h>
+#include <linux/fs_parser.h>
 #include "internal.h"
 
 struct ramfs_mount_opts {
@@ -175,62 +177,52 @@ static const struct super_operations ramfs_ops = {
 	.show_options	= ramfs_show_options,
 };
 
-enum {
+enum ramfs_param {
 	Opt_mode,
-	Opt_err
 };
 
-static const match_table_t tokens = {
-	{Opt_mode, "mode=%o"},
-	{Opt_err, NULL}
+static const struct fs_parameter_spec ramfs_param_specs[] = {
+	fsparam_u32oct("mode",	Opt_mode),
+	{}
 };
 
-static int ramfs_parse_options(char *data, struct ramfs_mount_opts *opts)
+const struct fs_parameter_description ramfs_fs_parameters = {
+	.name		= "ramfs",
+	.specs		= ramfs_param_specs,
+};
+
+static int ramfs_parse_param(struct fs_context *fc, struct fs_parameter *param)
 {
-	substring_t args[MAX_OPT_ARGS];
-	int option;
-	int token;
-	char *p;
-
-	opts->mode = RAMFS_DEFAULT_MODE;
-
-	while ((p = strsep(&data, ",")) != NULL) {
-		if (!*p)
-			continue;
-
-		token = match_token(p, tokens, args);
-		switch (token) {
-		case Opt_mode:
-			if (match_octal(&args[0], &option))
-				return -EINVAL;
-			opts->mode = option & S_IALLUGO;
-			break;
+	struct fs_parse_result result;
+	struct ramfs_fs_info *fsi = fc->s_fs_info;
+	int opt;
+
+	opt = fs_parse(fc, &ramfs_fs_parameters, param, &result);
+	if (opt < 0) {
 		/*
 		 * We might like to report bad mount options here;
 		 * but traditionally ramfs has ignored all mount options,
 		 * and as it is used as a !CONFIG_SHMEM simple substitute
 		 * for tmpfs, better continue to ignore other mount options.
 		 */
-		}
+		if (opt == -ENOPARAM)
+			opt = 0;
+		return opt;
+	}
+
+	switch (opt) {
+	case Opt_mode:
+		fsi->mount_opts.mode = result.uint_32 & S_IALLUGO;
+		break;
 	}
 
 	return 0;
 }
 
-int ramfs_fill_super(struct super_block *sb, void *data, int silent)
+static int ramfs_fill_super(struct super_block *sb, struct fs_context *fc)
 {
-	struct ramfs_fs_info *fsi;
+	struct ramfs_fs_info *fsi = sb->s_fs_info;
 	struct inode *inode;
-	int err;
-
-	fsi = kzalloc(sizeof(struct ramfs_fs_info), GFP_KERNEL);
-	sb->s_fs_info = fsi;
-	if (!fsi)
-		return -ENOMEM;
-
-	err = ramfs_parse_options(data, &fsi->mount_opts);
-	if (err)
-		return err;
 
 	sb->s_maxbytes		= MAX_LFS_FILESIZE;
 	sb->s_blocksize		= PAGE_SIZE;
@@ -247,10 +239,39 @@ int ramfs_fill_super(struct super_block *sb, void *data, int silent)
 	return 0;
 }
 
-struct dentry *ramfs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static int ramfs_get_tree(struct fs_context *fc)
 {
-	return mount_nodev(fs_type, flags, data, ramfs_fill_super);
+	enum vfs_get_super_keying keying = vfs_get_independent_super;
+
+	if (strcmp(fc->fs_type->name, "devtmpfs") == 0)
+		keying = vfs_get_single_super;
+
+	return vfs_get_super(fc, keying, ramfs_fill_super);
+}
+
+static void ramfs_free_fc(struct fs_context *fc)
+{
+	kfree(fc->s_fs_info);
+}
+
+static const struct fs_context_operations ramfs_context_ops = {
+	.free		= ramfs_free_fc,
+	.parse_param	= ramfs_parse_param,
+	.get_tree	= ramfs_get_tree,
+};
+
+int ramfs_init_fs_context(struct fs_context *fc)
+{
+	struct ramfs_fs_info *fsi;
+
+	fsi = kzalloc(sizeof(*fsi), GFP_KERNEL);
+	if (!fsi)
+		return -ENOMEM;
+
+	fsi->mount_opts.mode = RAMFS_DEFAULT_MODE;
+	fc->s_fs_info = fsi;
+	fc->ops = &ramfs_context_ops;
+	return 0;
 }
 
 static void ramfs_kill_sb(struct super_block *sb)
@@ -261,7 +282,8 @@ static void ramfs_kill_sb(struct super_block *sb)
 
 static struct file_system_type ramfs_fs_type = {
 	.name		= "ramfs",
-	.mount		= ramfs_mount,
+	.init_fs_context = ramfs_init_fs_context,
+	.parameters	= &ramfs_fs_parameters,
 	.kill_sb	= ramfs_kill_sb,
 	.fs_flags	= FS_USERNS_MOUNT,
 };
diff --git a/include/linux/ramfs.h b/include/linux/ramfs.h
index 5ef7d54caac2..94b407424cb7 100644
--- a/include/linux/ramfs.h
+++ b/include/linux/ramfs.h
@@ -4,8 +4,7 @@
 
 struct inode *ramfs_get_inode(struct super_block *sb, const struct inode *dir,
 	 umode_t mode, dev_t dev);
-extern struct dentry *ramfs_mount(struct file_system_type *fs_type,
-	 int flags, const char *dev_name, void *data);
+extern int ramfs_init_fs_context(struct fs_context *fc);
 
 #ifdef CONFIG_MMU
 static inline int
@@ -17,10 +16,9 @@ ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 extern int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize);
 #endif
 
+extern const struct fs_parameter_description ramfs_fs_parameters;
 extern const struct file_operations ramfs_file_operations;
 extern const struct vm_operations_struct generic_file_vm_ops;
 extern int __init init_ramfs_fs(void);
 
-int ramfs_fill_super(struct super_block *sb, void *data, int silent);
-
 #endif
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index f3fb1edb3526..3f73c00081e8 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -48,8 +48,10 @@ static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
 /*
  * Functions in mm/shmem.c called directly from elsewhere:
  */
+extern const struct fs_parameter_description shmem_fs_parameters;
+
 extern int shmem_init(void);
-extern int shmem_fill_super(struct super_block *sb, void *data, int silent);
+extern int shmem_init_fs_context(struct fs_context *fc);
 extern struct file *shmem_file_setup(const char *name,
 					loff_t size, unsigned long flags);
 extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
diff --git a/init/do_mounts.c b/init/do_mounts.c
index f8c230c77035..8242abd47e3f 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -626,24 +626,22 @@ void __init prepare_namespace(void)
 }
 
 static bool is_tmpfs;
-static struct dentry *rootfs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static int rootfs_init_fs_context(struct fs_context *fc)
 {
 	static unsigned long once;
-	void *fill = ramfs_fill_super;
 
 	if (test_and_set_bit(0, &once))
-		return ERR_PTR(-ENODEV);
+		return -ENODEV;
 
 	if (IS_ENABLED(CONFIG_TMPFS) && is_tmpfs)
-		fill = shmem_fill_super;
+		return shmem_init_fs_context(fc);
 
-	return mount_nodev(fs_type, flags, data, fill);
+	return ramfs_init_fs_context(fc);
 }
 
 static struct file_system_type rootfs_fs_type = {
 	.name		= "rootfs",
-	.mount		= rootfs_mount,
+	.init_fs_context = rootfs_init_fs_context,
 	.kill_sb	= kill_litter_super,
 };
 
diff --git a/mm/shmem.c b/mm/shmem.c
index b3db3779a30a..5f45a710ee04 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -37,6 +37,8 @@
 #include <linux/khugepaged.h>
 #include <linux/hugetlb.h>
 #include <linux/frontswap.h>
+#include <linux/fs_context.h>
+#include <linux/fs_parser.h>
 
 #include <asm/tlbflush.h> /* for arch/microblaze update_mmu_cache() */
 
@@ -85,6 +87,17 @@ static struct vfsmount *shm_mnt;
 
 #include "internal.h"
 
+struct shmem_fs_context {
+	unsigned long	changes;
+	unsigned long	max_blocks;	/* How many blocks are allowed */
+	unsigned long	max_inodes;	/* How many inodes are allowed */
+	kuid_t		uid;
+	kgid_t		gid;
+	int		huge;
+	umode_t		mode;
+	struct mempolicy *mpol;		/* default memory policy for mappings */
+};
+
 #define BLOCKS_PER_PAGE  (PAGE_SIZE/512)
 #define VM_ACCT(size)    (PAGE_ALIGN(size) >> PAGE_SHIFT)
 
@@ -3351,16 +3364,13 @@ static const struct export_operations shmem_export_ops = {
 	.fh_to_dentry	= shmem_fh_to_dentry,
 };
 
-static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
-			       bool remount)
+static int shmem_parse_monolithic(struct fs_context *fc, void *data)
 {
-	char *this_char, *value, *rest;
-	struct mempolicy *mpol = NULL;
-	uid_t uid;
-	gid_t gid;
+	char *options = data, *key;
+	int ret = 0;
 
 	while (options != NULL) {
-		this_char = options;
+		key = options;
 		for (;;) {
 			/*
 			 * NUL-terminate this option: unfortunately,
@@ -3376,139 +3386,219 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 				break;
 			}
 		}
-		if (!*this_char)
-			continue;
-		if ((value = strchr(this_char,'=')) != NULL) {
-			*value++ = 0;
-		} else {
-			pr_err("tmpfs: No value for mount option '%s'\n",
-			       this_char);
-			goto error;
-		}
 
-		if (!strcmp(this_char,"size")) {
-			unsigned long long size;
-			size = memparse(value,&rest);
-			if (*rest == '%') {
-				size <<= PAGE_SHIFT;
-				size *= totalram_pages();
-				do_div(size, 100);
-				rest++;
+		if (*key) {
+			size_t v_len = 0;
+			char *value = strchr(key, '=');
+
+			if (value) {
+				if (value == key)
+					continue;
+				*value++ = 0;
+				v_len = strlen(value);
 			}
-			if (*rest)
-				goto bad_val;
-			sbinfo->max_blocks =
-				DIV_ROUND_UP(size, PAGE_SIZE);
-		} else if (!strcmp(this_char,"nr_blocks")) {
-			sbinfo->max_blocks = memparse(value, &rest);
-			if (*rest)
-				goto bad_val;
-		} else if (!strcmp(this_char,"nr_inodes")) {
-			sbinfo->max_inodes = memparse(value, &rest);
-			if (*rest)
-				goto bad_val;
-		} else if (!strcmp(this_char,"mode")) {
-			if (remount)
-				continue;
-			sbinfo->mode = simple_strtoul(value, &rest, 8) & 07777;
-			if (*rest)
-				goto bad_val;
-		} else if (!strcmp(this_char,"uid")) {
-			if (remount)
-				continue;
-			uid = simple_strtoul(value, &rest, 0);
-			if (*rest)
-				goto bad_val;
-			sbinfo->uid = make_kuid(current_user_ns(), uid);
-			if (!uid_valid(sbinfo->uid))
-				goto bad_val;
-		} else if (!strcmp(this_char,"gid")) {
-			if (remount)
-				continue;
-			gid = simple_strtoul(value, &rest, 0);
-			if (*rest)
-				goto bad_val;
-			sbinfo->gid = make_kgid(current_user_ns(), gid);
-			if (!gid_valid(sbinfo->gid))
-				goto bad_val;
+			ret = vfs_parse_fs_string(fc, key, value, v_len);
+			if (ret < 0)
+				break;
+		}
+	}
+
+	return ret;
+}
+
+enum shmem_param {
+	Opt_gid,
+	Opt_huge,
+	Opt_mode,
+	Opt_mpol,
+	Opt_nr_blocks,
+	Opt_nr_inodes,
+	Opt_size,
+	Opt_uid,
+};
+
+static const struct fs_parameter_spec shmem_param_specs[] = {
+	fsparam_u32   ("gid",		Opt_gid),
+	fsparam_enum  ("huge",		Opt_huge),
+	fsparam_u32oct("mode",		Opt_mode),
+	fsparam_string("mpol",		Opt_mpol),
+	fsparam_string("nr_blocks",	Opt_nr_blocks),
+	fsparam_string("nr_inodes",	Opt_nr_inodes),
+	fsparam_string("size",		Opt_size),
+	fsparam_u32   ("uid",		Opt_uid),
+	{}
+};
+
+static const struct fs_parameter_enum shmem_param_enums[] = {
+	{ Opt_huge,	"never",	SHMEM_HUGE_NEVER },
+	{ Opt_huge,	"always",	SHMEM_HUGE_ALWAYS },
+	{ Opt_huge,	"within_size",	SHMEM_HUGE_WITHIN_SIZE },
+	{ Opt_huge,	"advise",	SHMEM_HUGE_ADVISE },
+	{ Opt_huge,	"deny",		SHMEM_HUGE_DENY },
+	{ Opt_huge,	"force",	SHMEM_HUGE_FORCE },
+	{}
+};
+
+const struct fs_parameter_description shmem_fs_parameters = {
+	.name		= "shmem",
+	.specs		= shmem_param_specs,
+	.enums		= shmem_param_enums,
+};
+
+static void shmem_apply_options(struct shmem_sb_info *sbinfo,
+				struct fs_context *fc,
+				unsigned long inodes_in_use)
+{
+	struct shmem_fs_context *ctx = fc->fs_private;
+	struct mempolicy *old = NULL;
+
+	if (test_bit(Opt_nr_blocks, &ctx->changes))
+		sbinfo->max_blocks = ctx->max_blocks;
+	if (test_bit(Opt_nr_inodes, &ctx->changes)) {
+		sbinfo->max_inodes = ctx->max_inodes;
+		sbinfo->free_inodes = ctx->max_inodes - inodes_in_use;
+	}
+	if (test_bit(Opt_huge, &ctx->changes))
+		sbinfo->huge = ctx->huge;
+	if (test_bit(Opt_mpol, &ctx->changes)) {
+		old = sbinfo->mpol;
+		sbinfo->mpol = ctx->mpol;
+	}
+
+	if (fc->purpose != FS_CONTEXT_FOR_RECONFIGURE) {
+		if (test_bit(Opt_uid, &ctx->changes))
+			sbinfo->uid = ctx->uid;
+		if (test_bit(Opt_gid, &ctx->changes))
+			sbinfo->gid = ctx->gid;
+		if (test_bit(Opt_mode, &ctx->changes))
+			sbinfo->mode = ctx->mode;
+	}
+
+	mpol_put(old);
+}
+
+static int shmem_parse_param(struct fs_context *fc, struct fs_parameter *param)
+{
+	struct shmem_fs_context *ctx = fc->fs_private;
+	struct fs_parse_result result;
+	unsigned long long size;
+	struct mempolicy *mpol;
+	char *rest;
+	int opt;
+
+	opt = fs_parse(fc, &shmem_fs_parameters, param, &result);
+	if (opt < 0)
+		return opt;
+
+	switch (opt) {
+	case Opt_size:
+		rest = param->string;
+		size = memparse(param->string, &rest);
+		if (*rest == '%') {
+			size <<= PAGE_SHIFT;
+			size *= totalram_pages();
+			do_div(size, 100);
+			rest++;
+		}
+		if (*rest)
+			return invalf(fc, "shmem: Invalid size");
+		ctx->max_blocks = DIV_ROUND_UP(size, PAGE_SIZE);
+		break;
+
+	case Opt_nr_blocks:
+		rest = param->string;
+		ctx->max_blocks = memparse(param->string, &rest);
+		if (*rest)
+			return invalf(fc, "shmem: Invalid nr_blocks");
+		break;
+	case Opt_nr_inodes:
+		rest = param->string;
+		ctx->max_inodes = memparse(param->string, &rest);
+		if (*rest)
+			return invalf(fc, "shmem: Invalid nr_inodes");
+		break;
+	case Opt_mode:
+		ctx->mode = result.uint_32 & 07777;
+		break;
+	case Opt_uid:
+		ctx->uid = make_kuid(current_user_ns(), result.uint_32);
+		if (!uid_valid(ctx->uid))
+			return invalf(fc, "shmem: Invalid uid");
+		break;
+
+	case Opt_gid:
+		ctx->gid = make_kgid(current_user_ns(), result.uint_32);
+		if (!gid_valid(ctx->gid))
+			return invalf(fc, "shmem: Invalid gid");
+		break;
+
+	case Opt_huge:
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
-		} else if (!strcmp(this_char, "huge")) {
-			int huge;
-			huge = shmem_parse_huge(value);
-			if (huge < 0)
-				goto bad_val;
-			if (!has_transparent_hugepage() &&
-					huge != SHMEM_HUGE_NEVER)
-				goto bad_val;
-			sbinfo->huge = huge;
+		if (!has_transparent_hugepage() &&
+		    result.uint_32 != SHMEM_HUGE_NEVER)
+			return invalf(fc, "shmem: Huge pages disabled");
+
+		ctx->huge = result.uint_32;
+		break;
+#else
+		return invalf(fc, "shmem: huge= option disabled");
 #endif
+
+	case Opt_mpol:
 #ifdef CONFIG_NUMA
-		} else if (!strcmp(this_char,"mpol")) {
-			mpol_put(mpol);
-			mpol = NULL;
-			if (mpol_parse_str(value, &mpol))
-				goto bad_val;
+		if (mpol_parse_str(param->string, &mpol))
+			return invalf(fc, "shmem: Invalid mpol=");
+		mpol_put(ctx->mpol);
+		ctx->mpol = mpol;
 #endif
-		} else {
-			pr_err("tmpfs: Bad mount option %s\n", this_char);
-			goto error;
-		}
+		break;
 	}
-	sbinfo->mpol = mpol;
-	return 0;
-
-bad_val:
-	pr_err("tmpfs: Bad value '%s' for mount option '%s'\n",
-	       value, this_char);
-error:
-	mpol_put(mpol);
-	return 1;
 
+	__set_bit(opt, &ctx->changes);
+	return 0;
 }
 
-static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
+/*
+ * Reconfigure a shmem filesystem.
+ *
+ * Note that we disallow change from limited->unlimited blocks/inodes while any
+ * are in use; but we must separately disallow unlimited->limited, because in
+ * that case we have no record of how much is already in use.
+ */
+static int shmem_reconfigure(struct fs_context *fc)
 {
+	struct shmem_fs_context *ctx = fc->fs_private;
+	struct super_block *sb = fc->root->d_sb;
 	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
-	struct shmem_sb_info config = *sbinfo;
-	unsigned long inodes;
-	int error = -EINVAL;
-
-	config.mpol = NULL;
-	if (shmem_parse_options(data, &config, true))
-		return error;
+	unsigned long inodes_in_use;
 
 	spin_lock(&sbinfo->stat_lock);
-	inodes = sbinfo->max_inodes - sbinfo->free_inodes;
-	if (percpu_counter_compare(&sbinfo->used_blocks, config.max_blocks) > 0)
-		goto out;
-	if (config.max_inodes < inodes)
-		goto out;
-	/*
-	 * Those tests disallow limited->unlimited while any are in use;
-	 * but we must separately disallow unlimited->limited, because
-	 * in that case we have no record of how much is already in use.
-	 */
-	if (config.max_blocks && !sbinfo->max_blocks)
-		goto out;
-	if (config.max_inodes && !sbinfo->max_inodes)
-		goto out;
-
-	error = 0;
-	sbinfo->huge = config.huge;
-	sbinfo->max_blocks  = config.max_blocks;
-	sbinfo->max_inodes  = config.max_inodes;
-	sbinfo->free_inodes = config.max_inodes - inodes;
+	if (test_bit(Opt_nr_blocks, &ctx->changes)) {
+		if (ctx->max_blocks && !sbinfo->max_blocks) {
+			spin_unlock(&sbinfo->stat_lock);
+			return invalf(fc, "shmem: Can't retroactively limit nr_blocks");
+		}
+		if (percpu_counter_compare(&sbinfo->used_blocks, ctx->max_blocks) > 0) {
+			spin_unlock(&sbinfo->stat_lock);
+			return invalf(fc, "shmem: Too few blocks for current use");
+		}
+	}
 
-	/*
-	 * Preserve previous mempolicy unless mpol remount option was specified.
-	 */
-	if (config.mpol) {
-		mpol_put(sbinfo->mpol);
-		sbinfo->mpol = config.mpol;	/* transfers initial ref */
+	inodes_in_use = sbinfo->max_inodes - sbinfo->free_inodes;
+	if (test_bit(Opt_nr_inodes, &ctx->changes)) {
+		if (ctx->max_inodes && !sbinfo->max_inodes) {
+			spin_unlock(&sbinfo->stat_lock);
+			return invalf(fc, "shmem: Can't retroactively limit nr_inodes");
+		}
+		if (ctx->max_inodes < inodes_in_use) {
+			spin_unlock(&sbinfo->stat_lock);
+			return invalf(fc, "shmem: Too few inodes for current use");
+		}
 	}
-out:
+
+	shmem_apply_options(sbinfo, fc, inodes_in_use);
 	spin_unlock(&sbinfo->stat_lock);
-	return error;
+	return 0;
 }
 
 static int shmem_show_options(struct seq_file *seq, struct dentry *root)
@@ -3549,7 +3639,7 @@ static void shmem_put_super(struct super_block *sb)
 	sb->s_fs_info = NULL;
 }
 
-int shmem_fill_super(struct super_block *sb, void *data, int silent)
+static int shmem_fill_super(struct super_block *sb, struct fs_context *fc)
 {
 	struct inode *inode;
 	struct shmem_sb_info *sbinfo;
@@ -3575,10 +3665,7 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	if (!(sb->s_flags & SB_KERNMOUNT)) {
 		sbinfo->max_blocks = shmem_default_max_blocks();
 		sbinfo->max_inodes = shmem_default_max_inodes();
-		if (shmem_parse_options(data, sbinfo, false)) {
-			err = -EINVAL;
-			goto failed;
-		}
+		shmem_apply_options(sbinfo, fc, 0);
 	} else {
 		sb->s_flags |= SB_NOUSER;
 	}
@@ -3624,6 +3711,36 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	return err;
 }
 
+static int shmem_get_tree(struct fs_context *fc)
+{
+	enum vfs_get_super_keying keying = vfs_get_independent_super;
+
+	if (strcmp(fc->fs_type->name, "devtmpfs") == 0)
+		keying = vfs_get_single_super;
+
+	return vfs_get_super(fc, keying, shmem_fill_super);
+}
+
+static void shmem_free_fc(struct fs_context *fc)
+{
+	struct shmem_fs_context *ctx = fc->fs_private;
+
+	if (ctx) {
+		mpol_put(ctx->mpol);
+		kfree(ctx);
+	}
+}
+
+static const struct fs_context_operations shmem_fs_context_ops = {
+	.free			= shmem_free_fc,
+	.get_tree		= shmem_get_tree,
+#ifdef CONFIG_TMPFS
+	.parse_monolithic	= shmem_parse_monolithic,
+	.parse_param		= shmem_parse_param,
+	.reconfigure		= shmem_reconfigure,
+#endif
+};
+
 static struct kmem_cache *shmem_inode_cachep;
 
 static struct inode *shmem_alloc_inode(struct super_block *sb)
@@ -3741,7 +3858,6 @@ static const struct super_operations shmem_ops = {
 	.destroy_inode	= shmem_destroy_inode,
 #ifdef CONFIG_TMPFS
 	.statfs		= shmem_statfs,
-	.remount_fs	= shmem_remount_fs,
 	.show_options	= shmem_show_options,
 #endif
 	.evict_inode	= shmem_evict_inode,
@@ -3762,16 +3878,26 @@ static const struct vm_operations_struct shmem_vm_ops = {
 #endif
 };
 
-static struct dentry *shmem_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+int shmem_init_fs_context(struct fs_context *fc)
 {
-	return mount_nodev(fs_type, flags, data, shmem_fill_super);
+	struct shmem_fs_context *ctx;
+
+	ctx = kzalloc(sizeof(struct shmem_fs_context), GFP_KERNEL);
+	if (!ctx)
+		return -ENOMEM;
+
+	fc->fs_private = ctx;
+	fc->ops = &shmem_fs_context_ops;
+	return 0;
 }
 
 static struct file_system_type shmem_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "tmpfs",
-	.mount		= shmem_mount,
+	.init_fs_context = shmem_init_fs_context,
+#ifdef CONFIG_TMPFS
+	.parameters	= &shmem_fs_parameters,
+#endif
 	.kill_sb	= kill_litter_super,
 	.fs_flags	= FS_USERNS_MOUNT,
 };
@@ -3916,7 +4042,8 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 
 static struct file_system_type shmem_fs_type = {
 	.name		= "tmpfs",
-	.mount		= ramfs_mount,
+	.init_fs_context = ramfs_init_fs_context,
+	.parameters	= &ramfs_fs_parameters,
 	.kill_sb	= kill_litter_super,
 	.fs_flags	= FS_USERNS_MOUNT,
 };
@@ -4117,3 +4244,4 @@ struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 #endif
 }
 EXPORT_SYMBOL_GPL(shmem_read_mapping_page_gfp);
+

