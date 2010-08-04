Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 917B662012A
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 04:49:45 -0400 (EDT)
Subject: RE: scalability investigation: Where can I get your latest patches?
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <F4DF93C7785E2549970341072BC32CD78D8FC0CC@irsmsx503.ger.corp.intel.com>
References: <1278579387.2096.889.camel@ymzhang.sh.intel.com>
	 <20100720031201.GC21274@amd>
	 <1280883843.2125.20.camel@ymzhang.sh.intel.com>
	 <F4DF93C7785E2549970341072BC32CD78D8FC01B@irsmsx503.ger.corp.intel.com>
	 <1280908717.2125.33.camel@ymzhang.sh.intel.com>
	 <F4DF93C7785E2549970341072BC32CD78D8FC0CC@irsmsx503.ger.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 04 Aug 2010 16:50:23 +0800
Message-Id: <1280911823.2125.35.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kleen, Andi" <andi.kleen@intel.com>
Cc: Nick Piggin <npiggin@suse.de>, "Shi, Alex" <alex.shi@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-08-04 at 09:06 +0100, Kleen, Andi wrote:
> > > I believe the latest version of Nick's patchkit has a likely fix for
> > that.
> > >
> > > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-
> > npiggin.git;a=commitdiff;h=9edd35f9aeafc8a5e1688b84cf4488a94898ca45
> > 
> > Thanks Andi. The patch has no ext3 part.
> 
> Good point. But perhaps the ext2 patch can be adapted. The ACL code
> should be similar in ext2 and ext3 (and 4)
I ported ext2 part to ext3. aim7 testing on Nehalem EX 4 socket machine
shows the regression disappears.

---

diff -Nraup linux-2.6.35-rc5_nick/fs/ext3/acl.c linux-2.6.35-rc5_npymz/fs/ext3/acl.c
--- linux-2.6.35-rc5_nick/fs/ext3/acl.c	2010-08-05 16:23:19.000000000 +0800
+++ linux-2.6.35-rc5_npymz/fs/ext3/acl.c	2010-08-05 15:47:38.000000000 +0800
@@ -240,13 +240,21 @@ ext3_set_acl(handle_t *handle, struct in
 }
 
 int
-ext3_check_acl(struct inode *inode, int mask)
+ext3_check_acl_rcu(struct inode *inode, int mask, unsigned int flags)
 {
-	struct posix_acl *acl = ext3_get_acl(inode, ACL_TYPE_ACCESS);
+	struct posix_acl *acl;
 
-	if (IS_ERR(acl))
-		return PTR_ERR(acl);
-	if (acl) {
+	if (flags & IPERM_FLAG_RCU) {
+		if (!negative_cached_acl(inode, ACL_TYPE_ACCESS))
+			return -ECHILD;
+		return -EAGAIN;
+	}
+
+       acl = ext3_get_acl(inode, ACL_TYPE_ACCESS);
+       if (IS_ERR(acl))
+                return PTR_ERR(acl);
+
+        if (acl) {
 		int error = posix_acl_permission(inode, acl, mask);
 		posix_acl_release(acl);
 		return error;
diff -Nraup linux-2.6.35-rc5_nick/fs/ext3/acl.h linux-2.6.35-rc5_npymz/fs/ext3/acl.h
--- linux-2.6.35-rc5_nick/fs/ext3/acl.h	2010-08-05 16:23:19.000000000 +0800
+++ linux-2.6.35-rc5_npymz/fs/ext3/acl.h	2010-08-05 15:48:51.000000000 +0800
@@ -54,7 +54,7 @@ static inline int ext3_acl_count(size_t 
 #ifdef CONFIG_EXT3_FS_POSIX_ACL
 
 /* acl.c */
-extern int ext3_check_acl (struct inode *, int);
+extern int ext3_check_acl_rcu(struct inode *inode, int mask, unsigned int flags);
 extern int ext3_acl_chmod (struct inode *);
 extern int ext3_init_acl (handle_t *, struct inode *, struct inode *);
 
diff -Nraup linux-2.6.35-rc5_nick/fs/ext3/file.c linux-2.6.35-rc5_npymz/fs/ext3/file.c
--- linux-2.6.35-rc5_nick/fs/ext3/file.c	2010-08-05 16:23:19.000000000 +0800
+++ linux-2.6.35-rc5_npymz/fs/ext3/file.c	2010-08-05 15:52:39.000000000 +0800
@@ -79,7 +79,7 @@ const struct inode_operations ext3_file_
 	.listxattr	= ext3_listxattr,
 	.removexattr	= generic_removexattr,
 #endif
-	.check_acl	= ext3_check_acl,
+	.check_acl_rcu	= ext3_check_acl_rcu,
 	.fiemap		= ext3_fiemap,
 };
 
diff -Nraup linux-2.6.35-rc5_nick/fs/ext3/namei.c linux-2.6.35-rc5_npymz/fs/ext3/namei.c
--- linux-2.6.35-rc5_nick/fs/ext3/namei.c	2010-08-05 16:25:08.000000000 +0800
+++ linux-2.6.35-rc5_npymz/fs/ext3/namei.c	2010-08-05 16:01:47.000000000 +0800
@@ -2465,7 +2465,7 @@ const struct inode_operations ext3_dir_i
 	.listxattr	= ext3_listxattr,
 	.removexattr	= generic_removexattr,
 #endif
-	.check_acl	= ext3_check_acl,
+	.check_acl_rcu	= ext3_check_acl_rcu,
 };
 
 const struct inode_operations ext3_special_inode_operations = {
@@ -2476,5 +2476,5 @@ const struct inode_operations ext3_speci
 	.listxattr	= ext3_listxattr,
 	.removexattr	= generic_removexattr,
 #endif
-	.check_acl	= ext3_check_acl,
+	.check_acl_rcu	= ext3_check_acl_rcu,
 };


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
