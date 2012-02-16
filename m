Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 437B96B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:52 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 05/18] Various VM_BUG_ON for securing tail pages usage
Date: Thu, 16 Feb 2012 15:31:32 +0100
Message-Id: <1329402705-25454-5-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 mm/vmscan.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..7299b71 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -636,7 +636,7 @@ void putback_lru_page(struct page *page)
 	int was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON(PageLRU(page));
-
+	VM_BUG_ON(PageTail(page));
 redo:
 	ClearPageUnevictable(page);
 
@@ -1177,6 +1177,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		prefetchw_prev_lru_page(page, src, flags);
 
 		VM_BUG_ON(!PageLRU(page));
+		VM_BUG_ON(PageTail(page));
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
@@ -1239,6 +1240,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				unsigned int isolated_pages;
 
+				VM_BUG_ON(PageTail(cursor_page));
+
 				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);
 				isolated_pages = hpage_nr_pages(cursor_page);
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
