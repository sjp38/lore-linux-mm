Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D78726B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 16:32:16 -0400 (EDT)
Date: Fri, 7 Oct 2011 15:32:13 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: mm: Do not drain pagevecs for mlockall(MCL_FUTURE)
Message-ID: <alpine.DEB.2.00.1110071529110.15540@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

MCL_FUTURE does not move pages between lru list and draining the LRU per
cpu pagevecs is a nasty activity. Avoid doing it unecessarily.

Signed-off-by: Christoph Lameter <cl@gentwo.org>


---
 mm/mlock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/mlock.c
===================================================================
--- linux-2.6.orig/mm/mlock.c	2011-10-07 14:57:52.000000000 -0500
+++ linux-2.6/mm/mlock.c	2011-10-07 15:01:06.000000000 -0500
@@ -549,7 +549,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	if (!can_do_mlock())
 		goto out;

-	lru_add_drain_all();	/* flush pagevec */
+	if (flags & MCL_CURRENT)
+		lru_add_drain_all();	/* flush pagevec */

 	down_write(&current->mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
