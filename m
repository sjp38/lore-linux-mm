Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 277666B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 14:28:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i85so203770125pfa.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 11:28:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ih4si26675239pab.37.2016.10.17.11.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 11:28:17 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9HINjQ8008386
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 14:28:16 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 264y7c6t4j-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 14:28:16 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Oct 2016 12:28:15 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs eventually kill my system
In-Reply-To: <472921348.43188.1476715444366.JavaMail.zimbra@redhat.com>
References: <57FF7BB4.1070202@redhat.com> <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com> <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com> <58009BE2.5010805@redhat.com> <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com> <472921348.43188.1476715444366.JavaMail.zimbra@redhat.com>
Date: Mon, 17 Oct 2016 23:57:05 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87h98a96h2.fsf@linux.vnet.ibm.com>
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

ok, we miss the _PAGE_PTE in new_pte there. 

	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
				&& (vma->vm_flags & VM_SHARED)));
	set_huge_pte_at(mm, address, ptep, new_pte);

	hugetlb_count_add(pages_per_huge_page(h), mm);
	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
		/* Optimization, do the COW without a second fault */
		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page, ptl);
	}

IMHO that new_pte usage is wrong, because we don't consider flags that
can possibly be added by set_huge_pte_at there. For pp64 we add _PAGE_PTE 

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

But I guess we still have issue with respecting reservation here.

I will look at _PAGE_PTE and see what best we can do w.r.t hugetlb.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
