Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6416C6B025E
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:44:14 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c126so85891137vkd.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 07:44:14 -0700 (PDT)
Received: from mx6-phx2.redhat.com (mx6-phx2.redhat.com. [209.132.183.39])
        by mx.google.com with ESMTPS id 76si14485982vkc.108.2016.10.17.07.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 07:44:13 -0700 (PDT)
Date: Mon, 17 Oct 2016 10:44:04 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <472921348.43188.1476715444366.JavaMail.zimbra@redhat.com>
In-Reply-To: <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com>
References: <57FF7BB4.1070202@redhat.com> <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com> <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com> <58009BE2.5010805@redhat.com> <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com>
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hillf zj <hillf.zj@alibaba-inc.com>, dave hansen <dave.hansen@linux.intel.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, iamjoonsoo kim <iamjoonsoo.kim@lge.com>


----- Original Message -----
> From: "Mike Kravetz" <mike.kravetz@oracle.com>
> To: "Jan Stancek" <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Cc: "hillf zj" <hillf.zj@alibaba-inc.com>, "dave hansen" <dave.hansen@linux.intel.com>, "kirill shutemov"
> <kirill.shutemov@linux.intel.com>, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, "aneesh kumar"
> <aneesh.kumar@linux.vnet.ibm.com>, "iamjoonsoo kim" <iamjoonsoo.kim@lge.com>
> Sent: Saturday, 15 October, 2016 1:57:31 AM
> Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs eventually kill my system
> 
> 
> It is pretty consistent that we leak a reserve page every time this
> test is run.
> 
> The interesting thing is that corrupt-by-cow-opt is a very simple
> test case.  commit 67961f9db8c4 potentially changes the return value
> of the functions vma_has_reserves() and vma_needs/commit_reservation()
> for the owner (HPAGE_RESV_OWNER) of private mappings.  running the
> test with and without the commit results in the same return values for
> these routines on x86.  And, no leaked reserve pages.
> 
> Is it possible to revert this commit and run the libhugetlbs tests
> (func and stress) again while monitoring the counts in /sys?  The
> counts should go to zero after cleanup as you describe above.  I just
> want to make sure that this commit is causing all the problems you
> are seeing.  If it is, then we can consider reverting and I can try
> to think of another way to address the original issue.
> 
> Thanks for your efforts on this.  I can not reproduce on x86 or sparc
> and do not see any similar symptoms on these architectures.
> 
> --
> Mike Kravetz
> 

Hi Mike,

Revert of 67961f9db8c4 helps, I let whole suite run for 100 iterations,
there were no issues.

I cut down reproducer and removed last mmap/write/munmap as that is enough
to reproduce the problem. Then I started introducing some traces into kernel
and noticed that on ppc I get 3 faults, while on x86 I get only 2.

Interesting is the 2nd fault, that is first write after mapping as PRIVATE.
Following condition fails on ppc first time:
    if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
but it's immediately followed by fault that looks identical
and in that one it evaluates as true.

Same with alloc_huge_page(), on x86_64 it's called twice, on ppc three times.
In 2nd call vma_needs_reservation() returns 0, in 3rd it returns 1.

---- ppc -> 2nd and 3rd fault ---
mmap(MAP_PRIVATE)
hugetlb_fault address: 3effff000000, flags: 55
hugetlb_cow old_page: f0000000010fc000
alloc_huge_page ret: f000000001100000
hugetlb_cow ptep: c000000455b27cf8, pte_same: 0
free_huge_page page: f000000001100000, restore_reserve: 1
hugetlb_fault address: 3effff000000, flags: 55
hugetlb_cow old_page: f0000000010fc000
alloc_huge_page ret: f000000001100000
hugetlb_cow ptep: c000000455b27cf8, pte_same: 1

--- x86_64 -> 2nd fault ---
mmap(MAP_PRIVATE)
hugetlb_fault address: 7f71a4200000, flags: 55
hugetlb_cow address 0x7f71a4200000, old_page: ffffea0008d20000
alloc_huge_page ret: ffffea0008d38000
hugetlb_cow ptep: ffff8802314c7908, pte_same: 1

Regards,
Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
