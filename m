Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 526726B48F0
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:20:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so14408424pfr.6
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:20:40 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id p26si5129609pli.225.2018.11.27.08.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:20:38 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 2/5] kernel, resource: Check for IORESOURCE_SYSRAM in release_mem_region_adjustable
Date: Tue, 27 Nov 2018 17:20:02 +0100
Message-Id: <20181127162005.15833-3-osalvador@suse.de>
In-Reply-To: <20181127162005.15833-1-osalvador@suse.de>
References: <20181127162005.15833-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

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
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 kernel/resource.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/kernel/resource.c b/kernel/resource.c
index 0aaa95005a2e..e20cea416f1f 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1266,6 +1266,21 @@ int release_mem_region_adjustable(struct resource *parent,
 			continue;
 		}
 
+		/*
+		 * All memory regions added from memory-hotplug path have the
+		 * flag IORESOURCE_SYSTEM_RAM. If the resource does not have
+		 * this flag, we know that we are dealing with a resource coming
+		 * from HMM/devm. HMM/devm use another mechanism to add/release
+		 * a resource. This goes via devm_request_mem_region and
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
