Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 166556B0261
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 03:52:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so136701395pfg.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:52:17 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id q4si1058962pfb.41.2016.10.25.00.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 00:52:15 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id i85so18857403pfa.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:52:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable 4.4 4/4] Using BUG_ON() as an assert() is _never_ acceptable
Date: Tue, 25 Oct 2016 09:51:48 +0200
Message-Id: <20161025075148.31661-5-mhocko@kernel.org>
In-Reply-To: <20161025075148.31661-1-mhocko@kernel.org>
References: <20161025075148.31661-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Linus Torvalds <torvalds@linux-foundation.org>

Commit 21f54ddae449f4bdd9f1498124901d67202243d9 upstream.

That just generally kills the machine, and makes debugging only much
harder, since the traces may long be gone.

Debugging by assert() is a disease.  Don't do it.  If you can continue,
you're much better off doing so with a live machine where you have a
much higher chance that the report actually makes it to the system logs,
rather than result in a machine that is just completely dead.

The only valid situation for BUG_ON() is when continuing is not an
option, because there is massive corruption.  But if you are just
verifying that something is true, you warn about your broken assumptions
(preferably just once), and limp on.

Fixes: 22f2ac51b6d6 ("mm: workingset: fix crash in shadow node shrinker caused by replace_page_cache_page()")
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/swap.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b28de19aadbf..d8ca2eaa3a8b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -266,7 +266,7 @@ static inline void workingset_node_pages_inc(struct radix_tree_node *node)
 
 static inline void workingset_node_pages_dec(struct radix_tree_node *node)
 {
-	VM_BUG_ON(!workingset_node_pages(node));
+	VM_WARN_ON_ONCE(!workingset_node_pages(node));
 	node->count--;
 }
 
@@ -282,7 +282,7 @@ static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
 
 static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
 {
-	VM_BUG_ON(!workingset_node_shadows(node));
+	VM_WARN_ON_ONCE(!workingset_node_shadows(node));
 	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
