Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3D96B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 20:05:44 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p9J05f7n010542
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:05:41 -0700
Received: from iaeo4 (iaeo4.prod.google.com [10.12.166.4])
	by hpaq14.eem.corp.google.com with ESMTP id p9J03Qv2003267
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:05:40 -0700
Received: by iaeo4 with SMTP id o4so2470007iae.9
        for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:05:31 -0700 (PDT)
Date: Tue, 18 Oct 2011 17:02:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: munlock use mapcount to avoid terrible overhead
Message-ID: <alpine.LSU.2.00.1110181700400.3361@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A process spent 30 minutes exiting, just munlocking the pages of a large
anonymous area that had been alternately mprotected into page-sized vmas:
for every single page there's an anon_vma walk through all the other
little vmas to find the right one.

A general fix to that would be a lot more complicated (use prio_tree on
anon_vma?), but there's one very simple thing we can do to speed up the
common case: if a page to be munlocked is mapped only once, then it is
our vma that it is mapped into, and there's no need whatever to walk
through all the others.

Okay, there is a very remote race in munlock_vma_pages_range(), if
between its follow_page() and lock_page(), another process were to
munlock the same page, then page reclaim remove it from our vma, then
another process mlock it again.  We would find it with page_mapcount
1, yet it's still mlocked in another process.  But never mind, that's
much less likely than the down_read_trylock() failure which munlocking
already tolerates (in try_to_unmap_one()): in due course page reclaim
will discover and move the page to unevictable instead.
    
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/mlock.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- 3.1-rc10/mm/mlock.c	2011-07-21 19:17:23.000000000 -0700
+++ linux/mm/mlock.c	2011-10-06 12:47:54.670436979 -0700
@@ -110,7 +110,10 @@ void munlock_vma_page(struct page *page)
 	if (TestClearPageMlocked(page)) {
 		dec_zone_page_state(page, NR_MLOCK);
 		if (!isolate_lru_page(page)) {
-			int ret = try_to_munlock(page);
+			int ret = SWAP_AGAIN;
+
+			if (page_mapcount(page) > 1)
+				ret = try_to_munlock(page);
 			/*
 			 * did try_to_unlock() succeed or punt?
 			 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
