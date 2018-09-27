Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A126F8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:46:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b17-v6so2435003pfo.20
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 05:46:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k76-v6sor467734pga.191.2018.09.27.05.46.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 05:46:24 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:46:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [v2 PATCH 1/2 -mm] mm: mremap: dwongrade mmap_sem to read when
 shrinking
Message-ID: <20180927124618.dsg4xtxcmn5hrdj6@kshutemo-mobl1>
References: <1537985434-22655-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537985434-22655-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 27, 2018 at 02:10:33AM +0800, Yang Shi wrote:
> Other than munmap, mremap might be used to shrink memory mapping too.
> So, it may hold write mmap_sem for long time when shrinking large
> mapping, as what commit ("mm: mmap: zap pages with read mmap_sem in
> munmap") described.
> 
> The mremap() will not manipulate vmas anymore after __do_munmap() call for
> the mapping shrink use case, so it is safe to downgrade to read mmap_sem.
> 
> So, the same optimization, which downgrades mmap_sem to read for zapping
> pages, is also feasible and reasonable to this case.
> 
> The period of holding exclusive mmap_sem for shrinking large mapping
> would be reduced significantly with this optimization.
> 
> MREMAP_FIXED and MREMAP_MAYMOVE are more complicated to adopt this
> optimization since they need manipulate vmas after do_munmap(),
> downgrading mmap_sem may create race window.
> 
> Simple mapping shrink is the low hanging fruit, and it may cover the
> most cases of unmap with munmap together.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v2: Rephrase the commit log per Michal
> 
>  include/linux/mm.h |  2 ++
>  mm/mmap.c          |  4 ++--
>  mm/mremap.c        | 17 +++++++++++++----
>  3 files changed, 17 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a61ebe8..3028028 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2286,6 +2286,8 @@ extern unsigned long do_mmap(struct file *file, unsigned long addr,
>  	unsigned long len, unsigned long prot, unsigned long flags,
>  	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
>  	struct list_head *uf);
> +extern int __do_munmap(struct mm_struct *, unsigned long, size_t,
> +		       struct list_head *uf, bool downgrade);
>  extern int do_munmap(struct mm_struct *, unsigned long, size_t,
>  		     struct list_head *uf);
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 847a17d..017bcfa 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2687,8 +2687,8 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>   * work.  This now handles partial unmappings.
>   * Jeremy Fitzhardinge <jeremy@goop.org>
>   */
> -static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
> -		       struct list_head *uf, bool downgrade)
> +int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
> +		struct list_head *uf, bool downgrade)
>  {
>  	unsigned long end;
>  	struct vm_area_struct *vma, *prev, *last;
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 5c2e185..8f1ec2b 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -525,6 +525,7 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
>  	unsigned long ret = -EINVAL;
>  	unsigned long charged = 0;
>  	bool locked = false;
> +	bool downgrade = false;

s/downgrade/downgraded/ ?

Otherwise looks good to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
