From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH]  incorrect error handling inside generic_file_direct_write
Date: Fri, 15 Dec 2006 10:53:18 -0800
Message-ID: <000101c7207a$48c138f0$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20061215104341.GA20089@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Christoph Hellwig' <hch@infradead.org>
Cc: 'Andrew Morton' <akpm@osdl.org>, Dmitriy Monakhov <dmonakhov@sw.ru>, Dmitriy Monakhov <dmonakhov@openvz.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote on Friday, December 15, 2006 2:44 AM
> So we're doing the sync_page_range once in __generic_file_aio_write
> with i_mutex held.
> 
> 
> >  	mutex_lock(&inode->i_mutex);
> > -	ret = __generic_file_aio_write_nolock(iocb, iov, nr_segs,
> > -			&iocb->ki_pos);
> > +	ret = __generic_file_aio_write(iocb, iov, nr_segs, pos);
> >  	mutex_unlock(&inode->i_mutex);
> >  
> >  	if (ret > 0 && ((file->f_flags & O_SYNC) || IS_SYNC(inode))) {
> 
> And then another time after it's unlocked, this seems wrong.


I didn't invent that mess though.

I should've ask the question first: in 2.6.20-rc1, generic_file_aio_write
will call sync_page_range twice, once from __generic_file_aio_write_nolock
and once within the function itself.  Is it redundant?  Can we delete the
one in the top level function?  Like the following?


--- ./mm/filemap.c.orig	2006-12-15 09:02:58.000000000 -0800
+++ ./mm/filemap.c	2006-12-15 09:03:19.000000000 -0800
@@ -2370,14 +2370,6 @@ ssize_t generic_file_aio_write(struct ki
 	ret = __generic_file_aio_write_nolock(iocb, iov, nr_segs,
 			&iocb->ki_pos);
 	mutex_unlock(&inode->i_mutex);
-
-	if (ret > 0 && ((file->f_flags & O_SYNC) || IS_SYNC(inode))) {
-		ssize_t err;
-
-		err = sync_page_range(inode, mapping, pos, ret);
-		if (err < 0)
-			ret = err;
-	}
 	return ret;
 }
 EXPORT_SYMBOL(generic_file_aio_write);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
