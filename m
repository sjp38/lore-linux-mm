Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1896B0010
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:07:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so5146609pld.23
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:07:21 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id n6-v6si5541394pla.398.2018.07.06.12.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 12:07:20 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH] mm/sparse.c: fix error path in sparse_add_one_section
Date: Fri,  6 Jul 2018 13:06:58 -0600
Message-Id: <20180706190658.6873-1-ross.zwisler@linux.intel.com>
in-reply-to: <CAOxpaSVkLh23jN_=0GpZ77EhKdAYaiWKkppnxWwf_MRa5FvopA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com, linux-nvdimm@lists.01.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, osalvador@techadventures.net, bhe@redhat.com, Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, osalvador@suse.de

The following commit in -next:

commit 054620849110 ("mm/sparse.c: make sparse_init_one_section void and
remove check")

changed how the error handling in sparse_add_one_section() works.

Previously sparse_index_init() could return -EEXIST, and the function would
continue on happily.  'ret' would get unconditionally overwritten by the
result from sparse_init_one_section() and the error code after the 'out:'
label wouldn't be triggered.

With the above referenced commit, though, an -EEXIST error return from
sparse_index_init() now takes us through the function and into the error
case after 'out:'.  This eventually causes a kernel BUG, probably because
we've just freed a memory section that we successfully set up and marked as
present:

  BUG: unable to handle kernel paging request at ffffea0005000080
  RIP: 0010:memmap_init_zone+0x154/0x1cf

  Call Trace:
   move_pfn_range_to_zone+0x168/0x180
   devm_memremap_pages+0x29b/0x480
   pmem_attach_disk+0x1ae/0x6c0 [nd_pmem]
   ? devm_memremap+0x79/0xb0
   nd_pmem_probe+0x7e/0xa0 [nd_pmem]
   nvdimm_bus_probe+0x6e/0x160 [libnvdimm]
   driver_probe_device+0x310/0x480
   __device_attach_driver+0x86/0x100
   ? __driver_attach+0x110/0x110
   bus_for_each_drv+0x6e/0xb0
   __device_attach+0xe2/0x160
   device_initial_probe+0x13/0x20
   bus_probe_device+0xa6/0xc0
   device_add+0x41b/0x660
   ? lock_acquire+0xa3/0x210
   nd_async_device_register+0x12/0x40 [libnvdimm]
   async_run_entry_fn+0x3e/0x170
   process_one_work+0x230/0x680
   worker_thread+0x3f/0x3b0
   kthread+0x12f/0x150
   ? process_one_work+0x680/0x680
   ? kthread_create_worker_on_cpu+0x70/0x70
   ret_from_fork+0x3a/0x50

Fix this by clearing 'ret' back to 0 if sparse_index_init() returns
-EEXIST.  This restores the previous behavior.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 mm/sparse.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 9574113fc745..d254bd2d3289 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -753,8 +753,12 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	 * plus, it does a kmalloc
 	 */
 	ret = sparse_index_init(section_nr, pgdat->node_id);
-	if (ret < 0 && ret != -EEXIST)
-		return ret;
+	if (ret < 0) {
+		if (ret == -EEXIST)
+			ret = 0;
+		else
+			return ret;
+	}
 	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
 	if (!memmap)
 		return -ENOMEM;
-- 
2.14.4
