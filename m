Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f171.google.com (mail-gg0-f171.google.com [209.85.161.171])
	by kanga.kvack.org (Postfix) with ESMTP id C305E6B0036
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 00:56:35 -0500 (EST)
Received: by mail-gg0-f171.google.com with SMTP id q4so200502ggn.30
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:56:35 -0800 (PST)
Received: from mail-gg0-x231.google.com (mail-gg0-x231.google.com [2607:f8b0:4002:c02::231])
        by mx.google.com with ESMTPS id q69si14068977yhd.70.2014.01.22.21.56.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 21:56:34 -0800 (PST)
Received: by mail-gg0-f177.google.com with SMTP id f4so198324ggn.8
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:56:34 -0800 (PST)
Date: Wed, 22 Jan 2014 21:56:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: ignore pageblock skip when manually invoking
 compaction
Message-ID: <alpine.DEB.2.02.1401222154220.7503@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The cached pageblock hint should be ignored when triggering compaction
through /proc/sys/vm/compact_memory so all eligible memory is isolated.  
Manually invoking compaction is known to be expensive, there's no need to
skip pageblocks based on heuristics (mainly for debugging).

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1177,6 +1177,7 @@ static void compact_node(int nid)
 	struct compact_control cc = {
 		.order = -1,
 		.sync = true,
+		.ignore_skip_hint = true,
 	};
 
 	__compact_pgdat(NODE_DATA(nid), &cc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
