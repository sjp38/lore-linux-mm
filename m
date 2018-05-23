Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFB136B000A
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:19:31 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u127-v6so22831628qka.9
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:19:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k2-v6si7245305qkf.87.2018.05.23.08.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 08:12:25 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 07/10] mm/memory_hotplug: print only with DEBUG_VM in online/offline_pages()
Date: Wed, 23 May 2018 17:11:48 +0200
Message-Id: <20180523151151.6730-8-david@redhat.com>
In-Reply-To: <20180523151151.6730-1-david@redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Thomas Gleixner <tglx@linutronix.de>

Let's try to minimze the noise.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8c0b7d85252b..27f7c27f57ac 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -943,9 +943,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
 	if (ret) {
+#ifdef CONFIG_DEBUG_VM
 		pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
 			 (unsigned long long) pfn << PAGE_SHIFT,
 			 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
+#endif
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
 		return ret;
 	}
@@ -1668,7 +1670,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0)
 		goto repeat;
+#ifdef CONFIG_DEBUG_VM
 	pr_info("Offlined Pages %ld\n", offlined_pages);
+#endif
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
@@ -1703,9 +1707,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	return 0;
 
 failed_removal:
+#ifdef CONFIG_DEBUG_VM
 	pr_debug("memory offlining [mem %#010llx-%#010llx] failed\n",
 		 (unsigned long long) start_pfn << PAGE_SHIFT,
 		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
+#endif
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
-- 
2.17.0
