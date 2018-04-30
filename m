Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16D466B000A
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 05:42:57 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l47-v6so4137801qtk.21
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 02:42:57 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j27si7261756qkh.366.2018.04.30.02.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 02:42:56 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RCFv2 5/7] mm/memory_hotplug: print only with DEBUG_VM in offline_pages()
Date: Mon, 30 Apr 2018 11:42:34 +0200
Message-Id: <20180430094236.29056-6-david@redhat.com>
In-Reply-To: <20180430094236.29056-1-david@redhat.com>
References: <20180430094236.29056-1-david@redhat.com>
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
 mm/memory_hotplug.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4c7e0efff079..d8f127754c2e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1685,7 +1685,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0)
 		goto repeat;
+#ifdef CONFIG_DEBUG_VM
 	pr_info("Offlined Pages %ld\n", offlined_pages);
+#endif
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
@@ -1720,9 +1722,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
2.14.3
