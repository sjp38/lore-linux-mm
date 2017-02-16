Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC18C681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 16:57:59 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f5so39255264pgi.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 13:57:59 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c66si8183303pfb.26.2017.02.16.13.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 13:57:59 -0800 (PST)
Subject: [PATCH v2 1/2] mm,
 devm_memremap_pages: hold device_hotplug lock over
 mem_hotplug_{begin, done}
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 16 Feb 2017 13:53:53 -0800
Message-ID: <148728203365.38457.17804568297887708345.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148728202805.38457.18028105614854319884.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148728202805.38457.18028105614854319884.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>, linux-nvdimm@lists.01.org, Logan Gunthorpe <logang@deltatee.com>, stable@vger.kernel.org, linux-mm@kvack.org, Ben Hutchings <ben@decadent.org.uk>, Vlastimil Babka <vbabka@suse.cz>

The mem_hotplug_{begin,done} lock coordinates with
{get,put}_online_mems() to hold off "readers" of the current state of
memory from new hotplug actions. mem_hotplug_begin() expects exclusive
access, via the device_hotplug lock, to set mem_hotplug.active_writer.
Calling mem_hotplug_begin() without locking device_hotplug can lead to
corrupting mem_hotplug.refcount and missed wakeups / soft lockups.

Cc: <stable@vger.kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Fixes: f931ab479dd2 ("mm: fix devm_memremap_pages crash, use mem_hotplug_{begin, done}")
Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 9ecedc28b928..06123234f118 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -246,9 +246,13 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
+
+	lock_device_hotplug();
 	mem_hotplug_begin();
 	arch_remove_memory(align_start, align_size);
 	mem_hotplug_done();
+	unlock_device_hotplug();
+
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
@@ -360,9 +364,11 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_pfn_remap;
 
+	lock_device_hotplug();
 	mem_hotplug_begin();
 	error = arch_add_memory(nid, align_start, align_size, true);
 	mem_hotplug_done();
+	unlock_device_hotplug();
 	if (error)
 		goto err_add_memory;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
