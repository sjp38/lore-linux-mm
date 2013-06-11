Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8D65E6B0037
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:32:43 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/8] mm: drop actor argument of do_generic_file_read()
Date: Tue, 11 Jun 2013 18:35:12 +0300
Message-Id: <1370964919-16187-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's only one caller of do_generic_file_read() and the only actor is
file_read_actor(). No reason to have a callback parameter.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 mm/filemap.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index e989fb1..61158ac 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1088,7 +1088,6 @@ static void shrink_readahead_size_eio(struct file *filp,
  * @filp:	the file to read
  * @ppos:	current file position
  * @desc:	read_descriptor
- * @actor:	read method
  *
  * This is a generic file read routine, and uses the
  * mapping->a_ops->readpage() function for the actual low-level stuff.
@@ -1097,7 +1096,7 @@ static void shrink_readahead_size_eio(struct file *filp,
  * of the logic when it comes to error handling etc.
  */
 static void do_generic_file_read(struct file *filp, loff_t *ppos,
-		read_descriptor_t *desc, read_actor_t actor)
+		read_descriptor_t *desc)
 {
 	struct address_space *mapping = filp->f_mapping;
 	struct inode *inode = mapping->host;
@@ -1198,13 +1197,14 @@ page_ok:
 		 * Ok, we have the page, and it's up-to-date, so
 		 * now we can copy it to user space...
 		 *
-		 * The actor routine returns how many bytes were actually used..
+		 * The file_read_actor routine returns how many bytes were
+		 * actually used..
 		 * NOTE! This may not be the same as how much of a user buffer
 		 * we filled up (we may be padding etc), so we can only update
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = actor(desc, page, offset, nr);
+		ret = file_read_actor(desc, page, offset, nr);
 		offset += ret;
 		index += offset >> PAGE_CACHE_SHIFT;
 		offset &= ~PAGE_CACHE_MASK;
@@ -1477,7 +1477,7 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
 		if (desc.count == 0)
 			continue;
 		desc.error = 0;
-		do_generic_file_read(filp, ppos, &desc, file_read_actor);
+		do_generic_file_read(filp, ppos, &desc);
 		retval += desc.written;
 		if (desc.error) {
 			retval = retval ?: desc.error;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
