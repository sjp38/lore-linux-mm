Message-ID: <41131105.8040108@yahoo.com.au>
Date: Fri, 06 Aug 2004 15:03:01 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH] 3/4: writeout watermarks
References: <41130FB1.5020001@yahoo.com.au> <41130FD2.5070608@yahoo.com.au>
In-Reply-To: <41130FD2.5070608@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------060604060805040303060604"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060604060805040303060604
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

3/4

3rd attempt for this patch ;)
I have since addressed your concerns.

So for example, with a 10/40 async/sync ratio, if the sync
watermark is moved down to 20, the async mark will be moved
to 5, preserving the ratio.

--------------060604060805040303060604
Content-Type: text/x-patch;
 name="vm-tune-writeout.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-tune-writeout.patch"


Slightly change the writeout watermark calculations so we keep background
and synchronous writeout watermarks in the same ratios after adjusting them.
This ensures we should always attempt to start background writeout before
synchronous writeout.

Signed-off-by: Nick Piggin <nickpiggin@cyberone.com.au>


---

 linux-2.6-npiggin/mm/page-writeback.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff -puN mm/page-writeback.c~vm-tune-writeout mm/page-writeback.c
--- linux-2.6/mm/page-writeback.c~vm-tune-writeout	2004-08-06 14:48:45.000000000 +1000
+++ linux-2.6-npiggin/mm/page-writeback.c	2004-08-06 14:48:45.000000000 +1000
@@ -153,9 +153,11 @@ get_dirty_limits(struct writeback_state 
 	if (dirty_ratio < 5)
 		dirty_ratio = 5;
 
-	background_ratio = dirty_background_ratio;
-	if (background_ratio >= dirty_ratio)
-		background_ratio = dirty_ratio / 2;
+	/*
+	 * Keep the ratio between dirty_ratio and background_ratio roughly
+	 * what the sysctls are after dirty_ratio has been scaled (above).
+	 */
+	background_ratio = dirty_background_ratio * dirty_ratio/vm_dirty_ratio;
 
 	background = (background_ratio * total_pages) / 100;
 	dirty = (dirty_ratio * total_pages) / 100;

_

--------------060604060805040303060604--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
