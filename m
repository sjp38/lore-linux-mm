Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0BBF06B0037
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 21:16:36 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so5998289igd.5
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:16:35 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id hj4si50252198igb.55.2014.07.23.18.16.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 18:16:34 -0700 (PDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so5996936igd.3
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:16:34 -0700 (PDT)
Date: Wed, 23 Jul 2014 18:16:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/3] mm, oom: remove unnecessary check for NULL zonelist
In-Reply-To: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If the pagefault handler is modified to pass a non-NULL zonelist then an 
unnecessary check for a NULL zonelist in constrained_alloc() can be removed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -208,8 +208,6 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 	/* Default to all available memory */
 	*totalpages = totalram_pages + total_swap_pages;
 
-	if (!zonelist)
-		return CONSTRAINT_NONE;
 	/*
 	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
 	 * to kill current.We have to random task kill in this case.
@@ -696,7 +694,7 @@ void pagefault_out_of_memory(void)
 
 	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
 	if (try_set_zonelist_oom(zonelist, GFP_KERNEL)) {
-		out_of_memory(NULL, 0, 0, NULL, false);
+		out_of_memory(zonelist, 0, 0, NULL, false);
 		clear_zonelist_oom(zonelist, GFP_KERNEL);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
