Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE4136B026E
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:01:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o18-v6so9599991pgv.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:01:26 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 101-v6si2024053ple.326.2018.10.12.11.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:01:25 -0700 (PDT)
Subject: [PATCH v7 1/7] mm,
 devm_memremap_pages: Mark devm_memremap_pages() EXPORT_SYMBOL_GPL
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 12 Oct 2018 10:49:37 -0700
Message-ID: <153936657702.1198040.119388737535638846.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

devm_memremap_pages() is a facility that can create struct page entries
for any arbitrary range and give drivers the ability to subvert core
aspects of page management.

Specifically the facility is tightly integrated with the kernel's memory
hotplug functionality. It injects an altmap argument deep into the
architecture specific vmemmap implementation to allow allocating from
specific reserved pages, and it has Linux specific assumptions about
page structure reference counting relative to get_user_pages() and
get_user_pages_fast(). It was an oversight and a mistake that this was
not marked EXPORT_SYMBOL_GPL from the outset.

Again, devm_memremap_pagex() exposes and relies upon core kernel
internal assumptions and will continue to evolve along with 'struct
page', memory hotplug, and support for new memory types / topologies.
Only an in-kernel GPL-only driver is expected to keep up with this
ongoing evolution. This interface, and functionality derived from this
interface, is not suitable for kernel-external drivers.

Cc: Michal Hocko <mhocko@suse.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c                 |    2 +-
 tools/testing/nvdimm/test/iomap.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6ec81e0d7a33..1bbb2e892941 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -232,7 +232,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
  err_array:
 	return ERR_PTR(error);
 }
-EXPORT_SYMBOL(devm_memremap_pages);
+EXPORT_SYMBOL_GPL(devm_memremap_pages);
 
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
 {
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index ff9d3a5825e1..ed18a0cbc0c8 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -113,7 +113,7 @@ void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		return nfit_res->buf + offset - nfit_res->res.start;
 	return devm_memremap_pages(dev, pgmap);
 }
-EXPORT_SYMBOL(__wrap_devm_memremap_pages);
+EXPORT_SYMBOL_GPL(__wrap_devm_memremap_pages);
 
 pfn_t __wrap_phys_to_pfn_t(phys_addr_t addr, unsigned long flags)
 {
