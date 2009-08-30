Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E8B16B006A
	for <linux-mm@kvack.org>; Sun, 30 Aug 2009 12:19:47 -0400 (EDT)
Received: by gxk12 with SMTP id 12so4609887gxk.4
        for <linux-mm@kvack.org>; Sun, 30 Aug 2009 09:19:53 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
Subject: [PATCH] swap: Fix swap size in case of block devices
Date: Sun, 30 Aug 2009 21:49:10 +0530
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200908302149.10981.ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

During swapon, swap size is set to number of usable pages in the given
swap file/block device minus 1 (for header page). In case of block devices,
this size is incorrectly set as one page less than the actual due to an
off-by-one error. For regular files, this size is set correctly.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---

 mm/swapfile.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8ffdc0d..3d37b97 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1951,9 +1951,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (error)
 		goto bad_swap;

+	/* excluding header page */
 	nr_good_pages = swap_header->info.last_page -
-			swap_header->info.nr_badpages -
-			1 /* header page */;
+			swap_header->info.nr_badpages;

 	if (nr_good_pages) {
 		swap_map[0] = SWAP_MAP_BAD;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
