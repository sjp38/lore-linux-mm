Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4AE5F6B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 03:30:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 14 Jun 2013 17:21:38 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 289A32CE804A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 17:30:51 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5E7GEN846137350
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 17:16:15 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5E7UnFj027732
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 17:30:49 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 1/8] mm/writeback: fix wb_do_writeback exported unsafely
Date: Fri, 14 Jun 2013 15:30:34 +0800
Message-Id: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

There is just one caller in fs-writeback.c call wb_do_writeback and
current codes unnecessary export it in header file, this patch fix
it by changing wb_do_writeback to static function.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 fs/fs-writeback.c         | 2 +-
 include/linux/writeback.h | 1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 3be5718..f892dec 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -959,7 +959,7 @@ static long wb_check_old_data_flush(struct bdi_writeback *wb)
 /*
  * Retrieve work items and do the writeback they describe
  */
-long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
+static long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
 {
 	struct backing_dev_info *bdi = wb->bdi;
 	struct wb_writeback_work *work;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 579a500..e27468e 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -94,7 +94,6 @@ int try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 void sync_inodes_sb(struct super_block *);
 long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
 				enum wb_reason reason);
-long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
 void inode_wait_for_writeback(struct inode *inode);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
