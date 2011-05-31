Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 924116B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:35:51 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p4V0ZnTK016142
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:35:49 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by hpaq1.eem.corp.google.com with ESMTP id p4V0ZkJC029310
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:35:48 -0700
Received: by pwi4 with SMTP id 4so2678449pwi.39
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:35:46 -0700 (PDT)
Date: Mon, 30 May 2011 17:35:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/14] mm: invalidate_mapping_pages flush cleancache
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301733500.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

truncate_inode_pages_range() and invalidate_inode_pages2_range()
call cleancache_flush_inode(mapping) before and after: shouldn't
invalidate_mapping_pages() be doing the same?

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 mm/truncate.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux.orig/mm/truncate.c	2011-05-30 13:56:10.416798124 -0700
+++ linux/mm/truncate.c	2011-05-30 14:08:46.612547848 -0700
@@ -333,6 +333,7 @@ unsigned long invalidate_mapping_pages(s
 	unsigned long count = 0;
 	int i;
 
+	cleancache_flush_inode(mapping);
 	pagevec_init(&pvec, 0);
 	while (next <= end &&
 			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
@@ -373,6 +374,7 @@ unsigned long invalidate_mapping_pages(s
 		mem_cgroup_uncharge_end();
 		cond_resched();
 	}
+	cleancache_flush_inode(mapping);
 	return count;
 }
 EXPORT_SYMBOL(invalidate_mapping_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
