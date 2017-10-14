Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6D26B0275
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 20:31:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k7so1874424wre.5
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 17:31:58 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id c36si1698689wrg.161.2017.10.13.17.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 17:31:56 -0700 (PDT)
Date: Sat, 14 Oct 2017 01:31:51 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 1/4] cramfs: direct memory access support
Message-ID: <20171014003151.GK21978@ZenIV.linux.org.uk>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org>
 <20171012061613.28705-2-nicolas.pitre@linaro.org>
 <20171013172934.GG21978@ZenIV.linux.org.uk>
 <nycvar.YSQ.7.76.1710131332360.1718@knanqh.ubzr>
 <20171013175208.GI21978@ZenIV.linux.org.uk>
 <nycvar.YSQ.7.76.1710131532291.1750@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710131532291.1750@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

On Fri, Oct 13, 2017 at 04:09:23PM -0400, Nicolas Pitre wrote:
> On Fri, 13 Oct 2017, Al Viro wrote:
> 
> > OK...  I wonder if it should simply define stubs for kill_mtd_super(),
> > mtd_unpoint() and kill_block_super() in !CONFIG_MTD and !CONFIG_BLOCK
> > cases.  mount_mtd() and mount_bdev() as well - e.g.  mount_bdev()
> > returning ERR_PTR(-ENODEV) and kill_block_super() being simply BUG()
> > in !CONFIG_BLOCK case.  Then cramfs_kill_sb() would be
> > 	if (sb->s_mtd) {
> > 		if (sbi->mtd_point_size)
> > 			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
> > 		kill_mtd_super(sb);
> > 	} else {
> > 		kill_block_super(sb);
> > 	}
> > 	kfree(sbi);
> 
> Well... Stubs have to be named differently or they conflict with 
> existing declarations. At that point that makes for more lines of code 
> compared to the current patch and the naming indirection makes it less 
> obvious when reading the code. Alternatively I could add those stubs in 
> the corresponding header files and #ifdef the existing declarations 
> away. That might look somewhat less cluttered in the main code but it 
> also hides what is actually going on and left me unconvinced. And I'm 
> not sure this is worth it in the end given this is not a common 
> occurrence in the kernel either.

What I mean is this (completely untested) for CONFIG_BLOCK side of things,
with something similar for CONFIG_MTD one:

Provide definitions of mount_bdev/kill_block_super() in case !CONFIG_BLOCK

mount_bdev() and kill_block_super() are defined only when CONFIG_BLOCK is
defined; however, their declarations in fs.h are unconditional.  We could
make these conditional upon CONFIG_BLOCK as well, but it's easy to provide
inline definitions for !CONFIG_BLOCK case - mount_bdev() should fail with
ENODEV, while kill_block_super() can be simply BUG(); there should be no
superblock instances with non-NULL ->s_bdev on such configs.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 339e73742e73..e773c1c51aad 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2094,9 +2094,18 @@ struct file_system_type {
 extern struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
 	int (*fill_super)(struct super_block *, void *, int));
+#ifdef CONFIG_BLOCK
 extern struct dentry *mount_bdev(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data,
 	int (*fill_super)(struct super_block *, void *, int));
+#else
+static inline struct dentry *mount_bdev(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *data,
+	int (*fill_super)(struct super_block *, void *, int))
+{
+	return ERR_PTR(-ENODEV);
+}
+#endif
 extern struct dentry *mount_single(struct file_system_type *fs_type,
 	int flags, void *data,
 	int (*fill_super)(struct super_block *, void *, int));
@@ -2105,7 +2114,14 @@ extern struct dentry *mount_nodev(struct file_system_type *fs_type,
 	int (*fill_super)(struct super_block *, void *, int));
 extern struct dentry *mount_subtree(struct vfsmount *mnt, const char *path);
 void generic_shutdown_super(struct super_block *sb);
+#ifdef CONFIG_BLOCK
 void kill_block_super(struct super_block *sb);
+#else
+static inline void kill_block_super(struct super_block *sb)
+{
+	BUG();
+}
+#endif
 void kill_anon_super(struct super_block *sb);
 void kill_litter_super(struct super_block *sb);
 void deactivate_super(struct super_block *sb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
