Subject: [PATCH 2.6.17-rc1-mm3] add migratepage address space op to shmem
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 20 Apr 2006 12:00:58 -0400
Message-Id: <1145548859.5214.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Add migratepage address space op to shmem

Basic problem:  pages of a shared memory segment can only be
migrated once.

In 2.6.16 through 2.6.17-rc1, shared memory mappings do not
have a migratepage address space op.  Therefore, migrate_pages()
falls back to default processing.  In this path, it will try to
pageout() dirty pages.  Once a shared memory page has been migrated
it becomes dirty, so migrate_pages() will try to page it out.  
However, because the page count is 3 [cache + current + pte],
pageout() will return PAGE_KEEP because is_page_cache_freeable()
returns false.  This will abort all subsequent migrations.

This patch adds a migratepage address space op to shared memory
segments to avoid taking the default path.  We use the "migrate_page()"
function because it knows how to migrate dirty pages.  This allows
shared memory segment pages to migrate, subject to other conditions
such as # pte's referencing the page [page_mapcount(page)], when
requested.  

I think this is safe.  If we're migrating a shared memory page,
then we found the page via a page table, so it must be in
memory.

Can be verified with memtoy and the shmem-mbind-test script, both
available at:  http://free.linux.hp.com/~lts/Tools/

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm3/mm/shmem.c
===================================================================
--- linux-2.6.17-rc1-mm3.orig/mm/shmem.c	2006-04-19 17:29:09.000000000 -0400
+++ linux-2.6.17-rc1-mm3/mm/shmem.c	2006-04-19 17:29:36.000000000 -0400
@@ -46,6 +46,8 @@
 #include <linux/mempolicy.h>
 #include <linux/namei.h>
 #include <linux/ctype.h>
+#include <linux/migrate.h>
+
 #include <asm/uaccess.h>
 #include <asm/div64.h>
 #include <asm/pgtable.h>
@@ -2165,6 +2167,7 @@ static struct address_space_operations s
 	.prepare_write	= shmem_prepare_write,
 	.commit_write	= simple_commit_write,
 #endif
+	.migratepage	= migrate_page,
 };
 
 static struct file_operations shmem_file_operations = {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
