Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 500E36B0005
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 02:11:54 -0500 (EST)
Received: by mail-yh0-f74.google.com with SMTP id z6so757151yhz.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 23:11:53 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/2] tmpfs: fix mempolicy object leaks
Date: Tue, 19 Feb 2013 23:11:42 -0800
Message-Id: <1361344302-26565-2-git-send-email-gthelen@google.com>
In-Reply-To: <1361344302-26565-1-git-send-email-gthelen@google.com>
References: <1361344302-26565-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

This patch fixes several mempolicy leaks in the tmpfs mount logic.
These leaks are slow - on the order of one object leaked per mount
attempt.

Leak 1 (umount doesn't free mpol allocated in mount):
    while true; do
        mount -t tmpfs -o mpol=interleave,size=100M nodev /mnt
        umount /mnt
    done

Leak 2 (errors parsing remount options will leak mpol):
    mount -t tmpfs -o size=100M nodev /mnt
    while true; do
        mount -o remount,mpol=interleave,size=x /mnt 2> /dev/null
    done
    umount /mnt

Leak 3 (multiple mpol per mount leak mpol):
    while true; do
        mount -t tmpfs -o mpol=interleave,mpol=interleave,size=100M nodev /mnt
        umount /mnt
    done

This patch fixes all of the above.  I could have broken the patch into
three pieces but is seemed easier to review as one.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/shmem.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index efd0b3a..ed2cb26 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2386,6 +2386,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			       bool remount)
 {
 	char *this_char, *value, *rest;
+	struct mempolicy *mpol = NULL;
 	uid_t uid;
 	gid_t gid;
 
@@ -2414,7 +2415,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			printk(KERN_ERR
 			    "tmpfs: No value for mount option '%s'\n",
 			    this_char);
-			return 1;
+			goto error;
 		}
 
 		if (!strcmp(this_char,"size")) {
@@ -2463,19 +2464,23 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			if (!gid_valid(sbinfo->gid))
 				goto bad_val;
 		} else if (!strcmp(this_char,"mpol")) {
-			if (mpol_parse_str(value, &sbinfo->mpol))
+			mpol_put(mpol);
+			if (mpol_parse_str(value, &mpol))
 				goto bad_val;
 		} else {
 			printk(KERN_ERR "tmpfs: Bad mount option %s\n",
 			       this_char);
-			return 1;
+			goto error;
 		}
 	}
+	sbinfo->mpol = mpol;
 	return 0;
 
 bad_val:
 	printk(KERN_ERR "tmpfs: Bad value '%s' for mount option '%s'\n",
 	       value, this_char);
+error:
+	mpol_put(mpol);
 	return 1;
 
 }
@@ -2551,6 +2556,7 @@ static void shmem_put_super(struct super_block *sb)
 	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
 
 	percpu_counter_destroy(&sbinfo->used_blocks);
+	mpol_put(sbinfo->mpol);
 	kfree(sbinfo);
 	sb->s_fs_info = NULL;
 }
-- 
1.8.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
