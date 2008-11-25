Date: Tue, 25 Nov 2008 21:36:11 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 1/9] swapfile: swapon needs larger size type
In-Reply-To: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252135140.17555@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

sys_swapon()'s swapfilesize (better renamed swapfilepages) is declared
as an int, but should be an unsigned long like the maxpages it's compared
against: on 64-bit (with 4kB pages) a swapfile of 2^44 bytes was rejected
with "Swap area shorter than signature indicates".

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
mkswap needs its own fixes for this: I'll be sending to Karel.

 mm/swapfile.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- swapfile0/mm/swapfile.c	2008-11-24 13:27:00.000000000 +0000
+++ swapfile1/mm/swapfile.c	2008-11-25 12:41:17.000000000 +0000
@@ -1452,7 +1452,7 @@ asmlinkage long sys_swapon(const char __
 	int nr_extents = 0;
 	sector_t span;
 	unsigned long maxpages = 1;
-	int swapfilesize;
+	unsigned long swapfilepages;
 	unsigned short *swap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
@@ -1530,7 +1530,7 @@ asmlinkage long sys_swapon(const char __
 		goto bad_swap;
 	}
 
-	swapfilesize = i_size_read(inode) >> PAGE_SHIFT;
+	swapfilepages = i_size_read(inode) >> PAGE_SHIFT;
 
 	/*
 	 * Read the swap header.
@@ -1607,7 +1607,7 @@ asmlinkage long sys_swapon(const char __
 		error = -EINVAL;
 		if (!maxpages)
 			goto bad_swap;
-		if (swapfilesize && maxpages > swapfilesize) {
+		if (swapfilepages && maxpages > swapfilepages) {
 			printk(KERN_WARNING
 			       "Swap area shorter than signature indicates\n");
 			goto bad_swap;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
