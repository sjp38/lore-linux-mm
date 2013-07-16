From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/8] mm: drop actor argument of do_generic_file_read()
Date: Tue, 16 Jul 2013 11:31:48 +0800
Message-ID: <47840.6440387063$1373945531@news.gmane.org>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1373885274-25249-2-git-send-email-kirill.shutemov@linux.intel.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Uyvze-0003KN-BI
	for glkm-linux-mm-2@m.gmane.org; Tue, 16 Jul 2013 05:32:02 +0200
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 4AB6A6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 23:31:58 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 16 Jul 2013 08:54:15 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 7FB7C3940058
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:01:47 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6G3WZE727459834
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:02:35 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6G3Vnrc013142
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 13:31:49 +1000
Content-Disposition: inline
In-Reply-To: <1373885274-25249-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Jul 15, 2013 at 01:47:47PM +0300, Kirill A. Shutemov wrote:
>From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
>There's only one caller of do_generic_file_read() and the only actor is
>file_read_actor(). No reason to have a callback parameter.
>
>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/filemap.c | 10 +++++-----
> 1 file changed, 5 insertions(+), 5 deletions(-)
>
>diff --git a/mm/filemap.c b/mm/filemap.c
>index 4b51ac1..f6fe61f 100644
>--- a/mm/filemap.c
>+++ b/mm/filemap.c
>@@ -1088,7 +1088,6 @@ static void shrink_readahead_size_eio(struct file *filp,
>  * @filp:	the file to read
>  * @ppos:	current file position
>  * @desc:	read_descriptor
>- * @actor:	read method
>  *
>  * This is a generic file read routine, and uses the
>  * mapping->a_ops->readpage() function for the actual low-level stuff.
>@@ -1097,7 +1096,7 @@ static void shrink_readahead_size_eio(struct file *filp,
>  * of the logic when it comes to error handling etc.
>  */
> static void do_generic_file_read(struct file *filp, loff_t *ppos,
>-		read_descriptor_t *desc, read_actor_t actor)
>+		read_descriptor_t *desc)
> {
> 	struct address_space *mapping = filp->f_mapping;
> 	struct inode *inode = mapping->host;
>@@ -1198,13 +1197,14 @@ page_ok:
> 		 * Ok, we have the page, and it's up-to-date, so
> 		 * now we can copy it to user space...
> 		 *
>-		 * The actor routine returns how many bytes were actually used..
>+		 * The file_read_actor routine returns how many bytes were
>+		 * actually used..
> 		 * NOTE! This may not be the same as how much of a user buffer
> 		 * we filled up (we may be padding etc), so we can only update
> 		 * "pos" here (the actor routine has to update the user buffer
> 		 * pointers and the remaining count).
> 		 */
>-		ret = actor(desc, page, offset, nr);
>+		ret = file_read_actor(desc, page, offset, nr);
> 		offset += ret;
> 		index += offset >> PAGE_CACHE_SHIFT;
> 		offset &= ~PAGE_CACHE_MASK;
>@@ -1477,7 +1477,7 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
> 		if (desc.count == 0)
> 			continue;
> 		desc.error = 0;
>-		do_generic_file_read(filp, ppos, &desc, file_read_actor);
>+		do_generic_file_read(filp, ppos, &desc);
> 		retval += desc.written;
> 		if (desc.error) {
> 			retval = retval ?: desc.error;
>-- 
>1.8.3.2
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
