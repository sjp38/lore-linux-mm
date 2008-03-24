Date: Mon, 24 Mar 2008 16:01:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ext3: Use page_mkwrite vma_operations to get mmap write
 notification.
Message-Id: <20080324160141.67746905.akpm@linux-foundation.org>
In-Reply-To: <1206378298-10341-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1206378298-10341-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1206378298-10341-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: cmm@us.ibm.com, linux-ext4@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Mar 2008 22:34:56 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> We would like to get notified when we are doing a write on mmap section.
> The changes are needed to handle ENOSPC when writing to an mmap section
> of files with holes.
> 

umm,

> 
> diff --git a/fs/ext3/file.c b/fs/ext3/file.c
> index acc4913..09e22e4 100644
> --- a/fs/ext3/file.c
> +++ b/fs/ext3/file.c
> @@ -106,6 +106,23 @@ force_commit:
>  	return ret;
>  }
>  
> +static struct vm_operations_struct ext3_file_vm_ops = {
> +	.fault		= filemap_fault,
> +	.page_mkwrite   = ext3_page_mkwrite,
> +};
> +
> +static int ext3_file_mmap(struct file *file, struct vm_area_struct *vma)
> +{
> +	struct address_space *mapping = file->f_mapping;
> +
> +	if (!mapping->a_ops->readpage)
> +		return -ENOEXEC;
> +	file_accessed(file);
> +	vma->vm_ops = &ext3_file_vm_ops;
> +	vma->vm_flags |= VM_CAN_NONLINEAR;
> +	return 0;
> +}
> +
>  const struct file_operations ext3_file_operations = {
>  	.llseek		= generic_file_llseek,
>  	.read		= do_sync_read,
> @@ -116,7 +133,7 @@ const struct file_operations ext3_file_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl	= ext3_compat_ioctl,
>  #endif
> -	.mmap		= generic_file_mmap,
> +	.mmap		= ext3_file_mmap,
>  	.open		= generic_file_open,
>  	.release	= ext3_release_file,
>  	.fsync		= ext3_sync_file,
> diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
> index eb95670..2293506 100644
> --- a/fs/ext3/inode.c
> +++ b/fs/ext3/inode.c
> @@ -3306,3 +3306,8 @@ int ext3_change_inode_journal_flag(struct inode *inode, int val)
>  
>  	return err;
>  }
> +
> +int ext3_page_mkwrite(struct vm_area_struct *vma, struct page *page)
> +{
> +	return block_page_mkwrite(vma, page, ext3_get_block);
> +}

This gets called within the pagefault handler.

And block_page_mkwrite() does lock_page().

But the pagefault handler can be called with a page already locked, from
generic_perform_write().

Nick, why are we not vulnerable to A-A or to AB-BA deadlocks here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
