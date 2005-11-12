Date: Fri, 11 Nov 2005 16:25:11 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 2.6.14 patch for supporting madvise(MADV_REMOVE)
Message-Id: <20051111162511.57ee1af3.akpm@osdl.org>
In-Reply-To: <1130947957.24503.70.camel@localhost.localdomain>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<20051028034616.GA14511@ccure.user-mode-linux.org>
	<43624F82.6080003@us.ibm.com>
	<20051028184235.GC8514@ccure.user-mode-linux.org>
	<1130544201.23729.167.camel@localhost.localdomain>
	<20051029025119.GA14998@ccure.user-mode-linux.org>
	<1130788176.24503.19.camel@localhost.localdomain>
	<20051101000509.GA11847@ccure.user-mode-linux.org>
	<1130894101.24503.64.camel@localhost.localdomain>
	<20051102014321.GG24051@opteron.random>
	<1130947957.24503.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: andrea@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, blaisorblade@yahoo.it, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> +/*
>  + * Application wants to free up the pages and associated backing store. 
>  + * This is effectively punching a hole into the middle of a file.
>  + *
>  + * NOTE: Currently, only shmfs/tmpfs is supported for this operation.
>  + * Other filesystems return -ENOSYS.
>  + */
>  +static long madvise_remove(struct vm_area_struct * vma,
>  +			     unsigned long start, unsigned long end)
>  +{
>  +	struct address_space *mapping;
>  +        loff_t offset, endoff;
>  +
>  +	if (vma->vm_flags & (VM_LOCKED|VM_NONLINEAR|VM_HUGETLB)) 
>  +		return -EINVAL;
>  +
>  +	if (!vma->vm_file || !vma->vm_file->f_mapping 
>  +		|| !vma->vm_file->f_mapping->host) {
>  +			return -EINVAL;
>  +	}
>  +
>  +	mapping = vma->vm_file->f_mapping;
>  +	if (mapping == &swapper_space) {
>  +		return -EINVAL;
>  +	}
>  +
>  +	offset = (loff_t)(start - vma->vm_start) 
>  +			+ (vma->vm_pgoff << PAGE_SHIFT);
>  +	endoff = (loff_t)(end - vma->vm_start - 1) 
>  +			+ (vma->vm_pgoff << PAGE_SHIFT);
>  +	return  vmtruncate_range(mapping->host, offset, endoff);
>  +}
>  +

I'm suspecting you tested this on a 64-bit machine, yes?  On 32-bit that
vm_pgoff shift is going to overflow.  

Fixes-thus-far below.   Please rerun all tests on x86?

Why does madvise_remove() have an explicit check for swapper_space?

In your testing, how are you determining that the code is successfully
removing the correct number of pages, from the correct file offset?


diff -puN mm/madvise.c~madvise-remove-remove-pages-from-tmpfs-shm-backing-store-tidy mm/madvise.c
--- devel/mm/madvise.c~madvise-remove-remove-pages-from-tmpfs-shm-backing-store-tidy	2005-11-11 16:12:43.000000000 -0800
+++ devel-akpm/mm/madvise.c	2005-11-11 16:16:50.000000000 -0800
@@ -147,8 +147,8 @@ static long madvise_dontneed(struct vm_a
  * NOTE: Currently, only shmfs/tmpfs is supported for this operation.
  * Other filesystems return -ENOSYS.
  */
-static long madvise_remove(struct vm_area_struct * vma,
-			     unsigned long start, unsigned long end)
+static long madvise_remove(struct vm_area_struct *vma,
+				unsigned long start, unsigned long end)
 {
 	struct address_space *mapping;
         loff_t offset, endoff;
@@ -162,14 +162,13 @@ static long madvise_remove(struct vm_are
 	}
 
 	mapping = vma->vm_file->f_mapping;
-	if (mapping == &swapper_space) {
+	if (mapping == &swapper_space)
 		return -EINVAL;
-	}
 
 	offset = (loff_t)(start - vma->vm_start)
-			+ (vma->vm_pgoff << PAGE_SHIFT);
+			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 	endoff = (loff_t)(end - vma->vm_start - 1)
-			+ (vma->vm_pgoff << PAGE_SHIFT);
+			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 	return  vmtruncate_range(mapping->host, offset, endoff);
 }
 
diff -puN mm/memory.c~madvise-remove-remove-pages-from-tmpfs-shm-backing-store-tidy mm/memory.c
--- devel/mm/memory.c~madvise-remove-remove-pages-from-tmpfs-shm-backing-store-tidy	2005-11-11 16:16:54.000000000 -0800
+++ devel-akpm/mm/memory.c	2005-11-11 16:17:59.000000000 -0800
@@ -1608,10 +1608,9 @@ out_big:
 out_busy:
 	return -ETXTBSY;
 }
-
 EXPORT_SYMBOL(vmtruncate);
 
-int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end)
+int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
 {
 	struct address_space *mapping = inode->i_mapping;
 
@@ -1634,7 +1633,6 @@ int vmtruncate_range(struct inode * inod
 
 	return 0;
 }
-
 EXPORT_SYMBOL(vmtruncate_range);
 
 /* 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
