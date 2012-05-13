Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A9DC96B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 16:51:34 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7631387pbb.14
        for <linux-mm@kvack.org>; Sun, 13 May 2012 13:51:34 -0700 (PDT)
Date: Sun, 13 May 2012 13:51:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/2] xfs: hole-punch retaining cache beyond
In-Reply-To: <alpine.LSU.2.00.1205131347120.1547@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205131350150.1547@eggly.anvils>
References: <alpine.LSU.2.00.1205131347120.1547@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Ben Myers <bpm@sgi.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

xfs has a very inefficient hole-punch implementation, invalidating all
the cache beyond the hole (after flushing dirty back to disk, from which
all must be read back if wanted again).  So if you punch a hole in a
file mlock()ed into userspace, pages beyond the hole are inadvertently
munlock()ed until they are touched again.

Is there a strong internal reason why that has to be so on xfs?
Or is it just a relic from xfs supporting XFS_IOC_UNRESVSP long
before Linux 2.6.16 provided truncate_inode_pages_range()?

If the latter, then this patch mostly fixes it, by passing the proper
range to xfs_flushinval_pages().  But a little more should be done to
get it just right: a partial page on either side of the hole is still
written back to disk, invalidated and munlocked.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/xfs/xfs_vnodeops.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

--- next-20120511/fs/xfs/xfs_vnodeops.c	2012-05-11 00:22:26.095158149 -0700
+++ linux/fs/xfs/xfs_vnodeops.c	2012-05-12 18:01:14.988654723 -0700
@@ -2040,7 +2040,8 @@ xfs_free_file_space(
 	xfs_fsblock_t		firstfsb;
 	xfs_bmap_free_t		free_list;
 	xfs_bmbt_irec_t		imap;
-	xfs_off_t		ioffset;
+	xfs_off_t		startoffset;
+	xfs_off_t		endoffset;
 	xfs_extlen_t		mod=0;
 	xfs_mount_t		*mp;
 	int			nimap;
@@ -2074,11 +2075,18 @@ xfs_free_file_space(
 		inode_dio_wait(VFS_I(ip));
 	}
 
+	/*
+	 * Round startoffset down and endoffset up: we write out any dirty
+	 * blocks in between before truncating, so we can read partial blocks
+	 * back from disk afterwards (but that may munlock the partial pages).
+	 */
 	rounding = max_t(uint, 1 << mp->m_sb.sb_blocklog, PAGE_CACHE_SIZE);
-	ioffset = offset & ~(rounding - 1);
+	startoffset = round_down(offset, rounding);
+	endoffset = round_up(offset + len, rounding) - 1;
 
 	if (VN_CACHED(VFS_I(ip)) != 0) {
-		error = xfs_flushinval_pages(ip, ioffset, -1, FI_REMAPF_LOCKED);
+		error = xfs_flushinval_pages(ip, startoffset, endoffset,
+							FI_REMAPF_LOCKED);
 		if (error)
 			goto out_unlock_iolock;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
