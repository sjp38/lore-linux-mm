Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D98026B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:54:03 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p4V0s213029364
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:54:02 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by kpbe11.cbf.corp.google.com with ESMTP id p4V0s0uE028313
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:54:01 -0700
Received: by pzk37 with SMTP id 37so3550919pzk.1
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:54:00 -0700 (PDT)
Date: Mon, 30 May 2011 17:54:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 13/14] mm: pincer in truncate_inode_pages_range
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301752410.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

truncate_inode_pages_range()'s final loop has a nice pincer property,
bringing start and end together, squeezing out the last pages.  But
the range handling missed out on that, just sliding up the range,
perhaps letting pages come in behind it.  Add one more test to give
it the same pincer effect.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/truncate.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/mm/truncate.c	2011-05-30 15:01:01.660093602 -0700
+++ linux/mm/truncate.c	2011-05-30 15:03:28.688822856 -0700
@@ -269,7 +269,7 @@ void truncate_inode_pages_range(struct a
 			index = start;
 			continue;
 		}
-		if (pvec.pages[0]->index > end) {
+		if (index == start && pvec.pages[0]->index > end) {
 			pagevec_release(&pvec);
 			break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
