Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C25B6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:32:07 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id tz10so227450560pab.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 01:32:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s69si31139040pgc.234.2016.10.18.01.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 01:32:06 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9I8SaZ1125962
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:32:06 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 265a0w8739-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:32:05 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Oct 2016 02:32:04 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs eventually kill my system
In-Reply-To: <472921348.43188.1476715444366.JavaMail.zimbra@redhat.com>
References: <57FF7BB4.1070202@redhat.com> <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com> <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com> <58009BE2.5010805@redhat.com> <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com> <472921348.43188.1476715444366.JavaMail.zimbra@redhat.com>
Date: Tue, 18 Oct 2016 14:01:55 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87funurrb8.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hillf zj <hillf.zj@alibaba-inc.com>, dave hansen <dave.hansen@linux.intel.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, iamjoonsoo kim <iamjoonsoo.kim@lge.com>

Jan Stancek <jstancek@redhat.com> writes:
> Hi Mike,
>
> Revert of 67961f9db8c4 helps, I let whole suite run for 100 iterations,
> there were no issues.
>
> I cut down reproducer and removed last mmap/write/munmap as that is enough
> to reproduce the problem. Then I started introducing some traces into kernel
> and noticed that on ppc I get 3 faults, while on x86 I get only 2.
>
> Interesting is the 2nd fault, that is first write after mapping as PRIVATE.
> Following condition fails on ppc first time:
>     if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
> but it's immediately followed by fault that looks identical
> and in that one it evaluates as true.
>
> Same with alloc_huge_page(), on x86_64 it's called twice, on ppc three times.
> In 2nd call vma_needs_reservation() returns 0, in 3rd it returns 1.
>
> ---- ppc -> 2nd and 3rd fault ---
> mmap(MAP_PRIVATE)
> hugetlb_fault address: 3effff000000, flags: 55
> hugetlb_cow old_page: f0000000010fc000
> alloc_huge_page ret: f000000001100000
> hugetlb_cow ptep: c000000455b27cf8, pte_same: 0
> free_huge_page page: f000000001100000, restore_reserve: 1
> hugetlb_fault address: 3effff000000, flags: 55
> hugetlb_cow old_page: f0000000010fc000
> alloc_huge_page ret: f000000001100000
> hugetlb_cow ptep: c000000455b27cf8, pte_same: 1
>
> --- x86_64 -> 2nd fault ---
> mmap(MAP_PRIVATE)
> hugetlb_fault address: 7f71a4200000, flags: 55
> hugetlb_cow address 0x7f71a4200000, old_page: ffffea0008d20000
> alloc_huge_page ret: ffffea0008d38000
> hugetlb_cow ptep: ffff8802314c7908, pte_same: 1
>
> Regards,
> Jan
>

Can you check with the below patch. I ran the corrupt-by-cow-opt test with this patch
and resv count got correctly updated.

commit fb2e0c081d2922c8aaa49bbe166472aac68ef5e1
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Tue Oct 18 11:23:11 2016 +0530

    mm/hugetlb: Use the right pte val for compare in hugetlb_cow
    
    We cannot use the pte value used in set_pte_at for pte_same comparison,
    because archs like ppc64, filter/add new pte flag in set_pte_at. Instead
    fetch the pte value inside hugetlb_cow. We are comparing pte value to
    make sure the pte didn't change since we dropped the page table lock.
    hugetlb_cow get called with page table lock held, and we can take a copy
    of the pte value before we drop the page table lock.
    
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec49d9ef1eef..da8fbd02b92e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3386,15 +3386,17 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
  * Keep the pte_same checks anyway to make transition from the mutex easier.
  */
 static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep, pte_t pte,
-			struct page *pagecache_page, spinlock_t *ptl)
+		       unsigned long address, pte_t *ptep,
+		       struct page *pagecache_page, spinlock_t *ptl)
 {
+	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
 	int ret = 0, outside_reserve = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
+	pte = huge_ptep_get(ptep);
 	old_page = pte_page(pte);
 
 retry_avoidcopy:
@@ -3668,7 +3670,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	hugetlb_count_add(pages_per_huge_page(h), mm);
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
-		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page, ptl);
+		ret = hugetlb_cow(mm, vma, address, ptep, page, ptl);
 	}
 
 	spin_unlock(ptl);
@@ -3822,8 +3824,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!huge_pte_write(entry)) {
-			ret = hugetlb_cow(mm, vma, address, ptep, entry,
-					pagecache_page, ptl);
+			ret = hugetlb_cow(mm, vma, address, ptep,
+					  pagecache_page, ptl);
 			goto out_put_page;
 		}
 		entry = huge_pte_mkdirty(entry);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
