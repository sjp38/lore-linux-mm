Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C406831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 03:09:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x184so13303183wmf.14
        for <linux-mm@kvack.org>; Fri, 19 May 2017 00:09:59 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::180])
        by mx.google.com with ESMTPS id g90si2407250lfi.43.2017.05.19.00.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 00:09:57 -0700 (PDT)
Subject: [PATCH] ext4: handle the rest of ext4_mb_load_buddy() ENOMEM errors
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 19 May 2017 10:09:54 +0300
Message-ID: <149517779388.33359.16474190951431954772.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

I've got another report about breaking ext4 by ENOMEM error returned from
ext4_mb_load_buddy() caused by memory shortage in memory cgroup.
This time inside ext4_discard_preallocations().

This patch replaces ext4_error() with ext4_warning() where errors returned
from ext4_mb_load_buddy() are not fatal and handled by caller:
* ext4_mb_discard_group_preallocations() - called before generating ENOSPC,
  we'll try to discard other group or return ENOSPC into user-space.
* ext4_trim_all_free() - just stop trimming and return ENOMEM from ioctl.

Some callers cannot handle errors, thus __GFP_NOFAIL is used for them:
* ext4_discard_preallocations()
* ext4_mb_discard_lg_preallocations()

The only unclear case is ext4_group_add_blocks(), probably ext4_std_error()
should handle ENOMEM as warning and don't break filesystem.

Fixes: adb7ef600cc9 ("ext4: use __GFP_NOFAIL in ext4_free_blocks()")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/ext4/mballoc.c |   23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 5083bce20ac4..b7928cddd539 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -3887,7 +3887,8 @@ ext4_mb_discard_group_preallocations(struct super_block *sb,
 
 	err = ext4_mb_load_buddy(sb, group, &e4b);
 	if (err) {
-		ext4_error(sb, "Error loading buddy information for %u", group);
+		ext4_warning(sb, "Error %d loading buddy information for %u",
+			     err, group);
 		put_bh(bitmap_bh);
 		return 0;
 	}
@@ -4044,10 +4045,11 @@ void ext4_discard_preallocations(struct inode *inode)
 		BUG_ON(pa->pa_type != MB_INODE_PA);
 		group = ext4_get_group_number(sb, pa->pa_pstart);
 
-		err = ext4_mb_load_buddy(sb, group, &e4b);
+		err = ext4_mb_load_buddy_gfp(sb, group, &e4b,
+					     GFP_NOFS|__GFP_NOFAIL);
 		if (err) {
-			ext4_error(sb, "Error loading buddy information for %u",
-					group);
+			ext4_error(sb, "Error %d loading buddy information for %u",
+				   err, group);
 			continue;
 		}
 
@@ -4303,11 +4305,14 @@ ext4_mb_discard_lg_preallocations(struct super_block *sb,
 	spin_unlock(&lg->lg_prealloc_lock);
 
 	list_for_each_entry_safe(pa, tmp, &discard_list, u.pa_tmp_list) {
+		int err;
 
 		group = ext4_get_group_number(sb, pa->pa_pstart);
-		if (ext4_mb_load_buddy(sb, group, &e4b)) {
-			ext4_error(sb, "Error loading buddy information for %u",
-					group);
+		err = ext4_mb_load_buddy_gfp(sb, group, &e4b,
+					     GFP_NOFS|__GFP_NOFAIL);
+		if (err) {
+			ext4_error(sb, "Error %d loading buddy information for %u",
+				   err, group);
 			continue;
 		}
 		ext4_lock_group(sb, group);
@@ -5127,8 +5132,8 @@ ext4_trim_all_free(struct super_block *sb, ext4_group_t group,
 
 	ret = ext4_mb_load_buddy(sb, group, &e4b);
 	if (ret) {
-		ext4_error(sb, "Error in loading buddy "
-				"information for %u", group);
+		ext4_warning(sb, "Error %d loading buddy information for %u",
+			     ret, group);
 		return ret;
 	}
 	bitmap = e4b.bd_bitmap;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
