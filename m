Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8E0C56B0073
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:25:29 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so3631063ghr.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 03:25:28 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 2/6] Make TestSetPageDirty and dirty page accounting in one func
Date: Fri, 27 Jul 2012 18:25:20 +0800
Message-Id: <1343384720-20084-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
References: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: fengguang.wu@intel.com, gthelen@google.com, akpm@linux-foundation.org, yinghan@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, npiggin@kernel.dk, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Commit a8e7d49a(Fix race in create_empty_buffers() vs __set_page_dirty_buffers())
extracts TestSetPageDirty from __set_page_dirty and is far away from
account_page_dirtied.But it's better to make the two operations in one single
function to keep modular.So in order to avoid the potential race mentioned in
commit a8e7d49a, we can hold private_lock until __set_page_dirty completes.
I guess there's no deadlock between ->private_lock and ->tree_lock by quick look.
It's a prepare patch for following memcg dirty page accounting patches.


Here is some test numbers that before/after this patch:

Test steps(Mem-24g, ext4):
drop_cache; sync
fio (buffered/randwrite/bs=4k/size=128m/filesize=1g/numjobs=8/sync)

We test it for 10 times and get the average numbers:
Before:
write: io=1024.0MB, bw=334678 KB/s, iops=83669.2 , runt=  3136 msec
lat (usec): min=1 , max=26203.1 , avg=81.473, stdev=275.754
After:
write: io=1024.0MB, bw=331583 KB/s, iops=82895.3 , runt=  3164.4 msec
lat (usec): min=1.1 , max=19001.6 , avg=83.544, stdev=272.704

Note that the impact is little(~1%).

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 fs/buffer.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index c7062c8..5e0b0d2 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -610,9 +610,15 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
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
@@ -622,6 +628,8 @@ static void __set_page_dirty(struct page *page,
 	}
 	spin_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	return 1;
 }
 
 /*
@@ -667,11 +675,9 @@ int __set_page_dirty_buffers(struct page *page)
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
@@ -1119,14 +1125,9 @@ void mark_buffer_dirty(struct buffer_head *bh)
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
+
 }
 EXPORT_SYMBOL(mark_buffer_dirty);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
