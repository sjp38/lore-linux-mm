Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A75D8D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 07:08:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 676263EE0B6
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:08:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E02A45DE69
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:08:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3706A45DE55
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:08:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 25FA01DB8043
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:08:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E3E1C1DB803F
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:08:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/5] mm: introduce wait_on_page_locked_killable
In-Reply-To: <20110322194721.B05E.A69D9226@jp.fujitsu.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com> <20110322194721.B05E.A69D9226@jp.fujitsu.com>
Message-Id: <20110322200904.B06A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 22 Mar 2011 20:08:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

commit 2687a356 (Add lock_page_killable) introduced killable
lock_page(). Similarly this patch introdues killable
wait_on_page_locked().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/pagemap.h |    9 +++++++++
 mm/filemap.c            |   11 +++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e407601..49f9315 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -369,6 +369,15 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
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
index a6cfecf..f5f9ac2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -608,6 +608,17 @@ void wait_on_page_bit(struct page *page, int bit_nr)
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
+int wait_on_page_bit_killable(struct page *page, int bit_nr)
+{
+	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+
+	if (!test_bit(bit_nr, &page->flags))
+		return 0;
+
+	return __wait_on_bit(page_waitqueue(page), &wait, sync_page_killable,
+							TASK_KILLABLE);
+}
+
 /**
  * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
  * @page: Page defining the wait queue of interest
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
