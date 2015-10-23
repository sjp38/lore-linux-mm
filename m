Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 368866B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:59:33 -0400 (EDT)
Received: by ykba4 with SMTP id a4so112557927ykb.3
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:59:32 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id 85si8719379ywe.208.2015.10.23.05.59.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Oct 2015 05:59:32 -0700 (PDT)
From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH] mm: hotplug: Don't release twice the resource on error
Date: Fri, 23 Oct 2015 13:57:33 +0100
Message-ID: <1445605053-23274-1-git-send-email-julien.grall@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org
Cc: Julien Grall <julien.grall@citrix.com>, David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org

The function add_memory_resource take in parameter a resource allocated
by the caller. On error, both add_memory_resource and the caller will
release the resource via release_memory_source.

This will result to Linux crashing when the caller is trying to release
the resource:

CPU: 1 PID: 45 Comm: xenwatch Not tainted 4.3.0-rc6-00043-g5e1d6ca-dirty #170
Hardware name: XENVM-4.7 (DT)
task: ffffffc1fb2421c0 ti: ffffffc1fb270000 task.ti:
ffffffc1fb270000
PC is at __release_resource+0x28/0x8c
LR is at __release_resource+0x24/0x8c

[...]

Call trace:
[<ffffffc0000b711c>] __release_resource+0x28/0x8c
[<ffffffc0000b71a4>] release_resource+0x24/0x44
[<ffffffc00033509c>] reserve_additional_memory+0x114/0x128
[<ffffffc0003358c8>] alloc_xenballooned_pages+0x98/0x16c
[<ffffffc0003a75f0>] blkfront_gather_backend_features+0x14c/0xd68
[<ffffffc0003aa4dc>] blkback_changed+0x678/0x150c
[<ffffffc00033c538>] xenbus_otherend_changed+0x9c/0xa4
[<ffffffc00033e518>] backend_changed+0xc/0x18
[<ffffffc00033bc68>] xenwatch_thread+0xa0/0x13c
[<ffffffc0000cc51c>] kthread+0xdc/0xf4

As the caller is allocating the resource, let him handle the release.
This has been introduced by commit b75351f "mm: memory hotplug with
an existing resource".

Signed-off-by: Julien Grall <julien.grall@citrix.com>

---
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org

    The patch who introduced this issue is in xentip/for-linus-4.4. So
    this patch is a good candidate for Linus 4.4.
---
 mm/memory_hotplug.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5f394e7..0780d11 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1298,7 +1298,6 @@ error:
 	/* rollback pgdat allocation and others */
 	if (new_pgdat)
 		rollback_node_hotadd(nid, pgdat);
-	release_memory_resource(res);
 	memblock_remove(start, size);
 
 out:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
