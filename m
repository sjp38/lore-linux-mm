Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6DF6B0502
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:42:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u30so31895242wrc.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 06:42:12 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id e21si9546185wmc.198.2017.07.11.06.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 06:42:10 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id z45so32533583wrb.2
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 06:42:10 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] vmemmap, memory_hotplug: fallback to base pages for vmmap
Date: Tue, 11 Jul 2017 15:42:04 +0200
Message-Id: <20170711134204.20545-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

vmemmap_populate uses huge pages if the CPU supports them which is good
and usually what we want. vmemmap_alloc_block will use the bootmem
allocator in the early initialization so the allocation will most likely
succeed. This is not the case for the memory hotplug though. Such an
allocation can easily fail under memory pressure. Especially so when the
kernel memory is restricted with movable_node parameter.

There is no real reason to fail the vmemmap_populate when
vmemmap_populate_hugepages fails though. We can still fallback to
vmemmap_populate_basepages and use base pages. The performance will not
be optimal but this is much better than failing the memory hot add.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/mm/init_64.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 136422d7d539..e6e3c755b9cb 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1401,15 +1401,16 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
 	struct vmem_altmap *altmap = to_vmem_altmap(start);
-	int err;
+	int err = -ENOMEM;
 
 	if (boot_cpu_has(X86_FEATURE_PSE))
 		err = vmemmap_populate_hugepages(start, end, node, altmap);
 	else if (altmap) {
 		pr_err_once("%s: no cpu support for altmap allocations\n",
 				__func__);
-		err = -ENOMEM;
-	} else
+		return err;
+	}
+	if (err)
 		err = vmemmap_populate_basepages(start, end, node);
 	if (!err)
 		sync_global_pgds(start, end - 1);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
