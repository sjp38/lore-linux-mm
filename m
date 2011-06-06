Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 94D4A6B0134
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:41:01 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p564exwC013383
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:40:59 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by hpaq6.eem.corp.google.com with ESMTP id p564eoLG015621
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:40:51 -0700
Received: by pwi3 with SMTP id 3so2145220pwi.37
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:40:50 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:40:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 13/14] mm: pincer in truncate_inode_pages_range
In-Reply-To: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106052139460.17116@sister.anvils>
References: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
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

--- linux.orig/mm/truncate.c	2011-06-05 19:25:13.112013371 -0700
+++ linux/mm/truncate.c	2011-06-05 19:27:12.244611885 -0700
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
