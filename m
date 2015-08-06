Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C43BB280245
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 11:53:36 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so28349128wib.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 08:53:36 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id gk19si13632407wjc.187.2015.08.06.08.53.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 08:53:35 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so28213123wic.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 08:53:34 -0700 (PDT)
Date: Thu, 6 Aug 2015 18:53:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V6 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150806155332.GA3118@node.dhcp.inet.fi>
References: <1438184575-10537-1-git-send-email-emunson@akamai.com>
 <1438184575-10537-4-git-send-email-emunson@akamai.com>
 <55C37E62.6020909@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55C37E62.6020909@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu, Aug 06, 2015 at 05:33:54PM +0200, Vlastimil Babka wrote:
> On 07/29/2015 05:42 PM, Eric B Munson wrote:
> >The cost of faulting in all memory to be locked can be very high when
> >working with large mappings.  If only portions of the mapping will be
> >used this can incur a high penalty for locking.
> >
> >For the example of a large file, this is the usage pattern for a large
> >statical language model (probably applies to other statical or graphical
> >models as well).  For the security example, any application transacting
> >in data that cannot be swapped out (credit card data, medical records,
> >etc).
> >
> >This patch introduces the ability to request that pages are not
> >pre-faulted, but are placed on the unevictable LRU when they are finally
> >faulted in.  The VM_LOCKONFAULT flag will be used together with
> >VM_LOCKED and has no effect when set without VM_LOCKED.  Setting the
> >VM_LOCKONFAULT flag for a VMA will cause pages faulted into that VMA to
> >be added to the unevictable LRU when they are faulted or if they are
> >already present, but will not cause any missing pages to be faulted in.
> >
> >Exposing this new lock state means that we cannot overload the meaning
> >of the FOLL_POPULATE flag any longer.  Prior to this patch it was used
> >to mean that the VMA for a fault was locked.  This means we need the
> >new FOLL_MLOCK flag to communicate the locked state of a VMA.
> >FOLL_POPULATE will now only control if the VMA should be populated and
> >in the case of VM_LOCKONFAULT, it will not be set.
> >
> >Signed-off-by: Eric B Munson <emunson@akamai.com>
> >Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Cc: Michal Hocko <mhocko@suse.cz>
> >Cc: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Jonathan Corbet <corbet@lwn.net>
> >Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> >Cc: linux-kernel@vger.kernel.org
> >Cc: dri-devel@lists.freedesktop.org
> >Cc: linux-mm@kvack.org
> >Cc: linux-api@vger.kernel.org
> >---
> >  drivers/gpu/drm/drm_vm.c |  8 +++++++-
> >  fs/proc/task_mmu.c       |  1 +
> >  include/linux/mm.h       |  2 ++
> >  kernel/fork.c            |  2 +-
> >  mm/debug.c               |  1 +
> >  mm/gup.c                 | 10 ++++++++--
> >  mm/huge_memory.c         |  2 +-
> >  mm/hugetlb.c             |  4 ++--
> >  mm/mlock.c               |  2 +-
> >  mm/mmap.c                |  2 +-
> >  mm/rmap.c                |  4 ++--
> >  11 files changed, 27 insertions(+), 11 deletions(-)
> >
> >diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
> >index aab49ee..103a5f6 100644
> >--- a/drivers/gpu/drm/drm_vm.c
> >+++ b/drivers/gpu/drm/drm_vm.c
> >@@ -699,9 +699,15 @@ int drm_vma_info(struct seq_file *m, void *data)
> >  		   (void *)(unsigned long)virt_to_phys(high_memory));
> >
> >  	list_for_each_entry(pt, &dev->vmalist, head) {
> >+		char lock_flag = '-';
> >+
> >  		vma = pt->vma;
> >  		if (!vma)
> >  			continue;
> >+		if (vma->vm_flags & VM_LOCKONFAULT)
> >+			lock_flag = 'f';
> >+		else if (vma->vm_flags & VM_LOCKED)
> >+			lock_flag = 'l';
> >  		seq_printf(m,
> >  			   "\n%5d 0x%pK-0x%pK %c%c%c%c%c%c 0x%08lx000",
> >  			   pt->pid,
> >@@ -710,7 +716,7 @@ int drm_vma_info(struct seq_file *m, void *data)
> >  			   vma->vm_flags & VM_WRITE ? 'w' : '-',
> >  			   vma->vm_flags & VM_EXEC ? 'x' : '-',
> >  			   vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
> >-			   vma->vm_flags & VM_LOCKED ? 'l' : '-',
> >+			   lock_flag,
> >  			   vma->vm_flags & VM_IO ? 'i' : '-',
> >  			   vma->vm_pgoff);
> >
> >diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> >index ca1e091..38d69fc 100644
> >--- a/fs/proc/task_mmu.c
> >+++ b/fs/proc/task_mmu.c
> >@@ -579,6 +579,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
> 
> This function has the following comment:
> 
> Don't forget to update Documentation/ on changes.
> 
> [...]
> 
> >--- a/mm/gup.c
> >+++ b/mm/gup.c
> >@@ -92,7 +92,7 @@ retry:
> >  		 */
> >  		mark_page_accessed(page);
> >  	}
> >-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
> >+	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> >  		/*
> >  		 * The preliminary mapping check is mainly to avoid the
> >  		 * pointless overhead of lock_page on the ZERO_PAGE
> >@@ -265,6 +265,9 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
> >  	unsigned int fault_flags = 0;
> >  	int ret;
> >
> >+	/* mlock all present pages, but do not fault in new pages */
> >+	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
> >+		return -ENOENT;
> >  	/* For mm_populate(), just skip the stack guard page. */
> >  	if ((*flags & FOLL_POPULATE) &&
> >  			(stack_guard_page_start(vma, address) ||
> >@@ -850,7 +853,10 @@ long populate_vma_page_range(struct vm_area_struct *vma,
> >  	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
> >  	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
> >
> >-	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
> >+	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
> >+	if ((vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) == VM_LOCKED)
> >+		gup_flags |= FOLL_POPULATE;
> >+
> >  	/*
> >  	 * We want to touch writable mappings with a write fault in order
> >  	 * to break COW, except for shared mappings because these don't COW
> 
> I think this might be breaking the populate part of mmap(MAP_POPULATE &
> ~MAP_LOCKED) case, if I follow the execution correctly (it's far from
> simple...)
> 
> SYSCALL_DEFINE6(mmap_pgoff... with MAP_POPULATE
>   vm_mmap_pgoff(..., MAP_POPULATE...)
>     do_mmap_pgoff(...MAP_POPULATE... &populate) -> populate == TRUE
>     mm_populate()
>       __mm_populate()
>         populate_vma_page_range()
> 
> Previously, this path would have FOLL_POPULATE in gup_flags and continue
> with __get_user_pages() and faultin_page() (actually regardless of
> FOLL_POPULATE) which would fault in the pages.
> 
> After your patch, populate_vma_page_range() will set FOLL_MLOCK, but since
> VM_LOCKED is not set, FOLL_POPULATE won't be set either.
> Then faultin_page() will return on the new check:
> 
> 	flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK

Good catch!

I guess it should be something like:

	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
	if (vma->vm_flags & VM_LOCKONFAULT) 
		gup_flags &= ~FOLL_POPULATE;

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
