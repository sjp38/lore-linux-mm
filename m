Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 813DF6B0276
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:01:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t18-v6so1544561plo.16
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:01:44 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id v12-v6si1911386pgn.547.2018.10.12.11.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:01:43 -0700 (PDT)
Subject: [PATCH v7 2/7] mm,
 devm_memremap_pages: Kill mapping "System RAM" support
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 12 Oct 2018 10:49:42 -0700
Message-ID: <153936658214.1198040.2213860996894588505.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Given the fact that devm_memremap_pages() requires a percpu_ref that is
torn down by devm_memremap_pages_release() the current support for
mapping RAM is broken.

Support for remapping "System RAM" has been broken since the beginning
and there is no existing user of this this code path, so just kill the
support and make it an explicit error.

This cleanup also simplifies a follow-on patch to fix the error path
when setting a devm release action for devm_memremap_pages_release()
fails.

Reviewed-by: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 1bbb2e892941..871d81bf0c69 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -167,15 +167,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	is_ram = region_intersects(align_start, align_size,
 		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
 
-	if (is_ram == REGION_MIXED) {
-		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
-				__func__, res);
+	if (is_ram != REGION_DISJOINT) {
+		WARN_ONCE(1, "%s attempted on %s region %pr\n", __func__,
+				is_ram == REGION_MIXED ? "mixed" : "ram", res);
 		return ERR_PTR(-ENXIO);
 	}
 
-	if (is_ram == REGION_INTERSECTS)
-		return __va(res->start);
-
 	if (!pgmap->ref)
 		return ERR_PTR(-EINVAL);
 
