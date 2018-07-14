Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6325B6B026A
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 00:59:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b17-v6so20408484pff.17
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 21:59:55 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id j67-v6si67257pgc.186.2018.07.13.21.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 21:59:54 -0700 (PDT)
Subject: [PATCH v6 05/13] mm,
 madvise_inject_error: Disable MADV_SOFT_OFFLINE for ZONE_DEVICE
 pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Jul 2018 21:49:56 -0700
Message-ID: <153154379606.34503.17311881160518829077.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Given that dax / device-mapped pages are never subject to page
allocations remove them from consideration by the soft-offline
mechanism.

Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory-failure.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9d142b9b86dc..988f977db3d2 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1751,6 +1751,14 @@ int soft_offline_page(struct page *page, int flags)
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
 
+	if (is_zone_device_page(page)) {
+		pr_debug_ratelimited("soft_offline: %#lx page is device page\n",
+				pfn);
+		if (flags & MF_COUNT_INCREASED)
+			put_page(page);
+		return -EIO;
+	}
+
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
 		if (flags & MF_COUNT_INCREASED)
