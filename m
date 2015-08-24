From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mmap: Check all failures before set values
Date: Mon, 24 Aug 2015 13:32:13 +0200
Message-ID: <20150824113212.GL17078@dhcp22.suse.cz>
References: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com>
Sender: linux-kernel-owner@vger.kernel.org
To: gang.chen.5i5j@qq.com
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, sasha.levin@oracle.com, gang.chen.5i5j@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Mon 24-08-15 00:59:39, gang.chen.5i5j@qq.com wrote:
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> When failure occurs and return, vma->vm_pgoff is already set, which is
> not a good idea.

Why? The vma is not inserted anywhere and the failure path is supposed
to simply free the vma.

> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/mmap.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8e0366e..b5a6f09 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2878,6 +2878,13 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
>  	struct vm_area_struct *prev;
>  	struct rb_node **rb_link, *rb_parent;
>  
> +	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
> +			   &prev, &rb_link, &rb_parent))
> +		return -ENOMEM;
> +	if ((vma->vm_flags & VM_ACCOUNT) &&
> +	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
> +		return -ENOMEM;
> +
>  	/*
>  	 * The vm_pgoff of a purely anonymous vma should be irrelevant
>  	 * until its first write fault, when page's anon_vma and index
> @@ -2894,12 +2901,6 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
>  		BUG_ON(vma->anon_vma);
>  		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
>  	}
> -	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
> -			   &prev, &rb_link, &rb_parent))
> -		return -ENOMEM;
> -	if ((vma->vm_flags & VM_ACCOUNT) &&
> -	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
> -		return -ENOMEM;
>  
>  	vma_link(mm, vma, prev, rb_link, rb_parent);
>  	return 0;
> -- 
> 1.9.3

-- 
Michal Hocko
SUSE Labs
