Date: Wed, 18 Jul 2007 22:19:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs read() support
Message-Id: <20070718221950.35bbdb76.akpm@linux-foundation.org>
In-Reply-To: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com>
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Bill Irwin <bill.irwin@oracle.com>, nacc@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007 18:23:33 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:

> Hi Andrew,
> 
> Here is the patch to support read() for hugetlbfs, needed to get
> oprofile working on executables backed by largepages. 
> 
> If you plan to consider Christoph Lameter's pagecache cleanup patches,
> I will re-write this. Otherwise, please consider this for -mm.
> 
> Thanks,
> Badari
> 
> Support for reading from hugetlbfs files. libhugetlbfs lets application
> text/data to be placed in large pages. When we do that, oprofile doesn't
> work - since libbfd tries to read from it.
> 
> This code is very similar to what do_generic_mapping_read() does, but
> I can't use it since it has PAGE_CACHE_SIZE assumptions.
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> Acked-by: William Irwin <bill.irwin@oracle.com>
> Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
>  fs/hugetlbfs/inode.c |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 113 insertions(+)
> 
> Index: linux-2.6.22/fs/hugetlbfs/inode.c
> ===================================================================
> --- linux-2.6.22.orig/fs/hugetlbfs/inode.c	2007-07-08 16:32:17.000000000 -0700
> +++ linux-2.6.22/fs/hugetlbfs/inode.c	2007-07-13 19:24:36.000000000 -0700
> @@ -156,6 +156,118 @@ full_search:
>  }
>  #endif
>  
> +static int
> +hugetlbfs_read_actor(struct page *page, unsigned long offset,
> +			char __user *buf, unsigned long count,
> +			unsigned long size)
> +{
> +	char *kaddr;
> +	unsigned long left, copied = 0;
> +	int i, chunksize;
> +
> +	if (size > count)
> +		size = count;
> +
> +	/* Find which 4k chunk and offset with in that chunk */
> +	i = offset >> PAGE_CACHE_SHIFT;
> +	offset = offset & ~PAGE_CACHE_MASK;
> +
> +	while (size) {
> +		chunksize = PAGE_CACHE_SIZE;
> +		if (offset)
> +			chunksize -= offset;
> +		if (chunksize > size)
> +			chunksize = size;
> +		kaddr = kmap(&page[i]);
> +		left = __copy_to_user(buf, kaddr + offset, chunksize);
> +		kunmap(&page[i]);
> +		if (left) {
> +			copied += (chunksize - left);
> +			break;
> +		}
> +		offset = 0;
> +		size -= chunksize;
> +		buf += chunksize;
> +		copied += chunksize;
> +		i++;
> +	}
> +	return copied ? copied : -EFAULT;
> +}

This returns -EFAULT when asked to read zero bytes.  The caller prevents
that, but it's a little bit ugly.  Livable with.

> +/*
> + * Support for read() - Find the page attached to f_mapping and copy out the
> + * data. Its *very* similar to do_generic_mapping_read(), we can't use that
> + * since it has PAGE_CACHE_SIZE assumptions.
> + */
> +ssize_t
> +hugetlbfs_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
> +{
> +	struct address_space *mapping = filp->f_mapping;
> +	struct inode *inode = mapping->host;
> +	unsigned long index = *ppos >> HPAGE_SHIFT;
> +	unsigned long end_index;
> +	loff_t isize;
> +	unsigned long offset;
> +	ssize_t retval = 0;
> +
> +	/* validate length */
> +	if (len == 0)
> +		goto out;
> +
> +	isize = i_size_read(inode);
> +	if (!isize)
> +		goto out;
> +
> +	offset = *ppos & ~HPAGE_MASK;
> +	end_index = (isize - 1) >> HPAGE_SHIFT;
> +	for (;;) {
> +		struct page *page;
> +		int nr, ret;
> +
> +		/* nr is the maximum number of bytes to copy from this page */
> +		nr = HPAGE_SIZE;
> +		if (index >= end_index) {
> +			if (index > end_index)
> +				goto out;
> +			nr = ((isize - 1) & ~HPAGE_MASK) + 1;
> +			if (nr <= offset) {
> +				goto out;
> +			}
> +		}
> +		nr = nr - offset;
> +
> +		/* Find the page */
> +		page = find_get_page(mapping, index);
> +		if (unlikely(page == NULL)) {
> +			/*
> +			 * We can't find the page in the cache - bail out ?
> +			 */
> +			goto out;
> +		}
> +		/*
> +		 * Ok, we have the page, copy it to user space buffer.
> +		 */
> +		ret = hugetlbfs_read_actor(page, offset, buf, len, nr);
> +		if (ret < 0) {
> +			retval = retval ? : ret;
> +			goto out;

Missing put_page().

> +		}
> +
> +		offset += ret;
> +		retval += ret;
> +		len -= ret;
> +		index += offset >> HPAGE_SHIFT;
> +		offset &= ~HPAGE_MASK;
> +
> +		page_cache_release(page);
> +		if (ret == nr && len)
> +			continue;
> +		goto out;
> +	}
> +out:
> +	return retval;
> +}

This code doesn't have all the ghastly tricks which we deploy to handle
concurrent truncate.

>  /*
>   * Read a page. Again trivial. If it didn't already exist
>   * in the page cache, it is zero-filled.
> @@ -560,6 +672,7 @@ static void init_once(void *foo, struct 
>  }
>  
>  const struct file_operations hugetlbfs_file_operations = {
> +	.read			= hugetlbfs_read,
>  	.mmap			= hugetlbfs_file_mmap,
>  	.fsync			= simple_sync_file,
>  	.get_unmapped_area	= hugetlb_get_unmapped_area,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
