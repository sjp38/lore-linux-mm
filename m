Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD2656B0269
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 19:22:10 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g6-v6so236694plq.9
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 16:22:10 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z62-v6si22625328pfk.197.2018.06.04.16.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 16:22:09 -0700 (PDT)
Subject: [PATCH v3 06/12] mm,
 madvise_inject_error: Let memory_failure() optionally take a page
 reference
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 04 Jun 2018 16:12:12 -0700
Message-ID: <152815393199.39010.5209788235715575901.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

The madvise_inject_error() routine uses get_user_pages() to lookup the
pfn and other information for injected error, but it does not release
that pin. The assumption is that failed pages should be taken out of
circulation.

However, for dax mappings it is not possible to take pages out of
circulation since they are 1:1 physically mapped as filesystem blocks,
or device-dax capacity. They also typically represent persistent memory
which has an error clearing capability.

In preparation for adding a special handler for dax mappings, shift the
responsibility of taking the page reference to memory_failure(). I.e.
drop the page reference and do not specify MF_COUNT_INCREASED to
memory_failure().

Cc: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/madvise.c |   18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..b731933dddae 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -631,11 +631,13 @@ static int madvise_inject_error(int behavior,
 
 
 	for (; start < end; start += PAGE_SIZE << order) {
+		unsigned long pfn;
 		int ret;
 
 		ret = get_user_pages_fast(start, 1, 0, &page);
 		if (ret != 1)
 			return ret;
+		pfn = page_to_pfn(page);
 
 		/*
 		 * When soft offlining hugepages, after migrating the page
@@ -651,17 +653,27 @@ static int madvise_inject_error(int behavior,
 
 		if (behavior == MADV_SOFT_OFFLINE) {
 			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
-						page_to_pfn(page), start);
+					pfn, start);
 
 			ret = soft_offline_page(page, MF_COUNT_INCREASED);
 			if (ret)
 				return ret;
 			continue;
 		}
+
 		pr_info("Injecting memory failure for pfn %#lx at process virtual address %#lx\n",
-						page_to_pfn(page), start);
+				pfn, start);
+
+		ret = memory_failure(pfn, 0);
+
+		/*
+		 * Drop the page reference taken by get_user_pages_fast(). In
+		 * the absence of MF_COUNT_INCREASED the memory_failure()
+		 * routine is responsible for pinning the page to prevent it
+		 * from being released back to the page allocator.
+		 */
+		put_page(page);
 
-		ret = memory_failure(page_to_pfn(page), MF_COUNT_INCREASED);
 		if (ret)
 			return ret;
 	}
