Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 771436B0007
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 06:49:12 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f91-v6so5658720plb.10
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 03:49:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6-v6si8564748plf.316.2018.08.10.03.49.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 03:49:11 -0700 (PDT)
Subject: Re: [RFC v7 PATCH 4/4] mm: unmap special vmas with regular
 do_munmap()
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-5-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <93bbbf91-2bae-b5f1-17d3-72a13efc3ec6@suse.cz>
Date: Fri, 10 Aug 2018 12:46:42 +0200
MIME-Version: 1.0
In-Reply-To: <1533857763-43527-5-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/10/2018 01:36 AM, Yang Shi wrote:
> Unmapping vmas, which have VM_HUGETLB | VM_PFNMAP flag set or
> have uprobes set, need get done with write mmap_sem held since
> they may update vm_flags.
> 
> So, it might be not safe enough to deal with these kind of special
> mappings with read mmap_sem. Deal with such mappings with regular
> do_munmap() call.
> 
> Michal suggested to make this as a separate patch for safer and more
> bisectable sake.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/mmap.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2234d5a..06cb83c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2766,6 +2766,16 @@ static inline void munlock_vmas(struct vm_area_struct *vma,
>  	}
>  }
>  
> +static inline bool can_zap_with_rlock(struct vm_area_struct *vma)
> +{
> +	if ((vma->vm_file &&
> +	     vma_has_uprobes(vma, vma->vm_start, vma->vm_end)) |

vma_has_uprobes() seems to be rather expensive check with e.g.
unconditional spinlock. uprobe_munmap() seems to have some precondition
cheaper checks for e.g. cases when there's no uprobes in the system
(should be common?).

BTW, uprobe_munmap() touches mm->flags, not vma->flags, so it should be
evaluated more carefully for being called under mmap sem for reading, as
having vmas already detached is no guarantee.

> +	     (vma->vm_flags | (VM_HUGETLB | VM_PFNMAP)))

			    ^ I think replace '|' with '&' here?

> +		return false;
> +
> +	return true;
> +}
> +
>  /*
>   * Zap pages with read mmap_sem held
>   *
> @@ -2808,6 +2818,17 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
>  			goto out;
>  	}
>  
> +	/*
> +	 * Unmapping vmas, which have VM_HUGETLB | VM_PFNMAP flag set or
> +	 * have uprobes set, need get done with write mmap_sem held since
> +	 * they may update vm_flags. Deal with such mappings with regular
> +	 * do_munmap() call.
> +	 */
> +	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
> +		if (!can_zap_with_rlock(vma))
> +			goto regular_path;
> +	}
> +
>  	/* Handle mlocked vmas */
>  	if (mm->locked_vm) {
>  		vma = start_vma;
> @@ -2828,6 +2849,9 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
>  
>  	return 0;
>  
> +regular_path:

I think it's missing a down_write_* here.

> +	ret = do_munmap(mm, start, len, uf);
> +
>  out:
>  	up_write(&mm->mmap_sem);
>  	return ret;
> 
