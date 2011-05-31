Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80FF66B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:45:16 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4V0jDcV009069
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:45:13 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq6.eem.corp.google.com with ESMTP id p4V0jAcE024149
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:45:11 -0700
Received: by pwj8 with SMTP id 8so2305766pwj.41
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:45:10 -0700 (PDT)
Date: Mon, 30 May 2011 17:45:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 7/14] drm/i915: adjust to new truncate_range
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301743500.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Keith Packard <keithp@keithp.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The interface to ->truncate_range is changing very slightly:
once "tmpfs: take control of its truncate_range" has been applied,
this can be applied.  For now it's only a slight inefficiency while
this remains unapplied, but soon it will become essential.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Keith Packard <keithp@keithp.com>
Cc: Dave Airlie <airlied@redhat.com>
---
 drivers/gpu/drm/i915/i915_gem.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux.orig/drivers/gpu/drm/i915/i915_gem.c	2011-05-30 14:26:13.121737248 -0700
+++ linux/drivers/gpu/drm/i915/i915_gem.c	2011-05-30 14:26:20.861775625 -0700
@@ -1693,13 +1693,13 @@ i915_gem_object_truncate(struct drm_i915
 	/* Our goal here is to return as much of the memory as
 	 * is possible back to the system as we are called from OOM.
 	 * To do this we must instruct the shmfs to drop all of its
-	 * backing pages, *now*. Here we mirror the actions taken
-	 * when by shmem_delete_inode() to release the backing store.
+	 * backing pages, *now*.
 	 */
 	inode = obj->base.filp->f_path.dentry->d_inode;
-	truncate_inode_pages(inode->i_mapping, 0);
 	if (inode->i_op->truncate_range)
 		inode->i_op->truncate_range(inode, 0, (loff_t)-1);
+	else
+		truncate_inode_pages(inode->i_mapping, 0);
 
 	obj->madv = __I915_MADV_PURGED;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
