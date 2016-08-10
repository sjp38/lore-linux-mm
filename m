Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C094D6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 18:28:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so104161448pfx.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 15:28:08 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id k7si50564937pag.88.2016.08.10.15.28.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 15:28:07 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id y134so19983633pfg.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 15:28:07 -0700 (PDT)
Date: Wed, 10 Aug 2016 15:28:05 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: Add the ram_latent_entropy kernel parameter
Message-ID: <20160810222805.GA13733@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Emese Revfy <re.emese@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: Emese Revfy <re.emese@gmail.com>

When "ram_latent_entropy" is passed on the kernel command line, entropy
will be extracted from up to the first 4GB of RAM while the runtime memory
allocator is being initialized. This entropy isn't cryptographically
secure, but does help provide additional unpredictability on otherwise
low-entropy systems.

Based on work created by the PaX Team.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
[kees: renamed parameter, dropped relationship with plugin, updated log]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This patch has been extracted from the latent_entropy gcc plugin, as
suggested by Linus: https://lkml.org/lkml/2016/8/8/840
---
 Documentation/kernel-parameters.txt |  5 +++++
 mm/page_alloc.c                     | 21 +++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 46c030a49186..9d054984370f 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3245,6 +3245,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	raid=		[HW,RAID]
 			See Documentation/md.txt.
 
+	ram_latent_entropy
+			Enable a very simple form of latent entropy extraction
+			from the first 4GB of memory as the bootmem allocator
+			passes the memory pages to the buddy allocator.
+
 	ramdisk_size=	[RAM] Sizes of RAM disks in kilobytes
 			See Documentation/blockdev/ramdisk.txt.
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fb975cec3518..1de94f0ff29d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -64,6 +64,7 @@
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
+#include <linux/random.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -1236,6 +1237,15 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
+bool __meminitdata ram_latent_entropy;
+
+static int __init setup_ram_latent_entropy(char *str)
+{
+	ram_latent_entropy = true;
+	return 0;
+}
+early_param("ram_latent_entropy", setup_ram_latent_entropy);
+
 static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
@@ -1251,6 +1261,17 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 	__ClearPageReserved(p);
 	set_page_count(p, 0);
 
+	if (ram_latent_entropy && !PageHighMem(page) &&
+		page_to_pfn(page) < 0x100000) {
+		u64 hash = 0;
+		size_t index, end = PAGE_SIZE * nr_pages / sizeof(hash);
+		const u64 *data = lowmem_page_address(page);
+
+		for (index = 0; index < end; index++)
+			hash ^= hash + data[index];
+		add_device_randomness((const void *)&hash, sizeof(hash));
+	}
+
 	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
 	__free_pages(page, order);
-- 
2.7.4


-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
