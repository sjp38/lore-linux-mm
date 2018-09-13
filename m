Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C50B18E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 22:33:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x19-v6so2049478pfh.15
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 19:33:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p84-v6si2912481pfj.101.2018.09.12.19.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 19:33:54 -0700 (PDT)
Subject: [PATCH v5 2/7] mm,
 devm_memremap_pages: Kill mapping "System RAM" support
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Sep 2018 19:22:11 -0700
Message-ID: <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Given the fact that devm_memremap_pages() requires a percpu_ref that is
torn down by devm_memremap_pages_release() the current support for
mapping RAM is broken.

Support for remapping "System RAM" has been broken since the beginning
and there is no existing user of this this code path, so just kill the
support and make it an explicit error.

This cleanup also simplifies a follow-on patch to fix the error path
when setting a devm release action for devm_memremap_pages_release()
fails.

Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index f95c7833db6d..92e838127767 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -202,15 +202,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
 
