Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E76F6B7E2D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 23:15:32 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i14so1350560edf.17
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 20:15:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor1675139edm.0.2018.12.06.20.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 20:15:30 -0800 (PST)
Date: Fri, 7 Dec 2018 04:15:28 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, kmemleak: Little optimization while scanning
Message-ID: <20181207041528.xs4xnw6vpsbu5csx@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181206131918.25099-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181206131918.25099-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 06, 2018 at 02:19:18PM +0100, Oscar Salvador wrote:
>kmemleak_scan() goes through all online nodes and tries
>to scan all used pages.
>We can do better and use pfn_to_online_page(), so in case we have
>CONFIG_MEMORY_HOTPLUG, offlined pages will be skiped automatically.
>For boxes where CONFIG_MEMORY_HOTPLUG is not present, pfn_to_online_page()
>will fallback to pfn_valid().
>
>Another little optimization is to check if the page belongs to the node
>we are currently checking, so in case we have nodes interleaved we will
>not check the same pfn multiple times.
>
>I ran some tests:
>
>Add some memory to node1 and node2 making it interleaved:
>
>(qemu) object_add memory-backend-ram,id=ram0,size=1G
>(qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
>(qemu) object_add memory-backend-ram,id=ram1,size=1G
>(qemu) device_add pc-dimm,id=dimm1,memdev=ram1,node=2
>(qemu) object_add memory-backend-ram,id=ram2,size=1G
>(qemu) device_add pc-dimm,id=dimm2,memdev=ram2,node=1
>
>Then, we offline that memory:
> # for i in {32..39} ; do echo "offline" > /sys/devices/system/node/node1/memory$i/state;done
> # for i in {48..55} ; do echo "offline" > /sys/devices/system/node/node1/memory$i/state;don
> # for i in {40..47} ; do echo "offline" > /sys/devices/system/node/node2/memory$i/state;done
>
>And we run kmemleak_scan:
>
> # echo "scan" > /sys/kernel/debug/kmemleak
>
>before the patch:
>
>kmemleak: time spend: 41596 us
>
>after the patch:
>
>kmemleak: time spend: 34899 us
>
>Signed-off-by: Oscar Salvador <osalvador@suse.de>
>---
> mm/kmemleak.c | 10 +++++++---
> 1 file changed, 7 insertions(+), 3 deletions(-)
>
>diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>index 877de4fa0720..5ce1e6a46d77 100644
>--- a/mm/kmemleak.c
>+++ b/mm/kmemleak.c
>@@ -113,6 +113,7 @@
> #include <linux/kmemleak.h>
> #include <linux/memory_hotplug.h>
> 
>+

This one maybe not necessary.

> /*
>  * Kmemleak configuration and common defines.
>  */
>@@ -1547,11 +1548,14 @@ static void kmemleak_scan(void)
> 		unsigned long pfn;
> 
> 		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>-			struct page *page;
>+			struct page *page = pfn_to_online_page(pfn);
>+
>+			if (!page)
>+				continue;
> 
>-			if (!pfn_valid(pfn))
>+			/* only scan pages belonging to this node */
>+			if (page_to_nid(page) != i)
> 				continue;

Not farmiliar with this situation. Is this often?

>-			page = pfn_to_page(pfn);
> 			/* only scan if page is in use */
> 			if (page_count(page) == 0)
> 				continue;
>-- 
>2.13.7

-- 
Wei Yang
Help you, Help me
