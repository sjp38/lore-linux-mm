Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A41D8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:50:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k66-v6so679994pga.21
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 05:50:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12-v6sor468183pga.230.2018.09.27.05.50.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 05:50:32 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:50:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [v2 PATCH 2/2 -mm] mm: brk: dwongrade mmap_sem to read when
 shrinking
Message-ID: <20180927125025.xnvoh2btdq5kjmai@kshutemo-mobl1>
References: <1537985434-22655-1-git-send-email-yang.shi@linux.alibaba.com>
 <1537985434-22655-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537985434-22655-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 27, 2018 at 02:10:34AM +0800, Yang Shi wrote:
> brk might be used to shinrk memory mapping too other than munmap().

s/shinrk/shrink/

> So, it may hold write mmap_sem for long time when shrinking large
> mapping, as what commit ("mm: mmap: zap pages with read mmap_sem in
> munmap") described.
> 
> The brk() will not manipulate vmas anymore after __do_munmap() call for
> the mapping shrink use case. But, it may set mm->brk after
> __do_munmap(), which needs hold write mmap_sem.
> 
> However, a simple trick can workaround this by setting mm->brk before
> __do_munmap(). Then restore the original value if __do_munmap() fails.
> With this trick, it is safe to downgrade to read mmap_sem.
> 
> So, the same optimization, which downgrades mmap_sem to read for
> zapping pages, is also feasible and reasonable to this case.
> 
> The period of holding exclusive mmap_sem for shrinking large mapping
> would be reduced significantly with this optimization.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v2: Rephrase the commit per Michal
> 
>  mm/mmap.c | 40 ++++++++++++++++++++++++++++++----------
>  1 file changed, 30 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 017bcfa..0d2fae1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -193,9 +193,11 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>  	unsigned long retval;
>  	unsigned long newbrk, oldbrk;
>  	struct mm_struct *mm = current->mm;
> +	unsigned long origbrk = mm->brk;

Is it safe to read mm->brk outside the lock?

>  	struct vm_area_struct *next;
>  	unsigned long min_brk;
>  	bool populate;
> +	bool downgrade = false;

Again,

s/downgrade/downgraded/ ?

>  	LIST_HEAD(uf);
>  
>  	if (down_write_killable(&mm->mmap_sem))
> @@ -229,14 +231,29 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>  
>  	newbrk = PAGE_ALIGN(brk);
>  	oldbrk = PAGE_ALIGN(mm->brk);
> -	if (oldbrk == newbrk)
> -		goto set_brk;
> +	if (oldbrk == newbrk) {
> +		mm->brk = brk;
> +		goto success;
> +	}
>  
> -	/* Always allow shrinking brk. */
> +	/*
> +	 * Always allow shrinking brk.
> +	 * __do_munmap() may downgrade mmap_sem to read.
> +	 */
>  	if (brk <= mm->brk) {
> -		if (!do_munmap(mm, newbrk, oldbrk-newbrk, &uf))
> -			goto set_brk;
> -		goto out;
> +		/*
> +		 * mm->brk need to be protected by write mmap_sem, update it
> +		 * before downgrading mmap_sem.
> +		 * When __do_munmap fail, it will be restored from origbrk.
> +		 */
> +		mm->brk = brk;
> +		retval = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true);
> +		if (retval < 0) {
> +			mm->brk = origbrk;
> +			goto out;
> +		} else if (retval == 1)
> +			downgrade = true;
> +		goto success;
>  	}
>  
>  	/* Check against existing mmap mappings. */
> @@ -247,18 +264,21 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>  	/* Ok, looks good - let it rip. */
>  	if (do_brk_flags(oldbrk, newbrk-oldbrk, 0, &uf) < 0)
>  		goto out;
> -
> -set_brk:
>  	mm->brk = brk;
> +
> +success:
>  	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
> -	up_write(&mm->mmap_sem);
> +	if (downgrade)
> +		up_read(&mm->mmap_sem);
> +	else
> +		up_write(&mm->mmap_sem);
>  	userfaultfd_unmap_complete(mm, &uf);
>  	if (populate)
>  		mm_populate(oldbrk, newbrk - oldbrk);
>  	return brk;
>  
>  out:
> -	retval = mm->brk;
> +	retval = origbrk;
>  	up_write(&mm->mmap_sem);
>  	return retval;
>  }
> -- 
> 1.8.3.1
> 

-- 
 Kirill A. Shutemov
