Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id AD7C86B0031
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 15:10:15 -0400 (EDT)
Date: Tue, 16 Jul 2013 15:10:10 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 1/8] mm: drop actor argument of do_generic_file_read()
Message-ID: <20130716191010.GC4855@linux.intel.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1373885274-25249-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373885274-25249-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 15, 2013 at 01:47:47PM +0300, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> There's only one caller of do_generic_file_read() and the only actor is
> file_read_actor(). No reason to have a callback parameter.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

Would it make sense to do the same thing to do_shmem_file_read()?

From: Matthew Wilcox <willy@linux.intel.com>

There's only one caller of do_shmem_file_read() and the only actor is
file_read_actor(). No reason to have a callback parameter.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

diff --git a/mm/shmem.c b/mm/shmem.c
index 5e6a842..6a9c325 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1464,7 +1464,7 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 	return copied;
 }
 
-static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_t *desc, read_actor_t actor)
+static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_t *desc)
 {
 	struct inode *inode = file_inode(filp);
 	struct address_space *mapping = inode->i_mapping;
@@ -1546,13 +1546,14 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		 * Ok, we have the page, and it's up-to-date, so
 		 * now we can copy it to user space...
 		 *
-		 * The actor routine returns how many bytes were actually used..
+		 * The file_read_actor routine returns how many bytes were actually
+		 * used..
 		 * NOTE! This may not be the same as how much of a user buffer
 		 * we filled up (we may be padding etc), so we can only update
-		 * "pos" here (the actor routine has to update the user buffer
+		 * "pos" here (file_read_actor has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = actor(desc, page, offset, nr);
+		ret = file_read_actor(desc, page, offset, nr);
 		offset += ret;
 		index += offset >> PAGE_CACHE_SHIFT;
 		offset &= ~PAGE_CACHE_MASK;
@@ -1590,7 +1591,7 @@ static ssize_t shmem_file_aio_read(struct kiocb *iocb,
 		if (desc.count == 0)
 			continue;
 		desc.error = 0;
-		do_shmem_file_read(filp, ppos, &desc, file_read_actor);
+		do_shmem_file_read(filp, ppos, &desc);
 		retval += desc.written;
 		if (desc.error) {
 			retval = retval ?: desc.error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
