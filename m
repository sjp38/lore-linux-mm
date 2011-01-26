Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0B58D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:30:18 -0500 (EST)
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH 5/6] fs: use appropriate printk priority level
Date: Wed, 26 Jan 2011 15:29:29 -0800
Message-Id: <1296084570-31453-6-git-send-email-msb@chromium.org>
In-Reply-To: <20110125235700.GR8008@google.com>
References: <20110125235700.GR8008@google.com>
Sender: owner-linux-mm@kvack.org
To: gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>
List-ID: <linux-mm.kvack.org>

printk()s without a priority level default to KERN_WARNING. To reduce
noise at KERN_WARNING, this patch set the priority level appriopriately
for unleveled printks()s. This should be useful to folks that look at
dmesg warnings closely.

Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 fs/bio.c         |    2 +-
 fs/namespace.c   |    2 +-
 init/do_mounts.c |    3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/bio.c b/fs/bio.c
index 4bd454f..4cf2a52 100644
--- a/fs/bio.c
+++ b/fs/bio.c
@@ -111,7 +111,7 @@ static struct kmem_cache *bio_find_or_create_slab(unsigned int extra_size)
 	if (!slab)
 		goto out_unlock;
 
-	printk("bio: create slab <%s> at %d\n", bslab->name, entry);
+	printk(KERN_INFO "bio: create slab <%s> at %d\n", bslab->name, entry);
 	bslab->slab = slab;
 	bslab->slab_ref = 1;
 	bslab->slab_size = sz;
diff --git a/fs/namespace.c b/fs/namespace.c
index 7b0b953..c81bcd9 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2594,7 +2594,7 @@ void __init mnt_init(void)
 	if (!mount_hashtable)
 		panic("Failed to allocate mount hash table\n");
 
-	printk("Mount-cache hash table entries: %lu\n", HASH_SIZE);
+	printk(KERN_INFO "Mount-cache hash table entries: %lu\n", HASH_SIZE);
 
 	for (u = 0; u < HASH_SIZE; u++)
 		INIT_LIST_HEAD(&mount_hashtable[u]);
diff --git a/init/do_mounts.c b/init/do_mounts.c
index 2b54bef..3e01121 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -293,7 +293,8 @@ static int __init do_mount_root(char *name, char *fs, int flags, void *data)
 
 	sys_chdir((const char __user __force *)"/root");
 	ROOT_DEV = current->fs->pwd.mnt->mnt_sb->s_dev;
-	printk("VFS: Mounted root (%s filesystem)%s on device %u:%u.\n",
+	printk(KERN_INFO
+	       "VFS: Mounted root (%s filesystem)%s on device %u:%u.\n",
 	       current->fs->pwd.mnt->mnt_sb->s_type->name,
 	       current->fs->pwd.mnt->mnt_sb->s_flags & MS_RDONLY ?
 	       " readonly" : "", MAJOR(ROOT_DEV), MINOR(ROOT_DEV));
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
