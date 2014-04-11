Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1A71A82966
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 16:42:43 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so5706335pdb.14
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:42:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id as3si4891148pbc.49.2014.04.11.13.42.34
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 13:42:35 -0700 (PDT)
Subject: [PATCH] [v2] mm: pass VM_BUG_ON() reason to dump_page()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 11 Apr 2014 13:42:32 -0700
Message-Id: <20140411204232.C8CF1A7A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com


Changes from v1:
 * Fix tabs before spaces in the multi-line #define

--
From: Dave Hansen <dave.hansen@linux.intel.com>

I recently added a patch to let folks pass a "reason" string
dump_page() which gets dumped out along with the page's data.
This essentially saves the bug-reader a trip in to the source
to figure out why we BUG_ON()'d.

The new VM_BUG_ON_PAGE() passes in NULL for "reason".  It seems
like we might as well pass the BUG_ON() condition if we have it.
This will bloat kernels a bit with ~160 new strings, but this
is all under a debugging option anyway.

	page:ffffea0008560280 count:1 mapcount:0 mapping:(null) index:0x0
	page flags: 0xbfffc0000000001(locked)
	page dumped because: VM_BUG_ON_PAGE(PageLocked(page))
	------------[ cut here ]------------
	kernel BUG at /home/davehans/linux.git/mm/filemap.c:464!
	invalid opcode: 0000 [#1] SMP
	CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.14.0+ #251
	Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
	...


Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---

 b/include/linux/mmdebug.h |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff -puN include/linux/mmdebug.h~pass-VM_BUG_ON-reason-to-dump_page include/linux/mmdebug.h
--- a/include/linux/mmdebug.h~pass-VM_BUG_ON-reason-to-dump_page	2014-04-11 13:39:26.313125298 -0700
+++ b/include/linux/mmdebug.h	2014-04-11 13:40:26.417835916 -0700
@@ -9,8 +9,13 @@ extern void dump_page_badflags(struct pa
 
 #ifdef CONFIG_DEBUG_VM
 #define VM_BUG_ON(cond) BUG_ON(cond)
-#define VM_BUG_ON_PAGE(cond, page) \
-	do { if (unlikely(cond)) { dump_page(page, NULL); BUG(); } } while (0)
+#define VM_BUG_ON_PAGE(cond, page)						\
+	do {									\
+		if (unlikely(cond)) {						\
+			dump_page(page, "VM_BUG_ON_PAGE(" __stringify(cond)")");\
+			BUG();							\
+		}								\
+	} while (0)
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
