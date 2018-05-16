Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5600D6B030F
	for <linux-mm@kvack.org>; Wed, 16 May 2018 05:53:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z7-v6so100448wrg.11
        for <linux-mm@kvack.org>; Wed, 16 May 2018 02:53:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f55-v6sor1727136ede.56.2018.05.16.02.53.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 02:53:06 -0700 (PDT)
Date: Wed, 16 May 2018 11:53:03 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 10/14] vgem: separate errno from VM_FAULT_* values
Message-ID: <20180516095303.GH3438@phenom.ffwll.local>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516054348.15950-11-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 07:43:44AM +0200, Christoph Hellwig wrote:
> And streamline the code in vgem_fault with early returns so that it is
> a little bit more readable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/vgem/vgem_drv.c | 51 +++++++++++++++------------------
>  1 file changed, 23 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/gpu/drm/vgem/vgem_drv.c b/drivers/gpu/drm/vgem/vgem_drv.c
> index 2524ff116f00..a261e0aab83a 100644
> --- a/drivers/gpu/drm/vgem/vgem_drv.c
> +++ b/drivers/gpu/drm/vgem/vgem_drv.c
> @@ -61,12 +61,13 @@ static void vgem_gem_free_object(struct drm_gem_object *obj)
>  	kfree(vgem_obj);
>  }
>  
> -static int vgem_gem_fault(struct vm_fault *vmf)
> +static vm_fault_t vgem_gem_fault(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
>  	struct drm_vgem_gem_object *obj = vma->vm_private_data;
>  	/* We don't use vmf->pgoff since that has the fake offset */
>  	unsigned long vaddr = vmf->address;
> +	struct page *page;
>  	int ret;
>  	loff_t num_pages;
>  	pgoff_t page_offset;
> @@ -85,35 +86,29 @@ static int vgem_gem_fault(struct vm_fault *vmf)
>  		ret = 0;
>  	}
>  	mutex_unlock(&obj->pages_lock);
> -	if (ret) {
> -		struct page *page;
> -
> -		page = shmem_read_mapping_page(
> -					file_inode(obj->base.filp)->i_mapping,
> -					page_offset);
> -		if (!IS_ERR(page)) {
> -			vmf->page = page;
> -			ret = 0;
> -		} else switch (PTR_ERR(page)) {
> -			case -ENOSPC:
> -			case -ENOMEM:
> -				ret = VM_FAULT_OOM;
> -				break;
> -			case -EBUSY:
> -				ret = VM_FAULT_RETRY;
> -				break;
> -			case -EFAULT:
> -			case -EINVAL:
> -				ret = VM_FAULT_SIGBUS;
> -				break;
> -			default:
> -				WARN_ON(PTR_ERR(page));
> -				ret = VM_FAULT_SIGBUS;
> -				break;
> -		}
> +	if (!ret)
> +		return 0;
> +
> +	page = shmem_read_mapping_page(file_inode(obj->base.filp)->i_mapping,
> +			page_offset);
> +	if (!IS_ERR(page)) {
> +		vmf->page = page;
> +		return 0;
> +	}
>  
> +	switch (PTR_ERR(page)) {
> +	case -ENOSPC:
> +	case -ENOMEM:
> +		return VM_FAULT_OOM;
> +	case -EBUSY:
> +		return VM_FAULT_RETRY;
> +	case -EFAULT:
> +	case -EINVAL:
> +		return VM_FAULT_SIGBUS;
> +	default:
> +		WARN_ON(PTR_ERR(page));
> +		return VM_FAULT_SIGBUS;
>  	}
> -	return ret;

Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

Want me to merge this through drm-misc or plan to pick it up yourself?
-Daniel

>  }
>  
>  static const struct vm_operations_struct vgem_gem_vm_ops = {
> -- 
> 2.17.0
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
