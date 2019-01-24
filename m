Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4AEC48E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:55 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o17so5035381pgi.14
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:55 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q24si23382216pls.325.2019.01.24.15.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:54 -0800 (PST)
Subject: [PATCH 2/5] mm/resource: move HMM pr_debug() deeper into resource code
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:44 -0800
References: <20190124231441.37A4A305@viggo.jf.intel.com>
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Message-Id: <20190124231444.38182DD8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, jglisse@redhat.com


From: Dave Hansen <dave.hansen@linux.intel.com>

HMM consumes physical address space for its own use, even
though nothing is mapped or accessible there.  It uses a
special resource description (IORES_DESC_DEVICE_PRIVATE_MEMORY)
to uniquely identify these areas.

When HMM consumes address space, it makes a best guess about
what to consume.  However, it is possible that a future memory
or device hotplug can collide with the reserved area.  In the
case of these conflicts, there is an error message in
register_memory_resource().

Later patches in this series move register_memory_resource()
from using request_resource_conflict() to __request_region().
Unfortunately, __request_region() does not return the conflict
like the previous function did, which makes it impossible to
check for IORES_DESC_DEVICE_PRIVATE_MEMORY in a conflicting
resource.

Instead of warning in register_memory_resource(), move the
check into the core resource code itself (__request_region())
where the conflicting resource _is_ available.  This has the
added bonus of producing a warning in case of HMM conflicts
with devices *or* RAM address space, as opposed to the RAM-
only warnings that were there previously.

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
Cc: Jerome Glisse <jglisse@redhat.com>
---

 b/kernel/resource.c   |   10 ++++++++++
 b/mm/memory_hotplug.c |    5 -----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff -puN kernel/resource.c~move-request_region-check kernel/resource.c
--- a/kernel/resource.c~move-request_region-check	2019-01-24 15:13:14.453199539 -0800
+++ b/kernel/resource.c	2019-01-24 15:13:14.458199539 -0800
@@ -1123,6 +1123,16 @@ struct resource * __request_region(struc
 		conflict = __request_resource(parent, res);
 		if (!conflict)
 			break;
+		/*
+		 * mm/hmm.c reserves physical addresses which then
+		 * become unavailable to other users.  Conflicts are
+		 * not expected.  Be verbose if one is encountered.
+		 */
+		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
+			pr_debug("Resource conflict with unaddressable "
+				 "device memory at %#010llx !\n",
+				 (unsigned long long)start);
+		}
 		if (conflict != parent) {
 			if (!(conflict->flags & IORESOURCE_BUSY)) {
 				parent = conflict;
diff -puN mm/memory_hotplug.c~move-request_region-check mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~move-request_region-check	2019-01-24 15:13:14.455199539 -0800
+++ b/mm/memory_hotplug.c	2019-01-24 15:13:14.459199539 -0800
@@ -109,11 +109,6 @@ static struct resource *register_memory_
 	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	conflict =  request_resource_conflict(&iomem_resource, res);
 	if (conflict) {
-		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
-			pr_debug("Device unaddressable memory block "
-				 "memory hotplug at %#010llx !\n",
-				 (unsigned long long)start);
-		}
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
 		return ERR_PTR(-EEXIST);
_
