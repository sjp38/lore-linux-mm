Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 209D25F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 03:31:37 -0400 (EDT)
Message-ID: <49E58D7A.4010708@ens-lyon.org>
Date: Wed, 15 Apr 2009 09:32:10 +0200
From: Brice Goglin <Brice.Goglin@ens-lyon.org>
MIME-Version: 1.0
Subject: [PATCH] migration: only migrate_prep() once per move_pages()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

migrate_prep() is fairly expensive (72us on 16-core barcelona 1.9GHz).
Commit 3140a2273009c01c27d316f35ab76a37e105fdd8 improved move_pages()
throughput by breaking it into chunks, but it also made migrate_prep()
be called once per chunk (every 128pages or so) instead of once per
move_pages().

This patch reverts to calling migrate_prep() only once per chunk
as we did before 2.6.29.
It is also a followup to commit 0aedadf91a70a11c4a3e7c7d99b21e5528af8d5d
    mm: move migrate_prep out from under mmap_sem

This improves migration throughput on the above machine from 600MB/s
to 750MB/s.

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>

diff --git a/mm/migrate.c b/mm/migrate.c
index 068655d..a2d3e83 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -820,7 +820,6 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
 
-	migrate_prep();
 	down_read(&mm->mmap_sem);
 
 	/*
@@ -907,6 +906,9 @@ static int do_pages_move(struct mm_struct *mm, struct task_struct *task,
 	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
 	if (!pm)
 		goto out;
+
+	migrate_prep();
+
 	/*
 	 * Store a chunk of page_to_node array in a page,
 	 * but keep the last one as a marker


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
