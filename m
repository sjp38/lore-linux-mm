Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51D426B0038
	for <linux-mm@kvack.org>; Thu, 18 May 2017 01:53:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u187so26687426pgb.0
        for <linux-mm@kvack.org>; Wed, 17 May 2017 22:53:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p12si4207881pli.219.2017.05.17.22.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 22:53:43 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4I5iOp9032605
	for <linux-mm@kvack.org>; Thu, 18 May 2017 01:53:42 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2agwapjf8u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 May 2017 01:53:42 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 18 May 2017 06:53:40 +0100
Date: Thu, 18 May 2017 08:53:33 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] Patch for remapping pages around the fault page
References: <CAC2c7Jts5uZOLXVi9N7xYXxxycv9xM1TBxcC3nMyn0NL-O+spw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC2c7Jts5uZOLXVi9N7xYXxxycv9xM1TBxcC3nMyn0NL-O+spw@mail.gmail.com>
Message-Id: <20170518055333.GC24445@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sarunya Pumma <sarunya@vt.edu>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com, lstoakes@gmail.com, dave.jiang@intel.com, linux-mm@kvack.org

Hello,

On Tue, May 16, 2017 at 12:16:00PM -0400, Sarunya Pumma wrote:
> After the fault handler performs the __do_fault function to read a fault
> page when a page fault occurs, it does not map other pages that have been
> read together with the fault page. This can cause a number of minor page
> faults to be large. Therefore, this patch is developed to remap pages
> around the fault page by aiming to map the pages that have been read
> with the fault page.

[...] 
 
> Thank you very much for your time for reviewing the patch.
> 
> Signed-off-by: Sarunya Pumma <sarunya@vt.edu>
> ---
>  include/linux/mm.h |  2 ++
>  kernel/sysctl.c    |  8 +++++
>  mm/memory.c        | 90
> ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 100 insertions(+)

The patch is completely unreadable :(
Please use a mail client that does not break whitespace, e.g 'git
send-email'
 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7cb17c6..2d533a3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -34,6 +34,8 @@ struct bdi_writeback;
> 
>  void init_mm_internals(void);
> 
> +extern unsigned long vm_nr_remapping;
> +
>  #ifndef CONFIG_NEED_MULTIPLE_NODES /* Don't use mapnrs, do it properly */
>  extern unsigned long max_mapnr;
> 
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 4dfba1a..16c7efe 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1332,6 +1332,14 @@ static struct ctl_table vm_table[] = {
>   .extra1 = &zero,
>   .extra2 = &one_hundred,
>   },
> + {
> + .procname = "nr_remapping",
> + .data = &vm_nr_remapping,
> + .maxlen = sizeof(vm_nr_remapping),
> + .mode = 0644,
> + .proc_handler = proc_doulongvec_minmax,
> + .extra1 = &zero,
> + },
>  #ifdef CONFIG_HUGETLB_PAGE
>   {
>   .procname = "nr_hugepages",
> diff --git a/mm/memory.c b/mm/memory.c
> index 6ff5d72..3d0dca9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -83,6 +83,9 @@
>  #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame
> for last_cpupid.
>  #endif
> 
> +/* A preset threshold for considering page remapping */
> +unsigned long vm_nr_remapping = 32;
> +
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
>  /* use the per-pgdat data instead for discontigmem - mbligh */
>  unsigned long max_mapnr;
> @@ -3374,6 +3377,82 @@ static int do_fault_around(struct vm_fault *vmf)
>   return ret;
>  }
> 
> +static int redo_fault_around(struct vm_fault *vmf)
> +{
> + unsigned long address = vmf->address, nr_pages, mask;
> + pgoff_t start_pgoff = vmf->pgoff;
> + pgoff_t end_pgoff;
> + pte_t *lpte, *rpte;
> + int off, ret = 0, is_mapped = 0;
> +
> + nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
> + mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
> +
> + vmf->address = max(address & mask, vmf->vma->vm_start);
> + off = ((address - vmf->address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
> + start_pgoff -= off;
> +
> + /*
> + *  end_pgoff is either end of page table or end of vma
> + *  or fault_around_pages() from start_pgoff, depending what is nearest.
> + */
> + end_pgoff = start_pgoff -
> + ((vmf->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
> + PTRS_PER_PTE - 1;
> + end_pgoff = min3(end_pgoff, vma_pages(vmf->vma) + vmf->vma->vm_pgoff - 1,
> + start_pgoff + nr_pages - 1);
> +
> + if (nr_pages < vm_nr_remapping) {
> + int i, start_off = 0, end_off = 0;
> +
> + lpte = vmf->pte - off;
> + for (i = 0; i < nr_pages; i++) {
> + if (!pte_none(*lpte)) {
> + is_mapped++;
> + } else {
> + if (!start_off)
> + start_off = i;
> + end_off = i;
> + }
> + lpte++;
> + }
> + if (is_mapped != nr_pages) {
> + is_mapped = 0;
> + end_pgoff = start_pgoff + end_off;
> + start_pgoff += start_off;
> + vmf->pte += start_off;
> + }
> + lpte = NULL;
> + } else {
> + lpte = vmf->pte - 1;
> + rpte = vmf->pte + 1;
> + if (!pte_none(*lpte) && !pte_none(*rpte))
> + is_mapped = 1;
> + lpte = NULL;
> + rpte = NULL;
> + }
> +
> + if (!is_mapped) {
> + vmf->pte -= off;
> + vmf->vma->vm_ops->map_pages(vmf, start_pgoff, end_pgoff);
> + vmf->pte -= (vmf->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
> + }
> +
> + /* Huge page is mapped? Page fault is solved */
> + if (pmd_trans_huge(*vmf->pmd)) {
> + ret = VM_FAULT_NOPAGE;
> + goto out;
> + }
> +
> + if (vmf->pte)
> + pte_unmap_unlock(vmf->pte, vmf->ptl);
> +
> +out:
> + vmf->address = address;
> + vmf->pte = NULL;
> + return ret;
> +}
> +
>  static int do_read_fault(struct vm_fault *vmf)
>  {
>   struct vm_area_struct *vma = vmf->vma;
> @@ -3394,6 +3473,17 @@ static int do_read_fault(struct vm_fault *vmf)
>   if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>   return ret;
> 
> + /*
> + * Remap pages after read
> + */
> + if (!(vma->vm_flags & VM_RAND_READ) && vma->vm_ops->map_pages
> + && fault_around_bytes >> PAGE_SHIFT > 1) {
> + ret |= alloc_set_pte(vmf, vmf->memcg, vmf->page);
> + unlock_page(vmf->page);
> + redo_fault_around(vmf);
> + return ret;
> + }
> +
>   ret |= finish_fault(vmf);
>   unlock_page(vmf->page);
>   if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
