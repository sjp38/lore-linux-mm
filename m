Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 089656B0009
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 08:38:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g13so11049984wrh.23
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:38:20 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l14si161235edd.252.2018.03.05.05.38.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 05:38:19 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 2/3] mm: add indirectly reclaimable memory to MemAvailable
Date: Mon, 5 Mar 2018 13:37:41 +0000
Message-ID: <20180305133743.12746-3-guro@fb.com>
In-Reply-To: <20180305133743.12746-1-guro@fb.com>
References: <20180305133743.12746-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This patch adjusts /proc/meminfo MemAvailable calculation
by adding the amount of indirectly reclaimable memory
(rounded to the PAGE_SIZE).

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 mm/page_alloc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2836bc9e0999..2247cda9e94e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4695,6 +4695,13 @@ long si_mem_available(void)
 		     min(global_node_page_state(NR_SLAB_RECLAIMABLE) / 2,
 			 wmark_low);
 
+	/*
+	 * Part of the kernel memory, which can be released under memory
+	 * pressure.
+	 */
+	available += global_node_page_state(NR_INDIRECTLY_RECLAIMABLE_BYTES) >>
+		PAGE_SHIFT;
+
 	if (available < 0)
 		available = 0;
 	return available;
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
