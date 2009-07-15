Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE2D6B005D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 06:44:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/3] profile: Suppress warning about large allocations when profile=1 is specified
Date: Wed, 15 Jul 2009 12:23:11 +0100
Message-Id: <1247656992-19846-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1247656992-19846-1-git-send-email-mel@csn.ul.ie>
References: <1247656992-19846-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Heinz Diehl <htd@fancy-poultry.org>, David Miller <davem@davemloft.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When profile= is used, a large buffer is allocated early at boot. This
can be larger than what the page allocator can provide so it prints a
warning. However, the caller is able to handle the situation so this patch
suppresses the warning.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 kernel/profile.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/profile.c b/kernel/profile.c
index 69911b5..419250e 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -117,11 +117,12 @@ int __ref profile_init(void)
 
 	cpumask_copy(prof_cpu_mask, cpu_possible_mask);
 
-	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
+	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL|__GFP_NOWARN);
 	if (prof_buffer)
 		return 0;
 
-	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
+	prof_buffer = alloc_pages_exact(buffer_bytes,
+					GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN);
 	if (prof_buffer)
 		return 0;
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
