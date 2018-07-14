Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC006B026C
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:00:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g26-v6so19146585pfo.7
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:00:12 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id a1-v6si13170360pgq.387.2018.07.13.22.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 22:00:11 -0700 (PDT)
Subject: [PATCH v6 07/13] mm,
 madvise_inject_error: Let memory_failure() optionally take a page
 reference
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Jul 2018 21:50:06 -0700
Message-ID: <153154380652.34503.2174920161570183766.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
 mm/madvise.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..972a9eaa898b 100644
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
@@ -651,17 +653,25 @@ static int madvise_inject_error(int behavior,
 
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
 
-		ret = memory_failure(page_to_pfn(page), MF_COUNT_INCREASED);
+		/*
+		 * Drop the page reference taken by get_user_pages_fast(). In
+		 * the absence of MF_COUNT_INCREASED the memory_failure()
+		 * routine is responsible for pinning the page to prevent it
+		 * from being released back to the page allocator.
+		 */
+		put_page(page);
+		ret = memory_failure(pfn, 0);
 		if (ret)
 			return ret;
 	}
