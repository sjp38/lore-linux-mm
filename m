Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m59HMjEZ017718
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 22:52:45 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m59HM6KF749586
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 22:52:07 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m59HMi5S018347
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 22:52:44 +0530
Date: Mon, 9 Jun 2008 22:52:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: 2.6.26-rc5-mm1
Message-ID: <20080609172238.GA27158@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080609053908.8021a635.akpm@linux-foundation.org> <484D6671.302@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <484D6671.302@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2008-06-09 22:50:49]:

> Andrew Morton wrote:
> > 
> > +memrlimit-add-memrlimit-controller-documentation.patch
> > +memrlimit-setup-the-memrlimit-controller.patch
> > +memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch
> > +memrlimit-add-memrlimit-controller-accounting-and-control.patch
> > 
> >  New cgroup conrtoller
> > 

Hi, Andrew,

There seems to be a merge fuzz, sorry for not catching it when you sent the mm
merge email

What I sent was

@@ -2056,6 +2058,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+	memrlimit_cgroup_uncharge_as(mm, mm->total_vm);

What got merged is

@@ -1756,7 +1783,8 @@ static void unmap_region(struct mm_struc
        update_hiwater_rss(mm);
        unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
        vm_unacct_memory(nr_accounted);
-       free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
+       memrlimit_cgroup_uncharge_as(mm, mm->total_vm);

Here's a patch to fix the problem


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/mmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/memory.c~memrlimit-fix-fuzz-in-merge mm/memory.c
diff -puN mm/mmap.c~memrlimit-fix-fuzz-in-merge mm/mmap.c
--- linux-2.6.26-rc5/mm/mmap.c~memrlimit-fix-fuzz-in-merge	2008-06-09 22:49:49.000000000 +0530
+++ linux-2.6.26-rc5-balbir/mm/mmap.c	2008-06-09 22:50:13.000000000 +0530
@@ -1783,7 +1783,6 @@ static void unmap_region(struct mm_struc
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	memrlimit_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
@@ -2111,6 +2110,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+	memrlimit_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
_


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
