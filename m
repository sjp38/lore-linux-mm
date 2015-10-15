Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id CD10282F66
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 12:04:39 -0400 (EDT)
Received: by oiev17 with SMTP id v17so1197275oie.2
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:04:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cn8si7838724oec.61.2015.10.15.09.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 09:04:32 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 6/6] ksm: unstable_tree_search_insert error checking cleanup
Date: Thu, 15 Oct 2015 18:04:25 +0200
Message-Id: <1444925065-4841-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

get_mergeable_page() can only return NULL (in case of errors) or the
pinned mergeable page. It can't return an error different than
NULL. This makes it more readable and less confusion in addition to
optimizing the check.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 10618a3..dcefc37 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1409,7 +1409,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
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
