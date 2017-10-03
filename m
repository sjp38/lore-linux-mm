Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA8D6B025F
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 04:13:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e26so4422913pfd.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:13:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f34si9840855ple.484.2017.10.03.01.13.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 01:13:03 -0700 (PDT)
Date: Tue, 3 Oct 2017 10:12:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 4/4] dax: stop using VM_HUGEPAGE for dax
Message-ID: <20171003081259.GE11879@quack2.suse.cz>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150664808322.36094.377701515526275078.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150664808322.36094.377701515526275078.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Thu 28-09-17 18:21:23, Dan Williams wrote:
> This flag is deprecated in favor of the vma_is_dax() check in
> transparent_hugepage_enabled() added in commit baabda261424 "mm: always
> enable thp for dax mappings"
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I like this! You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/dax/device.c |    1 -
>  fs/ext4/file.c       |    1 -
>  fs/xfs/xfs_file.c    |    2 --
>  3 files changed, 4 deletions(-)
> 
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index ed79d006026e..74a35eb5e6d3 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -450,7 +450,6 @@ static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
>  		return rc;
>  
>  	vma->vm_ops = &dax_vm_ops;
> -	vma->vm_flags |= VM_HUGEPAGE;
>  	return 0;
>  }
>  
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 0cc9d205bd96..a54e1b4c49f9 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -352,7 +352,6 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	file_accessed(file);
>  	if (IS_DAX(file_inode(file))) {
>  		vma->vm_ops = &ext4_dax_vm_ops;
> -		vma->vm_flags |= VM_HUGEPAGE;
>  	} else {
>  		vma->vm_ops = &ext4_file_vm_ops;
>  	}
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index dece8fe937f5..c0e0fcbe1bd3 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -1130,8 +1130,6 @@ xfs_file_mmap(
>  {
>  	file_accessed(filp);
>  	vma->vm_ops = &xfs_file_vm_ops;
> -	if (IS_DAX(file_inode(filp)))
> -		vma->vm_flags |= VM_HUGEPAGE;
>  	return 0;
>  }
>  
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
