Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7E44E6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:55:49 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p4V0tknd003113
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:55:46 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by hpaq7.eem.corp.google.com with ESMTP id p4V0tMFA007672
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:55:45 -0700
Received: by pvc30 with SMTP id 30so1899079pvc.6
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:55:44 -0700 (PDT)
Date: Mon, 30 May 2011 17:55:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 14/14] tmpfs: no need to use i_lock
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301754050.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2.6.36's 7e496299d4d2 to make tmpfs scalable with percpu_counter used
inode->i_lock in place of sbinfo->stat_lock around i_blocks updates;
but that was adverse to scalability, and unnecessary, since info->lock
is already held there in the fast paths.

Remove those uses of i_lock, and add info->lock in the three error
paths where it's then needed across shmem_free_blocks().  It's not
actually needed across shmem_unacct_blocks(), but they're so often
paired that it looks wrong to split them apart.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/shmem.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

--- linux.orig/mm/shmem.c	2011-05-30 14:25:32.665536626 -0700
+++ linux/mm/shmem.c	2011-05-30 15:03:41.680887254 -0700
@@ -241,9 +241,7 @@ static void shmem_free_blocks(struct ino
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
 	if (sbinfo->max_blocks) {
 		percpu_counter_add(&sbinfo->used_blocks, -pages);
-		spin_lock(&inode->i_lock);
 		inode->i_blocks -= pages*BLOCKS_PER_PAGE;
-		spin_unlock(&inode->i_lock);
 	}
 }
 
@@ -432,9 +430,7 @@ static swp_entry_t *shmem_swp_alloc(stru
 						sbinfo->max_blocks - 1) >= 0)
 				return ERR_PTR(-ENOSPC);
 			percpu_counter_inc(&sbinfo->used_blocks);
-			spin_lock(&inode->i_lock);
 			inode->i_blocks += BLOCKS_PER_PAGE;
-			spin_unlock(&inode->i_lock);
 		}
 
 		spin_unlock(&info->lock);
@@ -1420,9 +1416,7 @@ repeat:
 			    shmem_acct_block(info->flags))
 				goto nospace;
 			percpu_counter_inc(&sbinfo->used_blocks);
-			spin_lock(&inode->i_lock);
 			inode->i_blocks += BLOCKS_PER_PAGE;
-			spin_unlock(&inode->i_lock);
 		} else if (shmem_acct_block(info->flags))
 			goto nospace;
 
@@ -1433,8 +1427,10 @@ repeat:
 				spin_unlock(&info->lock);
 				filepage = shmem_alloc_page(gfp, info, idx);
 				if (!filepage) {
+					spin_lock(&info->lock);
 					shmem_unacct_blocks(info->flags, 1);
 					shmem_free_blocks(inode, 1);
+					spin_unlock(&info->lock);
 					error = -ENOMEM;
 					goto failed;
 				}
@@ -1448,8 +1444,10 @@ repeat:
 					current->mm, GFP_KERNEL);
 				if (error) {
 					page_cache_release(filepage);
+					spin_lock(&info->lock);
 					shmem_unacct_blocks(info->flags, 1);
 					shmem_free_blocks(inode, 1);
+					spin_unlock(&info->lock);
 					filepage = NULL;
 					goto failed;
 				}
@@ -1479,10 +1477,10 @@ repeat:
 			 * be done automatically.
 			 */
 			if (ret) {
-				spin_unlock(&info->lock);
-				page_cache_release(filepage);
 				shmem_unacct_blocks(info->flags, 1);
 				shmem_free_blocks(inode, 1);
+				spin_unlock(&info->lock);
+				page_cache_release(filepage);
 				filepage = NULL;
 				if (error)
 					goto failed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
