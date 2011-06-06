Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AECD96B0128
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:32:37 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p564WX9g007601
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:32:34 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz13.hot.corp.google.com with ESMTP id p564WWMp025791
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:32:32 -0700
Received: by pwi5 with SMTP id 5so2074794pwi.31
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:32:31 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:32:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 7/14] drm/i915: use shmem_truncate_range
In-Reply-To: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106052131080.17116@sister.anvils>
References: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Chris Wilson <chris@chris-wilson.co.uk>, Keith Packard <keithp@keithp.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The interface to ->truncate_range is changing very slightly:
once "tmpfs: take control of its truncate_range" has been applied,
this can be applied.  For now there is only a slight inefficiency
while this remains unapplied, but it will soon become essential
for managing shmem's use of swap.

Change i915_gem_object_truncate() to use shmem_truncate_range()
directly: which should also spare i915 later change if we switch
from inode_operations->truncate_range to file_operations->fallocate.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Keith Packard <keithp@keithp.com>
Cc: Dave Airlie <airlied@redhat.com>
---
 drivers/gpu/drm/i915/i915_gem.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

--- linux.orig/drivers/gpu/drm/i915/i915_gem.c	2011-06-05 18:37:13.589743574 -0700
+++ linux/drivers/gpu/drm/i915/i915_gem.c	2011-06-05 18:44:59.064050179 -0700
@@ -1694,13 +1694,10 @@ i915_gem_object_truncate(struct drm_i915
 	/* Our goal here is to return as much of the memory as
 	 * is possible back to the system as we are called from OOM.
 	 * To do this we must instruct the shmfs to drop all of its
-	 * backing pages, *now*. Here we mirror the actions taken
-	 * when by shmem_delete_inode() to release the backing store.
+	 * backing pages, *now*.
 	 */
 	inode = obj->base.filp->f_path.dentry->d_inode;
-	truncate_inode_pages(inode->i_mapping, 0);
-	if (inode->i_op->truncate_range)
-		inode->i_op->truncate_range(inode, 0, (loff_t)-1);
+	shmem_truncate_range(inode, 0, (loff_t)-1);
 
 	obj->madv = __I915_MADV_PURGED;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
