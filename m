Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 657A58E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:57 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v12so4956627plp.16
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:57 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p3si8871042plk.424.2019.01.24.15.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:56 -0800 (PST)
Subject: [PATCH 3/5] mm/memory-hotplug: allow memory resources to be children
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:45 -0800
References: <20190124231441.37A4A305@viggo.jf.intel.com>
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Message-Id: <20190124231445.5D8EEDAF@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The mm/resource.c code is used to manage the physical address
space.  The current resource configuration can be viewed in
/proc/iomem.  An example of this is at the bottom of this
description.

The nvdimm subsystem "owns" the physical address resources which
map to persistent memory and has resources inserted for them as
"Persistent Memory".  The best way to repurpose this for volatile
use is to leave the existing resource in place, but add a "System
RAM" resource underneath it. This clearly communicates the
ownership relationship of this memory.

The request_resource_conflict() API only deals with the
top-level resources.  Replace it with __request_region() which
will search for !IORESOURCE_BUSY areas lower in the resource
tree than the top level.

We *could* also simply truncate the existing top-level
"Persistent Memory" resource and take over the released address
space.  But, this means that if we ever decide to hot-unplug the
"RAM" and give it back, we need to recreate the original setup,
which may mean going back to the BIOS tables.

This should have no real effect on the existing collision
detection because the areas that truly conflict should be marked
IORESOURCE_BUSY.

00000000-00000fff : Reserved
00001000-0009fbff : System RAM
0009fc00-0009ffff : Reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c97ff : Video ROM
000c9800-000ca5ff : Adapter ROM
000f0000-000fffff : Reserved
  000f0000-000fffff : System ROM
00100000-9fffffff : System RAM
  01000000-01e071d0 : Kernel code
  01e071d1-027dfdff : Kernel data
  02dc6000-0305dfff : Kernel bss
a0000000-afffffff : Persistent Memory (legacy)
  a0000000-a7ffffff : System RAM
b0000000-bffdffff : System RAM
bffe0000-bfffffff : Reserved
c0000000-febfffff : PCI Bus 0000:00

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
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
Cc: Borislav Petkov <bp@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Jerome Glisse <jglisse@redhat.com>
---

 b/mm/memory_hotplug.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff -puN mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child	2019-01-24 15:13:14.979199537 -0800
+++ b/mm/memory_hotplug.c	2019-01-24 15:13:14.983199537 -0800
@@ -98,19 +98,21 @@ void mem_hotplug_done(void)
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
-	struct resource *res, *conflict;
-	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
-	if (!res)
-		return ERR_PTR(-ENOMEM);
+	struct resource *res;
+	unsigned long flags =  IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
+	char *resource_name = "System RAM";
 
-	res->name = "System RAM";
-	res->start = start;
-	res->end = start + size - 1;
-	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
-	conflict =  request_resource_conflict(&iomem_resource, res);
-	if (conflict) {
-		pr_debug("System RAM resource %pR cannot be added\n", res);
-		kfree(res);
+	/*
+	 * Request ownership of the new memory range.  This might be
+	 * a child of an existing resource that was present but
+	 * not marked as busy.
+	 */
+	res = __request_region(&iomem_resource, start, size,
+			       resource_name, flags);
+
+	if (!res) {
+		pr_debug("Unable to reserve System RAM region: %016llx->%016llx\n",
+				start, start + size);
 		return ERR_PTR(-EEXIST);
 	}
 	return res;
_
