Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 47CAE6B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 03:43:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c137so22583838pga.6
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 00:43:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 78si10927388pgb.691.2017.10.04.00.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 00:43:08 -0700 (PDT)
Date: Wed, 4 Oct 2017 10:43:05 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3] mm: Account pud page tables
Message-ID: <20171004074305.x35eh5u7ybbt5kar@black.fi.intel.com>
References: <20171002080427.3320-1-kirill.shutemov@linux.intel.com>
 <cb28b818-1927-1a36-578b-7ebaa8d1f381@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cb28b818-1927-1a36-578b-7ebaa8d1f381@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Wed, Oct 04, 2017 at 06:03:47AM +0000, Vlastimil Babka wrote:
> On 10/02/2017 10:04 AM, Kirill A. Shutemov wrote:
> > On machine with 5-level paging support a process can allocate
> > significant amount of memory and stay unnoticed by oom-killer and
> > memory cgroup. The trick is to allocate a lot of PUD page tables.
> > We don't account PUD page tables, only PMD and PTE.
> > 
> > We already addressed the same issue for PMD page tables, see
> > dc6c9a35b66b ("mm: account pmd page tables to the process").
> > Introduction 5-level paging bring the same issue for PUD page tables.
> > 
> > The patch expands accounting to PUD level.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Small fix below:
> 
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -25,7 +25,7 @@
> >  
> >  void task_mem(struct seq_file *m, struct mm_struct *mm)
> >  {
> > -	unsigned long text, lib, swap, ptes, pmds, anon, file, shmem;
> > +	unsigned long text, lib, swap, ptes, pmds, puds, anon, file, shmem;
> >  	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
> >  
> >  	anon = get_mm_counter(mm, MM_ANONPAGES);
> > @@ -51,6 +51,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
> >  	swap = get_mm_counter(mm, MM_SWAPENTS);
> >  	ptes = PTRS_PER_PTE * sizeof(pte_t) * atomic_long_read(&mm->nr_ptes);
> >  	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
> > +	puds = PTRS_PER_PUD * sizeof(pmd_t) * mm_nr_puds(mm);
> 
> 				     ^ pud_t ?

Ouch. Thanks for spotting this.

Andrew, could you take this fixup:

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 0bf9e423aa99..627de66204bd 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -51,7 +51,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	swap = get_mm_counter(mm, MM_SWAPENTS);
 	ptes = PTRS_PER_PTE * sizeof(pte_t) * atomic_long_read(&mm->nr_ptes);
 	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
-	puds = PTRS_PER_PUD * sizeof(pmd_t) * mm_nr_puds(mm);
+	puds = PTRS_PER_PUD * sizeof(pud_t) * mm_nr_puds(mm);
 	seq_printf(m,
 		"VmPeak:\t%8lu kB\n"
 		"VmSize:\t%8lu kB\n"
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
