Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEEC6B0010
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:30:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f13-v6so16579304wrr.4
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:30:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k18-v6sor6205205wrv.2.2018.10.15.08.30.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 08:30:55 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 3/5] mm/memory_hotplug: Check for IORESOURCE_SYSRAM in release_mem_region_adjustable
Date: Mon, 15 Oct 2018 17:30:32 +0200
Message-Id: <20181015153034.32203-4-osalvador@techadventures.net>
In-Reply-To: <20181015153034.32203-1-osalvador@techadventures.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This is a preparation for the next patch.

Currently, we only call release_mem_region_adjustable() in __remove_pages
if the zone is not ZONE_DEVICE, because resources that belong to
HMM/devm are being released by themselves with devm_release_mem_region.

Since we do not want to touch any zone/page stuff during the removing
of the memory (but during the offlining), we do not want to check for
the zone here.
So we need another way to tell release_mem_region_adjustable() to not
realease the resource in case it belongs to HMM/devm.

HMM/devm acquires/releases a resource through
devm_request_mem_region/devm_release_mem_region.

These resources have the flag IORESOURCE_MEM, while resources acquired by
hot-add memory path (register_memory_resource()) contain
IORESOURCE_SYSTEM_RAM.

So, we can check for this flag in release_mem_region_adjustable, and if
the resource does not contain such flag, we know that we are dealing with
a HMM/devm resource, so we can back off.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 kernel/resource.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/kernel/resource.c b/kernel/resource.c
index 81937830a42f..c45decd7d6af 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1272,6 +1272,22 @@ int release_mem_region_adjustable(struct resource *parent,
 			continue;
 		}
 
+		/*
+		 * All memory regions added from memory-hotplug path
+		 * have the flag IORESOURCE_SYSTEM_RAM.
+		 * If the resource does not have this flag, we know that
+		 * we are dealing with a resource coming from HMM/devm.
+		 * HMM/devm use another mechanism to add/release a resource.
+		 * This goes via devm_request_mem_region and
+		 * devm_release_mem_region.
+		 * HMM/devm take care to release their resources when they want,
+		 * so if we are dealing with them, let us just back off here.
+		 */
+		if (!(res->flags & IORESOURCE_SYSRAM)) {
+			ret = 0;
+			break;
+		}
+
 		if (!(res->flags & IORESOURCE_MEM))
 			break;
 
-- 
2.13.6
