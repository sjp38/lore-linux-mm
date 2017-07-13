Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E071440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 17:15:38 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m54so28220930qtb.9
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 14:15:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v205si760673qkb.60.2017.07.13.14.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 14:15:37 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 1/6] mm/zone-device: rename DEVICE_PUBLIC to DEVICE_HOST
Date: Thu, 13 Jul 2017 17:15:27 -0400
Message-Id: <20170713211532.970-2-jglisse@redhat.com>
In-Reply-To: <20170713211532.970-1-jglisse@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Existing user of ZONE_DEVICE in its DEVICE_PUBLIC variant are not tie
to specific device and behave more like host memory. This patch rename
DEVICE_PUBLIC to DEVICE_HOST and free the name DEVICE_PUBLIC to be use
for cache coherent device memory that has strong tie with the device
on which the memory is (for instance on board GPU memory).

There is no functional change here.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/memremap.h | 4 ++--
 kernel/memremap.c        | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 57546a07a558..ae5ff92f72b4 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -41,7 +41,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * Specialize ZONE_DEVICE memory into multiple types each having differents
  * usage.
  *
- * MEMORY_DEVICE_PUBLIC:
+ * MEMORY_DEVICE_HOST:
  * Persistent device memory (pmem): struct page might be allocated in different
  * memory and architecture might want to perform special actions. It is similar
  * to regular memory, in that the CPU can access it transparently. However,
@@ -59,7 +59,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * include/linux/hmm.h and Documentation/vm/hmm.txt.
  */
 enum memory_type {
-	MEMORY_DEVICE_PUBLIC = 0,
+	MEMORY_DEVICE_HOST = 0,
 	MEMORY_DEVICE_PRIVATE,
 };
 
diff --git a/kernel/memremap.c b/kernel/memremap.c
index b9baa6c07918..4e07525aa273 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -350,7 +350,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	}
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
-	pgmap->type = MEMORY_DEVICE_PUBLIC;
+	pgmap->type = MEMORY_DEVICE_HOST;
 	pgmap->page_fault = NULL;
 	pgmap->page_free = NULL;
 	pgmap->data = NULL;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
