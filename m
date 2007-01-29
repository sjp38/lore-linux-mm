From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070129081951.23584.52646.sendpatchset@linux.site>
In-Reply-To: <20070129081905.23584.97878.sendpatchset@linux.site>
References: <20070129081905.23584.97878.sendpatchset@linux.site>
Subject: [patch 5/9] mm: debug write deadlocks
Date: Mon, 29 Jan 2007 11:32:24 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Allow CONFIG_DEBUG_VM to switch off the prefaulting logic, to simulate the
difficult race where the page may be unmapped before calling copy_from_user.
Makes the race much easier to hit.

This is useful for demonstration and testing purposes, but is removed in a
subsequent patch.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1894,6 +1894,7 @@ generic_file_buffered_write(struct kiocb
 		if (maxlen > bytes)
 			maxlen = bytes;
 
+#ifndef CONFIG_DEBUG_VM
 		/*
 		 * Bring in the user page that we will copy from _first_.
 		 * Otherwise there's a nasty deadlock on copying from the
@@ -1901,6 +1902,7 @@ generic_file_buffered_write(struct kiocb
 		 * up-to-date.
 		 */
 		fault_in_pages_readable(buf, maxlen);
+#endif
 
 		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
 		if (!page) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
