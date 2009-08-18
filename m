Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8566B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 11:33:43 -0400 (EDT)
Message-Id: <4A8AE5F50200007800010536@vpn.id2.novell.com>
Date: Tue, 18 Aug 2009 16:33:41 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] fix updating of num_physpages for hot plugged memory
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Sizing of memory allocations shouldn't depend on the number of physical
pages found in a system, as that generally includes (perhaps a huge
amount of) non-RAM pages. The amount of what actually is usable as
storage should instead be used as a basis here.

In line with that, the memory hotplug code should update num_physpages
in a way that it retains its original (post-boot) meaning; in
particular, decreasing the value should at best be done with great care
- this patch doesn't try to ever decrease this value at all as it
doesn't really seem meaningful to do so.

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Acked-by: Rusty Russell <rusty@rustcorp.com.au>

---
 mm/memory_hotplug.c               |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- linux-2.6.31-rc6/mm/memory_hotplug.c	2009-08-18 15:31:56.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/mm/memory_hotplug.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -339,8 +339,11 @@ EXPORT_SYMBOL_GPL(__remove_pages);
=20
 void online_page(struct page *page)
 {
+	unsigned long pfn =3D page_to_pfn(page);
+
 	totalram_pages++;
-	num_physpages++;
+	if (pfn >=3D num_physpages)
+		num_physpages =3D pfn + 1;
=20
 #ifdef CONFIG_HIGHMEM
 	if (PageHighMem(page))
@@ -831,7 +834,6 @@ repeat:
 	zone->present_pages -=3D offlined_pages;
 	zone->zone_pgdat->node_present_pages -=3D offlined_pages;
 	totalram_pages -=3D offlined_pages;
-	num_physpages -=3D offlined_pages;
=20
 	setup_per_zone_wmarks();
 	calculate_zone_inactive_ratio(zone);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
