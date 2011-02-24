Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AEFA58D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 00:35:54 -0500 (EST)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p1O5ZpNg023177
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:35:51 -0800
Received: from yxk30 (yxk30.prod.google.com [10.190.3.158])
	by hpaq13.eem.corp.google.com with ESMTP id p1O5ZQBY004687
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:35:50 -0800
Received: by yxk30 with SMTP id 30so168830yxk.17
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:35:50 -0800 (PST)
Date: Wed, 23 Feb 2011 21:35:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: don't return 0 too early from find_get_pages()
Message-ID: <alpine.LSU.2.00.1102232132080.2239@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Salman Qazi <sqazi@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Callers of find_get_pages(), or its wrapper pagevec_lookup() - notably
truncate_inode_pages_range() - stop looking further when it returns 0.

But if an interrupt comes just after its radix_tree_gang_lookup_slot(),
especially if we have preemptible RCU enabled, isn't it conceivable
that all 14 pages returned could be removed from the page cache by
shrink_page_list(), before find_get_pages() gets to process them?  So
causing it to return 0 although there may be plenty more pages beyond.

Make find_get_pages() and find_get_pages_tag() check for this unlikely
case, and restart should it occur; but callers of find_get_pages_contig()
have no such expectation, it's okay for that to return 0 early.

I have not seen this in practice, just worried by the possibility.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/filemap.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

--- 2.6.38-rc6/mm/filemap.c	2011-01-18 22:04:56.000000000 -0800
+++ linux/mm/filemap.c	2011-02-23 16:06:19.000000000 -0800
@@ -800,6 +800,13 @@ repeat:
 		pages[ret] = page;
 		ret++;
 	}
+
+	/*
+	 * If all entries were removed before we could secure them,
+	 * try again, because callers stop trying once 0 is returned.
+	 */
+	if (unlikely(!ret && nr_found))
+		goto restart;
 	rcu_read_unlock();
 	return ret;
 }
@@ -909,6 +916,13 @@ repeat:
 		pages[ret] = page;
 		ret++;
 	}
+
+	/*
+	 * If all entries were removed before we could secure them,
+	 * try again, because callers stop trying once 0 is returned.
+	 */
+	if (unlikely(!ret && nr_found))
+		goto restart;
 	rcu_read_unlock();
 
 	if (ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
