Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3701F6B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:03:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n17-v6so538006pff.17
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:03:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y10-v6si10860887plp.5.2018.07.24.13.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 13:03:10 -0700 (PDT)
Date: Tue, 24 Jul 2018 13:03:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 1/3] mm: Introduce vma_init()
Message-Id: <20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
In-Reply-To: <20180724121139.62570-2-kirill.shutemov@linux.intel.com>
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
	<20180724121139.62570-2-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 24 Jul 2018 15:11:37 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Not all VMAs allocated with vm_area_alloc(). Some of them allocated on
> stack or in data segment.
> 
> The new helper can be use to initialize VMA properly regardless where
> it was allocated.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -452,6 +452,12 @@ struct vm_operations_struct {
>  					  unsigned long addr);
>  };
>  
> +static inline void vma_init(struct vm_area_struct *vma, struct mm_struct *mm)
> +{
> +	vma->vm_mm = mm;
> +	INIT_LIST_HEAD(&vma->anon_vma_chain);
> +}
> +
>  struct mmu_gather;
>  struct inode;
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index a191c05e757d..1b27babc4c78 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -312,10 +312,8 @@ struct vm_area_struct *vm_area_alloc(struct mm_struct *mm)
>  {
>  	struct vm_area_struct *vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);

I'd sleep better if this became a kmem_cache_alloc() and the memset
was moved into vma_init().  A bunch of the vma_init() callers are
already doing the memset and the others risk leaving uninitialized
stack fields in the vma.

>  
> -	if (vma) {
> -		vma->vm_mm = mm;
> -		INIT_LIST_HEAD(&vma->anon_vma_chain);
> -	}
> +	if (vma)
> +		vma_init(vma, mm);
>  	return vma;
>  }
