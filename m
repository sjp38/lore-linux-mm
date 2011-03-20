Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 166878D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 01:33:09 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p2K5X5aM011723
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 22:33:05 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz1.hot.corp.google.com with ESMTP id p2K5X3DH019676
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 22:33:04 -0700
Received: by pzk2 with SMTP id 2so582919pzk.9
        for <linux-mm@kvack.org>; Sat, 19 Mar 2011 22:33:03 -0700 (PDT)
Date: Sat, 19 Mar 2011 22:33:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix off-by-one in max_blocks checks
Message-ID: <alpine.LSU.2.00.1103192230480.1659@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If you fill up a tmpfs, df was showing
tmpfs                   460800         -         -   -  /tmp
because of an off-by-one in the max_blocks checks.  Fix it so df shows
tmpfs                   460800    460800         0 100% /tmp

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- 2.6.38/mm/shmem.c	2011-03-14 18:20:32.000000000 -0700
+++ linux/mm/shmem.c	2011-03-19 22:02:17.000000000 -0700
@@ -422,7 +422,8 @@ static swp_entry_t *shmem_swp_alloc(stru
 		 * a waste to allocate index if we cannot allocate data.
 		 */
 		if (sbinfo->max_blocks) {
-			if (percpu_counter_compare(&sbinfo->used_blocks, (sbinfo->max_blocks - 1)) > 0)
+			if (percpu_counter_compare(&sbinfo->used_blocks,
+						sbinfo->max_blocks - 1) >= 0)
 				return ERR_PTR(-ENOSPC);
 			percpu_counter_inc(&sbinfo->used_blocks);
 			spin_lock(&inode->i_lock);
@@ -1399,7 +1400,8 @@ repeat:
 		shmem_swp_unmap(entry);
 		sbinfo = SHMEM_SB(inode->i_sb);
 		if (sbinfo->max_blocks) {
-			if ((percpu_counter_compare(&sbinfo->used_blocks, sbinfo->max_blocks) > 0) ||
+			if (percpu_counter_compare(&sbinfo->used_blocks,
+						sbinfo->max_blocks) >= 0 ||
 			    shmem_acct_block(info->flags)) {
 				spin_unlock(&info->lock);
 				error = -ENOSPC;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
