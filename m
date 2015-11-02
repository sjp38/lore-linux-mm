Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 11C2C82F65
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 12:01:44 -0500 (EST)
Received: by pasz6 with SMTP id z6so153779659pas.2
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:01:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id yo3si36139676pab.227.2015.11.02.09.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 09:01:35 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/5] ksm: unstable_tree_search_insert error checking cleanup
Date: Mon,  2 Nov 2015 18:01:31 +0100
Message-Id: <1446483691-8494-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
References: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

get_mergeable_page() can only return NULL (also in case of errors) or
the pinned mergeable page. It can't return an error different than
NULL. This optimizes away the unnecessary error check.

Add a return after the "out:" label in the callee to make it more
readable.

Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 0183083..b5cd647 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -475,7 +475,8 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 		flush_dcache_page(page);
 	} else {
 		put_page(page);
-out:		page = NULL;
+out:
+		page = NULL;
 	}
 	up_read(&mm->mmap_sem);
 	return page;
@@ -1358,7 +1359,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 		cond_resched();
 		tree_rmap_item = rb_entry(*new, struct rmap_item, node);
 		tree_page = get_mergeable_page(tree_rmap_item);
-		if (IS_ERR_OR_NULL(tree_page))
+		if (!tree_page)
 			return NULL;
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
