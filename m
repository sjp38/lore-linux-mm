Date: Sun, 14 Oct 2007 20:50:59 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <200710141723.l9EHNowh015023@agora.fsl.cs.sunysb.edu>
Message-ID: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
References: <200710141723.l9EHNowh015023@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Hugh Dickins <hugh@veritas.com>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Erez,

On Sun, 14 Oct 2007, Erez Zadok wrote:
> In unionfs_writepage() I tried to emulate as best possible what the lower
> f/s will have returned to the VFS.  Since tmpfs's ->writepage can return
> AOP_WRITEPAGE_ACTIVATE and re-mark its page as dirty, I did the same in
> unionfs: mark again my page as dirty, and return AOP_WRITEPAGE_ACTIVATE.
> 
> Should I be doing something different when unionfs stacks on top of tmpfs?
> (BTW, this is probably also relevant to ecryptfs.)

Look at mm/filemap.c:__filemap_fdatawrite_range(). You shouldn't be 
calling unionfs_writepage() _at all_ if the lower mapping has 
BDI_CAP_NO_WRITEBACK capability set. Perhaps something like the totally 
untested patch below?

				Pekka

---
 fs/unionfs/mmap.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

Index: linux-2.6.23-rc8/fs/unionfs/mmap.c
===================================================================
--- linux-2.6.23-rc8.orig/fs/unionfs/mmap.c
+++ linux-2.6.23-rc8/fs/unionfs/mmap.c
@@ -17,6 +17,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/backing-dev.h>
 #include "union.h"
 
 /*
@@ -144,6 +145,21 @@ out:
 	return err;
 }
 
+static int unionfs_writepages(struct address_space *mapping,
+			      struct writeback_control *wbc)
+{
+	struct inode *lower_inode;
+	struct inode *inode;
+
+	inode = mapping->host;
+	lower_inode = unionfs_lower_inode(inode);
+
+	if (!mapping_cap_writeback_dirty(lower_inode->i_mapping))
+		return 0;
+
+	return generic_writepages(mapping, wbc);
+}
+
 /*
  * readpage is called from generic_page_read and the fault handler.
  * If your file system uses generic_page_read for the read op, it
@@ -371,6 +387,7 @@ out:
 
 struct address_space_operations unionfs_aops = {
 	.writepage	= unionfs_writepage,
+	.writepages	= unionfs_writepages,
 	.readpage	= unionfs_readpage,
 	.prepare_write	= unionfs_prepare_write,
 	.commit_write	= unionfs_commit_write,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
