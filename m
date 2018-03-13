Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 646546B0006
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 18:43:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id g199so791245qke.18
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 15:43:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m63si774471qkb.269.2018.03.13.15.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 15:43:10 -0700 (PDT)
From: Daniel Vacek <neelx@redhat.com>
Subject: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
Date: Tue, 13 Mar 2018 23:42:40 +0100
Message-Id: <20180313224240.25295-1-neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Sudeep Holla <sudeep.holla@arm.com>, Naresh Kamboju <naresh.kamboju@linaro.org>, Daniel Vacek <neelx@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

On some architectures (reported on arm64) commit 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
causes a boot hang. This patch fixes the hang making sure the alignment
never steps back.

Link: http://lkml.kernel.org/r/0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com
Fixes: 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
Signed-off-by: Daniel Vacek <neelx@redhat.com>
Tested-by: Sudeep Holla <sudeep.holla@arm.com>
Tested-by: Naresh Kamboju <naresh.kamboju@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Paul Burton <paul.burton@imgtec.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>
---
 mm/page_alloc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3d974cb2a1a1..e033a6895c6f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5364,9 +5364,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			 * is not. move_freepages_block() can shift ahead of
 			 * the valid region but still depends on correct page
 			 * metadata.
+			 * Also make sure we never step back.
 			 */
-			pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
+			unsigned long next_pfn;
+
+			next_pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
 					~(pageblock_nr_pages-1)) - 1;
+			if (next_pfn > pfn)
+				pfn = next_pfn;
 #endif
 			continue;
 		}
-- 
2.16.2
