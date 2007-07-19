Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l6JEiDl8022780
	for <linux-mm@kvack.org>; Thu, 19 Jul 2007 10:44:13 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6JFnwGt155782
	for <linux-mm@kvack.org>; Thu, 19 Jul 2007 09:49:58 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6JFnwe9006040
	for <linux-mm@kvack.org>; Thu, 19 Jul 2007 09:49:58 -0600
Subject: Re: [PATCH] hugetlbfs read() support
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20070718221950.35bbdb76.akpm@linux-foundation.org>
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com>
	 <20070718221950.35bbdb76.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 19 Jul 2007 08:51:49 -0700
Message-Id: <1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bill Irwin <bill.irwin@oracle.com>, nacc@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-18 at 22:19 -0700, Andrew Morton wrote:
> On Fri, 13 Jul 2007 18:23:33 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > Hi Andrew,
> > 
> > Here is the patch to support read() for hugetlbfs, needed to get
> > oprofile working on executables backed by largepages. 
> > 
> > If you plan to consider Christoph Lameter's pagecache cleanup patches,
> > I will re-write this. Otherwise, please consider this for -mm.
> > 
> > Thanks,
> > Badari
> > 
> > Support for reading from hugetlbfs files. libhugetlbfs lets application
> > text/data to be placed in large pages. When we do that, oprofile doesn't
> > work - since libbfd tries to read from it.
> > 
> > This code is very similar to what do_generic_mapping_read() does, but
> > I can't use it since it has PAGE_CACHE_SIZE assumptions.
> > 
> > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> > Acked-by: William Irwin <bill.irwin@oracle.com>
> > Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > 
> >  fs/hugetlbfs/inode.c |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 113 insertions(+)
> > 
> > Index: linux-2.6.22/fs/hugetlbfs/inode.c
> > ===================================================================
> > --- linux-2.6.22.orig/fs/hugetlbfs/inode.c	2007-07-08 16:32:17.000000000 -0700
> > +++ linux-2.6.22/fs/hugetlbfs/inode.c	2007-07-13 19:24:36.000000000 -0700
> > @@ -156,6 +156,118 @@ full_search:
> >  }
> >  #endif
> >  
> > +static int
> > +hugetlbfs_read_actor(struct page *page, unsigned long offset,
> > +			char __user *buf, unsigned long count,
> > +			unsigned long size)
> > +{
> > +	char *kaddr;
> > +	unsigned long left, copied = 0;
> > +	int i, chunksize;
> > +
> > +	if (size > count)
> > +		size = count;
> > +
> > +	/* Find which 4k chunk and offset with in that chunk */
> > +	i = offset >> PAGE_CACHE_SHIFT;
> > +	offset = offset & ~PAGE_CACHE_MASK;
> > +
> > +	while (size) {
> > +		chunksize = PAGE_CACHE_SIZE;
> > +		if (offset)
> > +			chunksize -= offset;
> > +		if (chunksize > size)
> > +			chunksize = size;
> > +		kaddr = kmap(&page[i]);
> > +		left = __copy_to_user(buf, kaddr + offset, chunksize);
> > +		kunmap(&page[i]);
> > +		if (left) {
> > +			copied += (chunksize - left);
> > +			break;
> > +		}
> > +		offset = 0;
> > +		size -= chunksize;
> > +		buf += chunksize;
> > +		copied += chunksize;
> > +		i++;
> > +	}
> > +	return copied ? copied : -EFAULT;
> > +}
> 
> This returns -EFAULT when asked to read zero bytes.  The caller prevents
> that, but it's a little bit ugly.  Livable with.

I can fix that, but I didn't want to come here if length == 0 - so
took a shortcut.

> 
> > +/*
> > + * Support for read() - Find the page attached to f_mapping and copy out the
> > + * data. Its *very* similar to do_generic_mapping_read(), we can't use that
> > + * since it has PAGE_CACHE_SIZE assumptions.
> > + */
> > +ssize_t
> > +hugetlbfs_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
> > +{
> > +	struct address_space *mapping = filp->f_mapping;
> > +	struct inode *inode = mapping->host;
> > +	unsigned long index = *ppos >> HPAGE_SHIFT;
> > +	unsigned long end_index;
> > +	loff_t isize;
> > +	unsigned long offset;
> > +	ssize_t retval = 0;
> > +
> > +	/* validate length */
> > +	if (len == 0)
> > +		goto out;
> > +
> > +	isize = i_size_read(inode);
> > +	if (!isize)
> > +		goto out;
> > +
> > +	offset = *ppos & ~HPAGE_MASK;
> > +	end_index = (isize - 1) >> HPAGE_SHIFT;
> > +	for (;;) {
> > +		struct page *page;
> > +		int nr, ret;
> > +
> > +		/* nr is the maximum number of bytes to copy from this page */
> > +		nr = HPAGE_SIZE;
> > +		if (index >= end_index) {
> > +			if (index > end_index)
> > +				goto out;
> > +			nr = ((isize - 1) & ~HPAGE_MASK) + 1;
> > +			if (nr <= offset) {
> > +				goto out;
> > +			}
> > +		}
> > +		nr = nr - offset;
> > +
> > +		/* Find the page */
> > +		page = find_get_page(mapping, index);
> > +		if (unlikely(page == NULL)) {
> > +			/*
> > +			 * We can't find the page in the cache - bail out ?
> > +			 */
> > +			goto out;
> > +		}
> > +		/*
> > +		 * Ok, we have the page, copy it to user space buffer.
> > +		 */
> > +		ret = hugetlbfs_read_actor(page, offset, buf, len, nr);
> > +		if (ret < 0) {
> > +			retval = retval ? : ret;
> > +			goto out;
> 
> Missing put_page().

Yes. Thanks for catching it.

> 
> > +		}
> > +
> > +		offset += ret;
> > +		retval += ret;
> > +		len -= ret;
> > +		index += offset >> HPAGE_SHIFT;
> > +		offset &= ~HPAGE_MASK;
> > +
> > +		page_cache_release(page);
> > +		if (ret == nr && len)
> > +			continue;
> > +		goto out;
> > +	}
> > +out:
> > +	return retval;
> > +}
> 
> This code doesn't have all the ghastly tricks which we deploy to handle
> concurrent truncate.

Do I need to ? Baaahh!!  I don't want to deal with them. 
All I want is a simple read() to get my oprofile working.
Please advise.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
