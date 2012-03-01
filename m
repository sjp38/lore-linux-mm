Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id BA5606B0083
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 06:41:55 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 7/9] gfs2: Push file_update_time() into gfs2_page_mkwrite()
Date: Thu,  1 Mar 2012 12:41:41 +0100
Message-Id: <1330602103-8851-8-git-send-email-jack@suse.cz>
In-Reply-To: <1330602103-8851-1-git-send-email-jack@suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jan Kara <jack@suse.cz>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

CC: Steven Whitehouse <swhiteho@redhat.com>
CC: cluster-devel@redhat.com
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/gfs2/file.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index c5fb359..1f03531 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -375,6 +375,9 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 */
 	vfs_check_frozen(inode->i_sb, SB_FREEZE_WRITE);
 
+	/* Update file times before taking page lock */
+	file_update_time(vma->vm_file);
+
 	gfs2_holder_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &gh);
 	ret = gfs2_glock_nq(&gh);
 	if (ret)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
