Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D11006B0269
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:18:49 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id v7-v6so31240097plo.23
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:18:49 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r15-v6si34776466pgh.88.2018.10.22.13.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 13:18:48 -0700 (PDT)
Subject: [PATCH 7/9] dax/kmem: actually perform memory hotplug
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 22 Oct 2018 13:13:29 -0700
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
Message-Id: <20181022201329.518577A4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com


This is the meat of this whole series.  When the "kmem" device's
probe function is called and we know we have a good persistent
memory device, hotplug the memory back into the main kernel.

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>

---

 b/drivers/dax/kmem.c |   28 +++++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff -puN drivers/dax/kmem.c~dax-kmem-hotplug drivers/dax/kmem.c
--- a/drivers/dax/kmem.c~dax-kmem-hotplug	2018-10-22 13:12:24.069930387 -0700
+++ b/drivers/dax/kmem.c	2018-10-22 13:12:24.072930387 -0700
@@ -55,10 +55,12 @@ static void dax_kmem_percpu_kill(void *d
 static int dax_kmem_probe(struct device *dev)
 {
 	void *addr;
+	int numa_node;
 	struct resource res;
 	int rc, id, region_id;
 	struct nd_pfn_sb *pfn_sb;
 	struct dev_dax *dev_dax;
+	struct resource *new_res;
 	struct dax_kmem *dax_kmem;
 	struct nd_namespace_io *nsio;
 	struct dax_region *dax_region;
@@ -86,13 +88,30 @@ static int dax_kmem_probe(struct device
 
 	pfn_sb = nd_pfn->pfn_sb;
 
-	if (!devm_request_mem_region(dev, nsio->res.start,
-				resource_size(&nsio->res),
-				dev_name(&ndns->dev))) {
+	new_res = devm_request_mem_region(dev, nsio->res.start,
+					  resource_size(&nsio->res),
+					  "System RAM (pmem)");
+	if (!new_res) {
 		dev_warn(dev, "could not reserve region %pR\n", &nsio->res);
 		return -EBUSY;
 	}
 
+	/*
+	 * Set flags appropriate for System RAM.  Leave ..._BUSY clear
+	 * so that add_memory() can add a child resource.
+	 */
+	new_res->flags = IORESOURCE_SYSTEM_RAM;
+
+	numa_node = dev_to_node(dev);
+	if (numa_node < 0) {
+		pr_warn_once("bad numa_node: %d, forcing to 0\n", numa_node);
+		numa_node = 0;
+	}
+
+	rc = add_memory(numa_node, nsio->res.start, resource_size(&nsio->res));
+	if (rc)
+		return rc;
+
 	dax_kmem->dev = dev;
 	init_completion(&dax_kmem->cmp);
 	rc = percpu_ref_init(&dax_kmem->ref, dax_kmem_percpu_release, 0,
@@ -106,6 +125,9 @@ static int dax_kmem_probe(struct device
 		return rc;
 
 	dax_kmem->pgmap.ref = &dax_kmem->ref;
+
+	dax_kmem->pgmap.res.name = "name_kmem_override2";
+
 	addr = devm_memremap_pages(dev, &dax_kmem->pgmap);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
_
