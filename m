Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E8F056B0047
	for <linux-mm@kvack.org>; Wed,  6 May 2009 02:19:38 -0400 (EDT)
Received: by mail-ew0-f164.google.com with SMTP id 8so6509923ewy.38
        for <linux-mm@kvack.org>; Tue, 05 May 2009 23:19:56 -0700 (PDT)
Date: Wed, 6 May 2009 10:19:53 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [PATCH -mmotm] mm: init_per_zone_pages_min - get rid of sqrt call
	on small machines
Message-ID: <20090506061953.GA16057@lenovo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: LMMML <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

For small machines we may eliminate call for int_sqrt
by using precaulculated value.

CC: David Rientjes <rientjes@google.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 mm/page_alloc.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Index: linux-2.6.git/mm/page_alloc.c
=====================================================================
--- linux-2.6.git.orig/mm/page_alloc.c
+++ linux-2.6.git/mm/page_alloc.c
@@ -4610,11 +4610,15 @@ static int __init init_per_zone_pages_mi
 
 	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
 
-	min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
-	if (min_free_kbytes < 128)
+	/* for small values we may eliminate sqrt operation completely */
+	if (lowmem_kbytes < 1024)
 		min_free_kbytes = 128;
-	if (min_free_kbytes > 65536)
-		min_free_kbytes = 65536;
+	else {
+		min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
+		if (min_free_kbytes > 65536)
+			min_free_kbytes = 65536;
+	}
+
 	setup_per_zone_pages_min();
 	setup_per_zone_lowmem_reserve();
 	setup_per_zone_inactive_ratio();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
