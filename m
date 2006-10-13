From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061013143606.15438.18462.sendpatchset@linux.site>
In-Reply-To: <20061013143516.15438.8802.sendpatchset@linux.site>
References: <20061013143516.15438.8802.sendpatchset@linux.site>
Subject: [patch 5/6] mm: debug write deadlocks
Date: Fri, 13 Oct 2006 18:44:42 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Allow CONFIG_DEBUG_VM to switch off the prefaulting logic, to simulate the
difficult race where the page may be unmapped before calling copy_from_user.
Makes the race much easier to hit.

This probably needn't go upstream.

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1895,6 +1895,7 @@ generic_file_buffered_write(struct kiocb
 		if (maxlen > bytes)
 			maxlen = bytes;
 
+#ifndef CONFIG_DEBUG_VM
 		/*
 		 * Bring in the user page that we will copy from _first_.
 		 * Otherwise there's a nasty deadlock on copying from the
@@ -1902,6 +1903,7 @@ generic_file_buffered_write(struct kiocb
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
