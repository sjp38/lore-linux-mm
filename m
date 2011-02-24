Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E9ACF8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 00:44:36 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p1O5iWWF031846
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:44:33 -0800
Received: from yie30 (yie30.prod.google.com [10.243.66.30])
	by wpaz13.hot.corp.google.com with ESMTP id p1O5iVli016299
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:44:31 -0800
Received: by yie30 with SMTP id 30so108022yie.9
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:44:31 -0800 (PST)
Date: Wed, 23 Feb 2011 21:44:33 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] memcg: more mem_cgroup_uncharge batching
Message-ID: <alpine.LSU.2.00.1102232139560.2239@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishmura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

It seems odd that truncate_inode_pages_range(), called not only when
truncating but also when evicting inodes, has mem_cgroup_uncharge_start
and _end() batching in its second loop to clear up a few leftovers, but
not in its first loop that does almost all the work: add them there too.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/truncate.c |    2 ++
 1 file changed, 2 insertions(+)

--- 2.6.38-rc6/mm/truncate.c	2011-01-21 20:54:14.000000000 -0800
+++ linux/mm/truncate.c	2011-02-23 16:12:19.000000000 -0800
@@ -225,6 +225,7 @@ void truncate_inode_pages_range(struct a
 	next = start;
 	while (next <= end &&
 	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index = page->index;
@@ -247,6 +248,7 @@ void truncate_inode_pages_range(struct a
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_end();
 		cond_resched();
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
