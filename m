Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id F06A36B0062
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 12:23:18 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id ro12so4429070pbb.24
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 09:23:18 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V3 2/8] Make TestSetPageDirty and dirty page accounting in one func
Date: Wed, 26 Dec 2012 01:22:36 +0800
Message-Id: <1356456156-14535-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Commit a8e7d49a(Fix race in create_empty_buffers() vs __set_page_dirty_buffers())
extracts TestSetPageDirty from __set_page_dirty and is far away from
account_page_dirtied. But it's better to make the two operations in one single
function to keep modular. So in order to avoid the potential race mentioned in
commit a8e7d49a, we can hold private_lock until __set_page_dirty completes.
There's no deadlock between ->private_lock and ->tree_lock after confirmation.
It's a prepare patch for following memcg dirty page accounting patches.


Here is some test numbers that before/after this patch:
Test steps(Mem-4g, ext4):
drop_cache; sync
fio (ioengine=sync/write/buffered/bs=4k/size=1g/numjobs=2/group_reporting/thread)

We test it for 10 times and get the average numbers:
Before:
write: io=2048.0MB, bw=254117KB/s, iops=63528.9 , runt=  8279msec
lat (usec): min=1 , max=742361 , avg=30.918, stdev=1601.02
After:
write: io=2048.0MB, bw=254044KB/s, iops=63510.3 , runt=  8274.4msec
lat (usec): min=1 , max=856333 , avg=31.043, stdev=1769.32

Note that the impact is little(<1%).


Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 fs/buffer.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index c017a2d..3b032b9 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -609,9 +609,15 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  * If warn is true, then emit a warning if the page is not uptodate and has
  * not been truncated.
  */
-static void __set_page_dirty(struct page *page,
+static int __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
+	if (unlikely(!mapping))
+		return !TestSetPageDirty(page);
+
+	if (TestSetPageDirty(page))
+		return 0;
+
 	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
@@ -621,6 +627,8 @@ static void __set_page_dirty(struct page *page,
 	}
 	spin_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	return 1;
 }
 
 /*
@@ -666,11 +674,9 @@ int __set_page_dirty_buffers(struct page *page)
 			bh = bh->b_this_page;
 		} while (bh != head);
 	}
-	newly_dirty = !TestSetPageDirty(page);
+	newly_dirty = __set_page_dirty(page, mapping, 1);
 	spin_unlock(&mapping->private_lock);
 
-	if (newly_dirty)
-		__set_page_dirty(page, mapping, 1);
 	return newly_dirty;
 }
 EXPORT_SYMBOL(__set_page_dirty_buffers);
@@ -1125,14 +1131,8 @@ void mark_buffer_dirty(struct buffer_head *bh)
 			return;
 	}
 
-	if (!test_set_buffer_dirty(bh)) {
-		struct page *page = bh->b_page;
-		if (!TestSetPageDirty(page)) {
-			struct address_space *mapping = page_mapping(page);
-			if (mapping)
-				__set_page_dirty(page, mapping, 0);
-		}
-	}
+	if (!test_set_buffer_dirty(bh))
+		__set_page_dirty(bh->b_page, page_mapping(bh->b_page), 0);
 }
 EXPORT_SYMBOL(mark_buffer_dirty);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
