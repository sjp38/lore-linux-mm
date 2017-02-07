Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A92A6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 15:28:06 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so28173548wjc.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 12:28:06 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id a40si6370780wrc.296.2017.02.07.12.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 12:28:05 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id v77so30352506wmv.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 12:28:05 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH]  mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages-fix
Date: Tue,  7 Feb 2017 21:27:55 +0100
Message-Id: <20170207202755.24571-1-mhocko@kernel.org>
In-Reply-To: <20170207201950.20482-1-mhocko@kernel.org>
References: <20170207201950.20482-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

there is no need to have both pcpu_drain and pcpu_drain_mutex visible
outside of drain_all_pages. This might just attract abuse.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Andrew, Mel,
I think this would be a good cleanup to be folded into
mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages.patch.

 mm/page_alloc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b6411816787a..6c48053bcd81 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -92,10 +92,6 @@ EXPORT_PER_CPU_SYMBOL(_numa_mem_);
 int _node_numa_mem_[MAX_NUMNODES];
 #endif
 
-/* work_structs for global per-cpu drains */
-DEFINE_MUTEX(pcpu_drain_mutex);
-DEFINE_PER_CPU(struct work_struct, pcpu_drain);
-
 #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
 volatile unsigned long latent_entropy __latent_entropy;
 EXPORT_SYMBOL(latent_entropy);
@@ -2364,6 +2360,8 @@ static void drain_local_pages_wq(struct work_struct *work)
  */
 void drain_all_pages(struct zone *zone)
 {
+	static DEFINE_PER_CPU(struct work_struct, pcpu_drain);
+	static DEFINE_MUTEX(pcpu_drain_mutex);
 	int cpu;
 
 	/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
