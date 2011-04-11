Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 48DB18D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 01:31:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 29A163EE0C3
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 91F9845DE9E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 751FE45DE99
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 58AAEE08003
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF372E18002
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/4] mm: introduce wait_on_page_locked_killable
In-Reply-To: <20110411142949.006C.A69D9226@jp.fujitsu.com>
References: <20110411142949.006C.A69D9226@jp.fujitsu.com>
Message-Id: <20110411143247.0078.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 14:31:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

commit 2687a356 (Add lock_page_killable) introduced killable
lock_page(). Similarly this patch introdues killable
wait_on_page_locked().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/pagemap.h |    9 +++++++++
 mm/filemap.c            |   11 +++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c119506..ea26808 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -357,6 +357,15 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
  */
 extern void wait_on_page_bit(struct page *page, int bit_nr);
 
+extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
+
+static inline int wait_on_page_locked_killable(struct page *page)
+{
+	if (PageLocked(page))
+		return wait_on_page_bit_killable(page, PG_locked);
+	return 0;
+}
+
 /* 
  * Wait for a page to be unlocked.
  *
diff --git a/mm/filemap.c b/mm/filemap.c
index 1c63865..507349d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -573,6 +573,17 @@ void wait_on_page_bit(struct page *page, int bit_nr)
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
+int wait_on_page_bit_killable(struct page *page, int bit_nr)
+{
+	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+
+	if (!test_bit(bit_nr, &page->flags))
+		return 0;
+
+	return __wait_on_bit(page_waitqueue(page), &wait,
+			     sleep_on_page_killable, TASK_KILLABLE);
+}
+
 /**
  * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
  * @page: Page defining the wait queue of interest
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
