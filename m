Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B5B55900001
	for <linux-mm@kvack.org>; Sat, 30 Apr 2011 22:35:38 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p412Za4v022016
	for <linux-mm@kvack.org>; Sat, 30 Apr 2011 19:35:36 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by hpaq3.eem.corp.google.com with ESMTP id p412ZVRE004403
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Apr 2011 19:35:35 -0700
Received: by pve37 with SMTP id 37so3901411pve.35
        for <linux-mm@kvack.org>; Sat, 30 Apr 2011 19:35:31 -0700 (PDT)
Date: Sat, 30 Apr 2011 19:35:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mmotm: fix hang at startup
In-Reply-To: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1104301929520.1343@sister.anvils>
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Yesterday's mmotm hangs at startup, and with lockdep it reports:
BUG: spinlock recursion on CPU#1, blkid/284 - with bdi_lock_two()
called from bdev_inode_switch_bdi() in the backtrace.  It appears
that this function is sometimes called with new the same as old.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Fix to
writeback-split-inode_wb_list_lock-into-bdi_writebacklist_lock.patch

 fs/block_dev.c |    2 ++
 1 file changed, 2 insertions(+)

--- 2.6.39-rc5-mm1/fs/block_dev.c	2011-04-29 18:20:09.183314733 -0700
+++ linux/fs/block_dev.c	2011-04-30 17:55:45.718785263 -0700
@@ -57,6 +57,8 @@ static void bdev_inode_switch_bdi(struct
 {
 	struct backing_dev_info *old = inode->i_data.backing_dev_info;
 
+	if (dst == old)
+		return;
 	bdi_lock_two(&old->wb, &dst->wb);
 	spin_lock(&inode->i_lock);
 	inode->i_data.backing_dev_info = dst;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
