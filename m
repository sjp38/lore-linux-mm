Date: Fri, 2 Feb 2007 06:51:42 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] mm: half-fix page tail zeroing on write problem
Message-ID: <20070202055142.GA5004@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

For no important reason, I've again looked at those zeroing patches that
Neil did a while back. I've always thought that a simple
`write(fd, NULL, size)` would cause the same sorts of problems.

Turns out it does. If you first write all 1s into a page, then do the
`write(fd, NULL, size)` at the same position, you end up with all 0s in
the page (test-case available on request).  Incredible; surely this
violates the spec?

The buffered-write fixes I've got actually fix this properly, but  they
don't look like getting merged any time soon. We could do this simple
patch which just reduces the chance of corruption from a certainty down
to a small race.

Any thoughts?

-- 
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2007-02-02 13:41:21.000000000 +1100
+++ linux-2.6/include/linux/pagemap.h	2007-02-02 13:42:09.000000000 +1100
@@ -198,6 +198,9 @@ static inline int fault_in_pages_writeab
 {
 	int ret;
 
+	if (unlikely(size == 0))
+		return 0;
+
 	/*
 	 * Writing zeroes into userspace here is OK, because we know that if
 	 * the zero gets there, we'll be overwriting it.
@@ -217,19 +220,23 @@ static inline int fault_in_pages_writeab
 	return ret;
 }
 
-static inline void fault_in_pages_readable(const char __user *uaddr, int size)
+static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 {
 	volatile char c;
 	int ret;
 
+	if (unlikely(size == 0))
+		return 0;
+
 	ret = __get_user(c, uaddr);
 	if (ret == 0) {
 		const char __user *end = uaddr + size - 1;
 
 		if (((unsigned long)uaddr & PAGE_MASK) !=
 				((unsigned long)end & PAGE_MASK))
-		 	__get_user(c, end);
+		 	ret = __get_user(c, end);
 	}
+	return ret;
 }
 
 #endif /* _LINUX_PAGEMAP_H */
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-02-02 13:42:40.000000000 +1100
+++ linux-2.6/mm/filemap.c	2007-02-02 14:00:19.000000000 +1100
@@ -2112,7 +2112,10 @@ generic_file_buffered_write(struct kiocb
 		 * same page as we're writing to, without it being marked
 		 * up-to-date.
 		 */
-		fault_in_pages_readable(buf, bytes);
+		if (fault_in_pages_readable(buf, bytes)) {
+			status = -EFAULT;
+			break;
+		}
 
 		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
 		if (!page) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
