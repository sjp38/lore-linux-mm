Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17EA96B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 23:08:33 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n85so43302496pfi.4
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 20:08:33 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id n126si29157638pga.243.2016.11.06.20.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Nov 2016 20:08:31 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id n85so84305842pfi.1
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 20:08:31 -0800 (PST)
Date: Sun, 6 Nov 2016 20:08:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] shmem: fix pageflags after swapping DMA32 object
Message-ID: <alpine.LSU.2.11.1611062003510.11253@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org

If shmem_alloc_page() does not set PageLocked and PageSwapBacked, then
shmem_replace_page() needs to do so for itself.  Without this, it puts
newpage on the wrong lru, re-unlocks the unlocked newpage, and system
descends into "Bad page" reports and freeze; or if CONFIG_DEBUG_VM=y,
it hits an earlier VM_BUG_ON_PAGE(!PageLocked), depending on config.

But shmem_replace_page() is not a common path: it's only called when
swapin (or swapoff) finds the page was already read into an unsuitable
zone: usually all zones are suitable, but gem objects for a few drm
devices (gma500, omapdrm, crestline, broadwater) require zone DMA32
if there's more than 4GB of ram.

Fixes: 800d8c63b2e9 ("shmem: add huge pages support")
Cc: stable@vger.kernel.org # v4.8
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    2 ++
 1 file changed, 2 insertions(+)

--- 4.9-rc4/mm/shmem.c	2016-10-15 12:52:13.157533478 -0700
+++ linux/mm/shmem.c	2016-11-06 12:45:49.626193769 -0800
@@ -1483,6 +1483,8 @@ static int shmem_replace_page(struct pag
 	copy_highpage(newpage, oldpage);
 	flush_dcache_page(newpage);
 
+	__SetPageLocked(newpage);
+	__SetPageSwapBacked(newpage);
 	SetPageUptodate(newpage);
 	set_page_private(newpage, swap_index);
 	SetPageSwapCache(newpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
