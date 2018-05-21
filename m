Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF8446B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:45:22 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a5-v6so10778489plp.8
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:45:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q9-v6si14979324plr.144.2018.05.21.15.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:45:21 -0700 (PDT)
Subject: [PATCH 2/5] mm,
 devm_memremap_pages: handle errors allocating final devres action
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 21 May 2018 15:35:24 -0700
Message-ID: <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The last step before devm_memremap_pages() returns success is to
allocate a release action to tear the entire setup down. However, the
result from devm_add_action() is not checked.

Checking the error also means that we need to handle the fact that the
percpu_ref may not be killed by the time devm_memremap_pages_release()
runs. Add a new state flag for this case.

Cc: <stable@vger.kernel.org>
Fixes: e8d513483300 ("memremap: change devm_memremap_pages interface...")
Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memremap.h |    1 +
 kernel/memremap.c        |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 7b4899c06f49..44a7ee517513 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -115,6 +115,7 @@ struct dev_pagemap {
 	dev_page_free_t page_free;
 	struct vmem_altmap altmap;
 	bool altmap_valid;
+	bool registered;
 	struct resource res;
 	struct percpu_ref *ref;
 	struct device *dev;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index c614645227a7..30d96be5a965 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -296,7 +296,7 @@ static void devm_memremap_pages_release(void *data)
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
 
-	if (percpu_ref_tryget_live(pgmap->ref)) {
+	if (pgmap->registered && percpu_ref_tryget_live(pgmap->ref)) {
 		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
 		percpu_ref_put(pgmap->ref);
 	}
@@ -418,7 +418,11 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		percpu_ref_get(pgmap->ref);
 	}
 
-	devm_add_action(dev, devm_memremap_pages_release, pgmap);
+	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
+			pgmap);
+	if (error)
+		return ERR_PTR(error);
+	pgmap->registered = true;
 
 	return __va(res->start);
 
