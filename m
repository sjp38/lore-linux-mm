Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEDC6B000C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:06:44 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d18-v6so3304993qtj.20
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:06:44 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d23-v6si6461778qtp.373.2018.08.16.03.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 03:06:43 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 2/5] mm/memory_hotplug: enforce section alignment when onlining/offlining
Date: Thu, 16 Aug 2018 12:06:25 +0200
Message-Id: <20180816100628.26428-3-david@redhat.com>
In-Reply-To: <20180816100628.26428-1-david@redhat.com>
References: <20180816100628.26428-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, David Hildenbrand <david@redhat.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

onlining/offlining code works on whole sections, so let's enforce that.
Existing code only allows to add memory in memory block size. And only
whole memory blocks can be onlined/offlined. Memory blocks are always
aligned to sections, so this should not break anything.

online_pages/offline_pages will implicitly mark whole sections
online/offline, so the code really can only handle such granularities.

(especially offlining code cannot deal with pageblock_nr_pages but
 theoretically only MAX_ORDER-1)

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 090cf474de87..30d2fa42b0bb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -897,6 +897,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	struct memory_notify arg;
 	struct memory_block *mem;
 
+	if (!IS_ALIGNED(pfn, PAGES_PER_SECTION))
+		return -EINVAL;
+	if (!IS_ALIGNED(nr_pages, PAGES_PER_SECTION))
+		return -EINVAL;
+
 	/*
 	 * We can't use pfn_to_nid() because nid might be stored in struct page
 	 * which is not yet initialized. Instead, we find nid from memory block.
@@ -1600,10 +1605,9 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	struct zone *zone;
 	struct memory_notify arg;
 
-	/* at least, alignment against pageblock is necessary */
-	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
+	if (!IS_ALIGNED(start_pfn, PAGES_PER_SECTION))
 		return -EINVAL;
-	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
+	if (!IS_ALIGNED(nr_pages, PAGES_PER_SECTION))
 		return -EINVAL;
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
-- 
2.17.1
