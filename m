Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id B58E36B00E0
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 07:24:41 -0500 (EST)
Received: by faao14 with SMTP id o14so689870faa.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 04:24:40 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 12 Dec 2011 20:24:39 +0800
Message-ID: <CAJd=RBAN7cK_6OstO=5gszW8cJ_d4-8iQC3gWG6HUtabiMN9Yg@mail.gmail.com>
Subject: [PATCH] mm: vmscan: try to free orphaned page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

If the orphaned page has no buffer attached at the moment, we clean it up by
hand, then it has the chance to progress the freeing trip.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Sun Dec  4 13:10:08 2011
+++ b/mm/vmscan.c	Mon Dec 12 20:12:44 2011
@@ -487,12 +487,10 @@ static pageout_t pageout(struct page *pa
 		 * Some data journaling orphaned pages can have
 		 * page->mapping == NULL while being dirty with clean buffers.
 		 */
-		if (page_has_private(page)) {
-			if (try_to_free_buffers(page)) {
-				ClearPageDirty(page);
-				printk("%s: orphaned page\n", __func__);
-				return PAGE_CLEAN;
-			}
+		if (!page_has_private(page) || try_to_free_buffers(page)) {
+			ClearPageDirty(page);
+			printk(KERN_INFO "%s: orphaned page\n", __func__);
+			return PAGE_CLEAN;
 		}
 		return PAGE_KEEP;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
