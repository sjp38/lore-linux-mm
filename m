Date: Wed, 27 Dec 2006 01:03:48 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/1 2.6.20-rc2] MM: ramfs breaks without CONFIG_BLOCK
Message-Id: <20061227010348.2e84b0cd.akpm@osdl.org>
In-Reply-To: <1167152987.4591575b1a824@imp8-g19.free.fr>
References: <1167152987.4591575b1a824@imp8-g19.free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dimitri.gorokhovik@free.fr
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Dec 2006 18:09:47 +0100
dimitri.gorokhovik@free.fr wrote:

> From: Dimitri Gorokhovik <dimitri.gorokhovik@free.fr>
> 
> ramfs doesn't provide the .set_dirty_page a_op, and when the BLOCK
> layer is not configured in, 'set_page_dirty' makes a call via a NULL
> pointer.

OK.  But I think it'd be better to fill in the address_space_operations:


From: Dimitri Gorokhovik <dimitri.gorokhovik@free.fr>

ramfs doesn't provide the .set_dirty_page a_op, and when the BLOCK layer is
not configured in, 'set_page_dirty' makes a call via a NULL pointer.

Signed-off-by: Dimitri Gorokhovik <dimitri.gorokhovik@free.fr>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 fs/ramfs/file-mmu.c   |    4 +++-
 fs/ramfs/file-nommu.c |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff -puN fs/ramfs/file-mmu.c~mm-ramfs-breaks-without-config_block fs/ramfs/file-mmu.c
--- a/fs/ramfs/file-mmu.c~mm-ramfs-breaks-without-config_block
+++ a/fs/ramfs/file-mmu.c
@@ -25,11 +25,13 @@
  */
 
 #include <linux/fs.h>
+#include <linux/mm.h>
 
 const struct address_space_operations ramfs_aops = {
 	.readpage	= simple_readpage,
 	.prepare_write	= simple_prepare_write,
-	.commit_write	= simple_commit_write
+	.commit_write	= simple_commit_write,
+	.set_page_dirty = __set_page_dirty_nobuffers,
 };
 
 const struct file_operations ramfs_file_operations = {
diff -puN fs/ramfs/file-nommu.c~mm-ramfs-breaks-without-config_block fs/ramfs/file-nommu.c
--- a/fs/ramfs/file-nommu.c~mm-ramfs-breaks-without-config_block
+++ a/fs/ramfs/file-nommu.c
@@ -11,6 +11,7 @@
 
 #include <linux/module.h>
 #include <linux/fs.h>
+#include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/highmem.h>
 #include <linux/init.h>
@@ -30,7 +31,8 @@ static int ramfs_nommu_setattr(struct de
 const struct address_space_operations ramfs_aops = {
 	.readpage		= simple_readpage,
 	.prepare_write		= simple_prepare_write,
-	.commit_write		= simple_commit_write
+	.commit_write		= simple_commit_write,
+	.set_page_dirty = __set_page_dirty_nobuffers,
 };
 
 const struct file_operations ramfs_file_operations = {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
