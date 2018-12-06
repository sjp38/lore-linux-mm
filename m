Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5096B7A43
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 08:19:36 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so364868edc.13
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 05:19:36 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id d1si281663edb.435.2018.12.06.05.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 05:19:34 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [PATCH] mm, kmemleak: Little optimization while scanning
Date: Thu,  6 Dec 2018 14:19:18 +0100
Message-Id: <20181206131918.25099-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

kmemleak_scan() goes through all online nodes and tries
to scan all used pages.
We can do better and use pfn_to_online_page(), so in case we have
CONFIG_MEMORY_HOTPLUG, offlined pages will be skiped automatically.
For boxes where CONFIG_MEMORY_HOTPLUG is not present, pfn_to_online_page()
will fallback to pfn_valid().

Another little optimization is to check if the page belongs to the node
we are currently checking, so in case we have nodes interleaved we will
not check the same pfn multiple times.

I ran some tests:

Add some memory to node1 and node2 making it interleaved:

(qemu) object_add memory-backend-ram,id=ram0,size=1G
(qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
(qemu) object_add memory-backend-ram,id=ram1,size=1G
(qemu) device_add pc-dimm,id=dimm1,memdev=ram1,node=2
(qemu) object_add memory-backend-ram,id=ram2,size=1G
(qemu) device_add pc-dimm,id=dimm2,memdev=ram2,node=1

Then, we offline that memory:
 # for i in {32..39} ; do echo "offline" > /sys/devices/system/node/node1/memory$i/state;done
 # for i in {48..55} ; do echo "offline" > /sys/devices/system/node/node1/memory$i/state;don
 # for i in {40..47} ; do echo "offline" > /sys/devices/system/node/node2/memory$i/state;done

And we run kmemleak_scan:

 # echo "scan" > /sys/kernel/debug/kmemleak

before the patch:

kmemleak: time spend: 41596 us

after the patch:

kmemleak: time spend: 34899 us

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/kmemleak.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 877de4fa0720..5ce1e6a46d77 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -113,6 +113,7 @@
 #include <linux/kmemleak.h>
 #include <linux/memory_hotplug.h>
 
+
 /*
  * Kmemleak configuration and common defines.
  */
@@ -1547,11 +1548,14 @@ static void kmemleak_scan(void)
 		unsigned long pfn;
 
 		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-			struct page *page;
+			struct page *page = pfn_to_online_page(pfn);
+
+			if (!page)
+				continue;
 
-			if (!pfn_valid(pfn))
+			/* only scan pages belonging to this node */
+			if (page_to_nid(page) != i)
 				continue;
-			page = pfn_to_page(pfn);
 			/* only scan if page is in use */
 			if (page_count(page) == 0)
 				continue;
-- 
2.13.7
