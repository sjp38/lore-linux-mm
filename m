Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 363A96B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 05:54:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id v26-v6so3123629eds.9
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 02:54:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6-v6si3565575eds.237.2018.08.10.02.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 02:54:20 -0700 (PDT)
Subject: Re: [RFC v7 PATCH 4/4] mm: unmap special vmas with regular
 do_munmap()
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-5-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <521a7d54-efdb-2401-c677-3f5fcbad557b@suse.cz>
Date: Fri, 10 Aug 2018 11:51:54 +0200
MIME-Version: 1.0
In-Reply-To: <1533857763-43527-5-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
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

Hm I believe Michal meant the opposite "evolution" though. Patch 2/4
should be done in a way that special mappings keep using the regular
path, and this patch would convert them to the new path. Possibly even
each special case separately.

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
> +	     vma_has_uprobes(vma, vma->vm_start, vma->vm_end)) ||
> +	     (vma->vm_flags | (VM_HUGETLB | VM_PFNMAP)))
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
> +	ret = do_munmap(mm, start, len, uf);
> +
>  out:
>  	up_write(&mm->mmap_sem);
>  	return ret;
> 
