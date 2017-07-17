Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D79566B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:52:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z1so170667266pgs.10
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 04:52:35 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0138.outbound.protection.outlook.com. [104.47.1.138])
        by mx.google.com with ESMTPS id r14si12963157pgf.6.2017.07.17.04.52.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 04:52:34 -0700 (PDT)
Subject: Re: [PATCH v2] userfaultfd: non-cooperative: notify about unmap of
 destination during mremap
References: <1500276876-3350-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <79a8ac9a-8f20-2145-6953-427480d2a84e@virtuozzo.com>
Date: Mon, 17 Jul 2017 14:52:25 +0300
MIME-Version: 1.0
In-Reply-To: <1500276876-3350-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, stable@vger.kernel.org

On 07/17/2017 10:34 AM, Mike Rapoport wrote:
> When mremap is called with MREMAP_FIXED it unmaps memory at the destination
> address without notifying userfaultfd monitor. If the destination were
> registered with userfaultfd, the monitor has no way to distinguish between
> the old and new ranges and to properly relate the page faults that would
> occur in the destination region.
> 
> Cc: stable@vger.kernel.org
> Fixes: 897ab3e0c49e ("userfaultfd: non-cooperative: add event for memory
> unmaps")
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>

> ---
> 
> v2: make sure userfault callbacks are called with mmap_sem released
>  
>  mm/mremap.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cd8a1b199ef9..8d6fc5f104d1 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -428,6 +428,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
>  static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
>  		unsigned long new_addr, unsigned long new_len, bool *locked,
>  		struct vm_userfaultfd_ctx *uf,
> +		struct list_head *uf_unmap_early,
>  		struct list_head *uf_unmap)
>  {
>  	struct mm_struct *mm = current->mm;
> @@ -446,7 +447,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
>  	if (addr + old_len > new_addr && new_addr + new_len > addr)
>  		goto out;
>  
> -	ret = do_munmap(mm, new_addr, new_len, NULL);
> +	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
>  	if (ret)
>  		goto out;
>  
> @@ -514,6 +515,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	unsigned long charged = 0;
>  	bool locked = false;
>  	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
> +	LIST_HEAD(uf_unmap_early);
>  	LIST_HEAD(uf_unmap);
>  
>  	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
> @@ -541,7 +543,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  
>  	if (flags & MREMAP_FIXED) {
>  		ret = mremap_to(addr, old_len, new_addr, new_len,
> -				&locked, &uf, &uf_unmap);
> +				&locked, &uf, &uf_unmap_early, &uf_unmap);
>  		goto out;
>  	}
>  
> @@ -621,6 +623,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	up_write(&current->mm->mmap_sem);
>  	if (locked && new_len > old_len)
>  		mm_populate(new_addr + old_len, new_len - old_len);
> +	userfaultfd_unmap_complete(mm, &uf_unmap_early);
>  	mremap_userfaultfd_complete(&uf, addr, new_addr, old_len);
>  	userfaultfd_unmap_complete(mm, &uf_unmap);
>  	return ret;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
