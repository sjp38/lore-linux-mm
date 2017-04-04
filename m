Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EDD26B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 12:51:57 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v75so21645906qkb.23
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 09:51:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m23si15493627qke.157.2017.04.04.09.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 09:51:56 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH] mm, memory_hotplug: fix devm_memremap_pages() after memory_hotplug rework
Date: Tue,  4 Apr 2017 12:51:44 -0400
Message-Id: <20170404165144.29791-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>

Just a trivial fix.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index faa9276..bbbe646 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -366,7 +366,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	error = arch_add_memory(nid, align_start, align_size);
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start, align_size);
+					align_start >> PAGE_SHIFT,
+					align_size >> PAGE_SHIFT);
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
