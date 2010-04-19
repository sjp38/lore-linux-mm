Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 59B0B6B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 22:18:25 -0400 (EDT)
Message-ID: <4BCBBD3D.5020102@oracle.com>
Date: Sun, 18 Apr 2010 19:17:33 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: mmotm 2010-04-15-14-42 uploaded (shmem, CGROUP_MEM_RES_CTLR)
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>	<20100416090315.22b7d361.randy.dunlap@oracle.com> <20100419104917.1a568b17.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100419104917.1a568b17.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 04/18/10 18:49, Daisuke Nishimura wrote:
> On Fri, 16 Apr 2010 09:03:15 -0700, Randy Dunlap <randy.dunlap@oracle.com> wrote:
>> On Thu, 15 Apr 2010 14:42:59 -0700 akpm@linux-foundation.org wrote:
>>
>>> The mm-of-the-moment snapshot 2010-04-15-14-42 has been uploaded to
>>>
>>>    http://userweb.kernel.org/~akpm/mmotm/
>>>
>>> and will soon be available at
>>>
>>>    git://zen-kernel.org/kernel/mmotm.git
>>>
>>> It contains the following patches against 2.6.34-rc4:
>>
>>
>> memcg-move-charge-of-file-pages.patch:
>>
>> when CONFIG_SHMFS is not enabled:
>>
>> mm/shmem.c:2721: error: implicit declaration of function 'SHMEM_I'
>> mm/shmem.c:2721: warning: initialization makes pointer from integer without a cast
>> mm/shmem.c:2726: error: dereferencing pointer to incomplete type
>> mm/shmem.c:2727: error: implicit declaration of function 'shmem_swp_entry'
>> mm/shmem.c:2727: warning: assignment makes pointer from integer without a cast
>> mm/shmem.c:2734: error: implicit declaration of function 'shmem_swp_unmap'
>> mm/shmem.c:2735: error: dereferencing pointer to incomplete type
>>
> Thank you very much for your report.
> 
> I attach a fix patch.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> build fix for !CONFIG_SHMEM case.
> 
>   CC      mm/shmem.o
> mm/shmem.c: In function 'mem_cgroup_get_shmem_target':
> mm/shmem.c:2721: error: implicit declaration of function 'SHMEM_I'
> mm/shmem.c:2721: warning: initialization makes pointer from integer without a cast
> mm/shmem.c:2726: error: dereferencing pointer to incomplete type
> mm/shmem.c:2727: error: implicit declaration of function 'shmem_swp_entry'
> mm/shmem.c:2727: warning: assignment makes pointer from integer without a cast
> mm/shmem.c:2734: error: implicit declaration of function 'shmem_swp_unmap'
> mm/shmem.c:2735: error: dereferencing pointer to incomplete type
> make[1]: *** [mm/shmem.o] Error 1
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
>  mm/shmem.c |   99 +++++++++++++++++++++++++++++++++++++----------------------
>  1 files changed, 62 insertions(+), 37 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index cb87365..6f183ef 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2568,6 +2568,43 @@ out4:
>  	return error;
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/**
> + * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
> + * @inode: the inode to be searched
> + * @pgoff: the offset to be searched
> + * @pagep: the pointer for the found page to be stored
> + * @ent: the pointer for the found swap entry to be stored
> + *
> + * If a page is found, refcount of it is incremented. Callers should handle
> + * these refcount.
> + */
> +void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> +					struct page **pagep, swp_entry_t *ent)
> +{
> +	swp_entry_t entry = { .val = 0 }, *ptr;
> +	struct page *page = NULL;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +
> +	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
> +		goto out;
> +
> +	spin_lock(&info->lock);
> +	ptr = shmem_swp_entry(info, pgoff, NULL);
> +	if (ptr && ptr->val) {
> +		entry.val = ptr->val;
> +		page = find_get_page(&swapper_space, entry.val);
> +	} else
> +		page = find_get_page(inode->i_mapping, pgoff);
> +	if (ptr)
> +		shmem_swp_unmap(ptr);
> +	spin_unlock(&info->lock);
> +out:
> +	*pagep = page;
> +	*ent = entry;
> +}
> +#endif
> +
>  #else /* !CONFIG_SHMEM */
>  
>  /*
> @@ -2607,6 +2644,31 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/**
> + * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
> + * @inode: the inode to be searched
> + * @pgoff: the offset to be searched
> + * @pagep: the pointer for the found page to be stored
> + * @ent: the pointer for the found swap entry to be stored
> + *
> + * If a page is found, refcount of it is incremented. Callers should handle
> + * these refcount.
> + */
> +void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> +					struct page **pagep, swp_entry_t *ent)
> +{
> +	struct page *page = NULL;
> +
> +	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
> +		goto out;
> +	page = find_get_page(inode->i_mapping, pgoff);
> +out:
> +	*pagep = page;
> +	*ent = (swp_entry_t){ .val = 0 };
> +}
> +#endif
> +
>  #define shmem_vm_ops				generic_file_vm_ops
>  #define shmem_file_operations			ramfs_file_operations
>  #define shmem_get_inode(sb, mode, dev, flags)	ramfs_get_inode(sb, mode, dev)
> @@ -2701,40 +2763,3 @@ int shmem_zero_setup(struct vm_area_struct *vma)
>  	vma->vm_ops = &shmem_vm_ops;
>  	return 0;
>  }
> -
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -/**
> - * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
> - * @inode: the inode to be searched
> - * @pgoff: the offset to be searched
> - * @pagep: the pointer for the found page to be stored
> - * @ent: the pointer for the found swap entry to be stored
> - *
> - * If a page is found, refcount of it is incremented. Callers should handle
> - * these refcount.
> - */
> -void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> -					struct page **pagep, swp_entry_t *ent)
> -{
> -	swp_entry_t entry = { .val = 0 }, *ptr;
> -	struct page *page = NULL;
> -	struct shmem_inode_info *info = SHMEM_I(inode);
> -
> -	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
> -		goto out;
> -
> -	spin_lock(&info->lock);
> -	ptr = shmem_swp_entry(info, pgoff, NULL);
> -	if (ptr && ptr->val) {
> -		entry.val = ptr->val;
> -		page = find_get_page(&swapper_space, entry.val);
> -	} else
> -		page = find_get_page(inode->i_mapping, pgoff);
> -	if (ptr)
> -		shmem_swp_unmap(ptr);
> -	spin_unlock(&info->lock);
> -out:
> -	*pagep = page;
> -	*ent = entry;
> -}
> -#endif


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
