Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69D746B000A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:18:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z10-v6so516384pfd.5
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:18:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m17-v6si35751470pgj.155.2018.10.22.13.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 13:18:41 -0700 (PDT)
Subject: [PATCH 3/9] dax: add more kmem device infrastructure
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 22 Oct 2018 13:13:22 -0700
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
Message-Id: <20181022201322.6C8A7B2A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com


The previous patch is a simple copy of the pmem driver.  This
makes it easy while this is in development to keep the pmem
and kmem code in sync.

This actually adds some necessary infrastructure for the new
driver to compile.

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

 b/drivers/dax/kmem.c         |   10 +++++-----
 b/include/uapi/linux/ndctl.h |    2 ++
 2 files changed, 7 insertions(+), 5 deletions(-)

diff -puN drivers/dax/kmem.c~dax-kmem-try-again-2018-2-header drivers/dax/kmem.c
--- a/drivers/dax/kmem.c~dax-kmem-try-again-2018-2-header	2018-10-22 13:12:22.000930392 -0700
+++ b/drivers/dax/kmem.c	2018-10-22 13:12:22.005930392 -0700
@@ -27,7 +27,7 @@ static struct dax_kmem *to_dax_kmem(stru
 
 static void dax_kmem_percpu_release(struct percpu_ref *ref)
 {
-	struct dax_kmem *dax_kmem = to_dax_pmem(ref);
+	struct dax_kmem *dax_kmem = to_dax_kmem(ref);
 
 	dev_dbg(dax_kmem->dev, "trace\n");
 	complete(&dax_kmem->cmp);
@@ -36,7 +36,7 @@ static void dax_kmem_percpu_release(stru
 static void dax_kmem_percpu_exit(void *data)
 {
 	struct percpu_ref *ref = data;
-	struct dax_kmem *dax_kmem = to_dax_pmem(ref);
+	struct dax_kmem *dax_kmem = to_dax_kmem(ref);
 
 	dev_dbg(dax_kmem->dev, "trace\n");
 	wait_for_completion(&dax_kmem->cmp);
@@ -46,7 +46,7 @@ static void dax_kmem_percpu_exit(void *d
 static void dax_kmem_percpu_kill(void *data)
 {
 	struct percpu_ref *ref = data;
-	struct dax_kmem *dax_kmem = to_dax_pmem(ref);
+	struct dax_kmem *dax_kmem = to_dax_kmem(ref);
 
 	dev_dbg(dax_kmem->dev, "trace\n");
 	percpu_ref_kill(ref);
@@ -142,11 +142,11 @@ static struct nd_device_driver dax_kmem_
 	.drv = {
 		.name = "dax_kmem",
 	},
-	.type = ND_DRIVER_DAX_PMEM,
+	.type = ND_DRIVER_DAX_KMEM,
 };
 
 module_nd_driver(dax_kmem_driver);
 
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Intel Corporation");
-MODULE_ALIAS_ND_DEVICE(ND_DEVICE_DAX_PMEM);
+MODULE_ALIAS_ND_DEVICE(ND_DEVICE_DAX_KMEM);
diff -puN include/uapi/linux/ndctl.h~dax-kmem-try-again-2018-2-header include/uapi/linux/ndctl.h
--- a/include/uapi/linux/ndctl.h~dax-kmem-try-again-2018-2-header	2018-10-22 13:12:22.002930392 -0700
+++ b/include/uapi/linux/ndctl.h	2018-10-22 13:12:22.005930392 -0700
@@ -197,6 +197,7 @@ static inline const char *nvdimm_cmd_nam
 #define ND_DEVICE_NAMESPACE_PMEM 5  /* PMEM namespace (may alias with BLK) */
 #define ND_DEVICE_NAMESPACE_BLK 6   /* BLK namespace (may alias with PMEM) */
 #define ND_DEVICE_DAX_PMEM 7        /* Device DAX interface to pmem */
+#define ND_DEVICE_DAX_KMEM 8        /* Normal kernel-managed system memory */
 
 enum nd_driver_flags {
 	ND_DRIVER_DIMM            = 1 << ND_DEVICE_DIMM,
@@ -206,6 +207,7 @@ enum nd_driver_flags {
 	ND_DRIVER_NAMESPACE_PMEM  = 1 << ND_DEVICE_NAMESPACE_PMEM,
 	ND_DRIVER_NAMESPACE_BLK   = 1 << ND_DEVICE_NAMESPACE_BLK,
 	ND_DRIVER_DAX_PMEM	  = 1 << ND_DEVICE_DAX_PMEM,
+	ND_DRIVER_DAX_KMEM	  = 1 << ND_DEVICE_DAX_KMEM,
 };
 
 enum {
_
