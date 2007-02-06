Subject: Re: [RFC/PATCH] prepare_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1170777380.26117.28.camel@localhost.localdomain>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	 <1170736938.2620.213.camel@localhost.localdomain>
	 <20070206044516.GA16647@wotan.suse.de>
	 <1170738296.2620.220.camel@localhost.localdomain>
	 <1170777380.26117.28.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 07 Feb 2007 07:12:34 +1100
Message-Id: <1170792754.2620.244.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>, hch@infradead.org, "David C. Hansen [imap]" <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-02-06 at 09:56 -0600, Adam Litke wrote:
> On Tue, 2007-02-06 at 16:04 +1100, Benjamin Herrenschmidt wrote:
> > Hi folks !
> > 
> > On Cell, I have, for performance reasons, a need to create special
> > mappings of SPEs that use a different page size as the system base page
> > size _and_ as the huge page size.
> > 
> > Due to the way the PowerPC memory management works, however, I can only
> > have one page size per "segment" of 256MB (or 1T) and thus after such a
> > mapping have been created in its own segment, I need to constraint
> > -other- vma's to stay out of that area.
> > 
> > This currently cannot be done with the existing arch hooks (because of
> > MAP_FIXED). However, the hugetlbfs code already has a hack in there to
> > do the exact same thing for huge pages. Thus, this patch moves that hack
> > into something that can be overriden by the architectures. This approach
> > was choosen as the less ugly of the uglies after discussing with Nick
> > Piggin. If somebody has a better idea, I'd love to hear it.
> 
> Hi Ben.  Would my patch from last Jan 31 entitled "[PATCH 5/6] Abstract
> is_hugepage_only_range" (attached for your convienence) solve this
> problem?

I don't see how your patch abstracts is_hugepage_only_range tho... you
still call it at the same spot, you abstracted prepare_hugepage_range.

I was talking to hch and arjan yesterday on irc and we though about
having an mm hook validate_area() that could replace the
is_hugepage_only_range() hack and deal with my issue as well. As for
having prepare in the fops, do we need it at all if we call fops->g_u_a
in the MAP_FIXED case ?

Ben.

> commit ef36c6c859d37ac40f0bd12d08f41f103ab76657
> Author: litke@us.ibm.com <aglitke@kernel.localdomain>
> Date:   Tue Jan 16 08:57:16 2007 -0800
> 
>     Abstract is_hugepage_only_range
>     
>     Some architectures define regions of the address space that can be used
>     exclusively for either normal pages or hugetlb pages.  Currently,
>     prepare_hugepage_range() is used to validate an unmapped_area for use with
>     hugepages and is_hugepage_only_range() is used to validate an unmapped_area for
>     normal pages.
>     
>     Introduce a prepare_unmapped_area() file operation to abstract the validation
>     of unmapped areas.  If prepare_unmapped_area() is not specified, the default
>     behavior is to require the area to not overlap any "special" areas.
>     
>     Buh-bye to another is_file_hugepages() call.
>     
>     Signed-off-by: Adam Litke <agl@us.ibm.com>
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index b61592f..3eea7a5 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -561,6 +561,7 @@ const struct file_operations hugetlbfs_file_operations = {
>  	.mmap			= hugetlbfs_file_mmap,
>  	.fsync			= simple_sync_file,
>  	.get_unmapped_area	= hugetlb_get_unmapped_area,
> +	.prepare_unmapped_area	= prepare_hugepage_range,
>  };
>  
>  static struct inode_operations hugetlbfs_dir_inode_operations = {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 1410e53..853a4f4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1094,6 +1094,7 @@ struct file_operations {
>  	ssize_t (*sendfile) (struct file *, loff_t *, size_t, read_actor_t, void *);
>  	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
>  	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
> +	int (*prepare_unmapped_area)(unsigned long addr, unsigned long len, pgoff_t pgoff);
>  	int (*check_flags)(int);
>  	int (*dir_notify)(struct file *filp, unsigned long arg);
>  	int (*flock) (struct file *, int, struct file_lock *);
> diff --git a/mm/mmap.c b/mm/mmap.c
> index a5cb0a5..f8e0bd0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1374,20 +1374,17 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
>  		return -ENOMEM;
>  	if (addr & ~PAGE_MASK)
>  		return -EINVAL;
> -	if (file && is_file_hugepages(file))  {
> -		/*
> -		 * Check if the given range is hugepage aligned, and
> -		 * can be made suitable for hugepages.
> -		 */
> -		ret = prepare_hugepage_range(addr, len, pgoff);
> -	} else {
> -		/*
> -		 * Ensure that a normal request is not falling in a
> -		 * reserved hugepage range.  For some archs like IA-64,
> -		 * there is a separate region for hugepages.
> -		 */
> +	/*
> +	 * This file may only be able to be mapped into special areas of the
> +	 * addess space (eg. hugetlb pages).  If prepare_unmapped_area() is
> +	 * specified, use it to validate the selected range.  If not, just
> +	 * make sure the range does not overlap any special ranges.
> +	 */
> +	if (file && file->f_op && file->f_op->prepare_unmapped_area)
> +		ret = file->f_op->prepare_unmapped_area(addr, len, pgoff);
> +	else
>  		ret = is_hugepage_only_range(current->mm, addr, len);
> -	}
> +
>  	if (ret)
>  		return -EINVAL;
>  	return addr;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
