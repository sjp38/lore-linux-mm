Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 130D56B0082
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:25:49 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 16/18] SHM: Support for splitting on truncation
Date: Thu, 16 Feb 2012 15:31:43 +0100
Message-Id: <1329402705-25454-16-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Writeback will be added in next patches, but after experimental support
for huge pages for EXT 4.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 mm/shmem.c |   39 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 97e76b9..db377bf 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -454,6 +454,7 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
+			struct page *head = NULL;
 
 			index = indices[i];
 			if (index > end)
@@ -464,12 +465,32 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 								index, page);
 				continue;
 			}
-
 			if (!trylock_page(page))
 				continue;
+			if (PageCompound(page)) {
+				head = compound_head(page);
+				switch (compound_try_freeze(head, false)) {
+				case -1:
+					head = NULL;
+					break;
+				case 1:
+					unlock_page(page);
+					continue;
+				case 0:
+					if (!split_huge_page_file(head, page))
+						head = NULL;
+					break;
+				}
+			}
+			/* Truncate inode page may try to freez, so unfreez. */
 			if (page->mapping == mapping) {
 				VM_BUG_ON(PageWriteback(page));
+				if (head != NULL)
+					compound_unfreeze(head);
 				truncate_inode_page(mapping, page);
+			} else {
+				if (head != NULL)
+					compound_unfreeze(head);
 			}
 			unlock_page(page);
 		}
@@ -511,6 +532,7 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
+			struct page *head = NULL;
 
 			index = indices[i];
 			if (index > end)
@@ -523,9 +545,24 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 			}
 
 			lock_page(page);
+			if (PageCompound(page)) {
+				head = compound_head(page);
+				if (compound_freeze(head)) {
+					if (!split_huge_page_file(head, page))
+						head = NULL;
+				} else {
+					head = NULL;
+				}
+			}
+			/* Truncate inode page may try to freez, so unfreez. */
 			if (page->mapping == mapping) {
 				VM_BUG_ON(PageWriteback(page));
+				if (head != NULL)
+					compound_unfreeze(head);
 				truncate_inode_page(mapping, page);
+			} else {
+				if (head != NULL)
+					compound_unfreeze(head);
 			}
 			unlock_page(page);
 		}
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
