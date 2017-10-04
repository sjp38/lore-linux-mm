Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6DB6B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 02:03:50 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k15so5438706wrc.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 23:03:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u27si12201604wrf.285.2017.10.03.23.03.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 23:03:49 -0700 (PDT)
Subject: Re: [PATCHv3] mm: Account pud page tables
References: <20171002080427.3320-1-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cb28b818-1927-1a36-578b-7ebaa8d1f381@suse.cz>
Date: Wed, 4 Oct 2017 08:03:47 +0200
MIME-Version: 1.0
In-Reply-To: <20171002080427.3320-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On 10/02/2017 10:04 AM, Kirill A. Shutemov wrote:
> On machine with 5-level paging support a process can allocate
> significant amount of memory and stay unnoticed by oom-killer and
> memory cgroup. The trick is to allocate a lot of PUD page tables.
> We don't account PUD page tables, only PMD and PTE.
> 
> We already addressed the same issue for PMD page tables, see
> dc6c9a35b66b ("mm: account pmd page tables to the process").
> Introduction 5-level paging bring the same issue for PUD page tables.
> 
> The patch expands accounting to PUD level.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Small fix below:

> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -25,7 +25,7 @@
>  
>  void task_mem(struct seq_file *m, struct mm_struct *mm)
>  {
> -	unsigned long text, lib, swap, ptes, pmds, anon, file, shmem;
> +	unsigned long text, lib, swap, ptes, pmds, puds, anon, file, shmem;
>  	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
>  
>  	anon = get_mm_counter(mm, MM_ANONPAGES);
> @@ -51,6 +51,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  	swap = get_mm_counter(mm, MM_SWAPENTS);
>  	ptes = PTRS_PER_PTE * sizeof(pte_t) * atomic_long_read(&mm->nr_ptes);
>  	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
> +	puds = PTRS_PER_PUD * sizeof(pmd_t) * mm_nr_puds(mm);

				     ^ pud_t ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
