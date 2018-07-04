Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6633C6B0269
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 17:50:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u18-v6so3457621pfh.21
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 14:50:49 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 59-v6si4391678plp.496.2018.07.04.14.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 14:50:48 -0700 (PDT)
Subject: [PATCH v5 05/11] mm,
 madvise_inject_error: Let memory_failure() optionally take a page
 reference
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 14:40:49 -0700
Message-ID: <153074044986.27838.16910122305490506387.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, hch@lst.dehch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, ross.zwisler@linux.intel.com

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
