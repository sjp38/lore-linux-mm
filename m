Date: Mon, 19 Mar 2007 19:12:58 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Message-ID: <20070319081258.GE32597093@melbourne.sgi.com>
References: <20070318233008.GA32597093@melbourne.sgi.com> <45FE2F8F.6010603@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45FE2F8F.6010603@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 19, 2007 at 05:37:03PM +1100, Nick Piggin wrote:
> David Chinner wrote:
> > 
> >+/*
> >+ * block_page_mkwrite() is not allowed to change the file size as it gets
> >+ * called from a page fault handler when a page is first dirtied. Hence 
> >we must
> >+ * be careful to check for EOF conditions here. We set the page up 
> >correctly
> >+ * for a written page which means we get ENOSPC checking when writing into
> >+ * holes and correct delalloc and unwritten extent mapping on filesystems 
> >that
> >+ * support these features.
> >+ *
> >+ * We are not allowed to take the i_mutex here so we have to play games to
> >+ * protect against truncate races as the page could now be beyond EOF.  
> >Because
> >+ * vmtruncate() writes the inode size before removing pages, once we have 
> >the
> >+ * page lock we can determine safely if the page is beyond EOF. If it is 
> >not
> >+ * beyond EOF, then the page is guaranteed safe against truncation until 
> >we
> >+ * unlock the page.
> >+ */
> >+int
> >+block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
> >+		   get_block_t get_block)
> >+{
> >+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
> >+	unsigned long end;
> >+	loff_t size;
> >+	int ret = -EINVAL;
> >+
> >+	lock_page(page);
> >+	size = i_size_read(inode);
> >+	if ((page->mapping != inode->i_mapping) ||
> >+	    ((page->index << PAGE_CACHE_SHIFT) > size)) {
> >+		/* page got truncated out from underneath us */
> >+		goto out_unlock;
> >+	}
> 
> I see your explanation above, but I still don't see why this can't
> just follow the conventional if (!page->mapping) check for truncation.
> If the test happens to be performed after truncate concurrently
> decreases i_size, then the blocks are going to get truncated by the
> truncate afterwards anyway.

We have to read the inode size in the normal case so that we know if
the page is at EOF and is a partial page so we don't allocate past EOF in
block_prepare_write().  Hence it seems like a no-brainer to me to check
and error out on a page that we *know* is beyond EOF.

I can drop the check if you see no value in it - I just don't
like the idea of ignoring obvious boundary condition violations...

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
