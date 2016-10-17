Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0CC6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 19:20:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 131so221112544ioo.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 16:20:07 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p125si612881iof.179.2016.10.17.16.20.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 16:20:06 -0700 (PDT)
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
References: <57FF7BB4.1070202@redhat.com>
 <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com>
 <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com>
 <58009BE2.5010805@redhat.com>
 <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com>
 <472921348.43188.1476715444366.JavaMail.zimbra@redhat.com>
 <87h98a96h2.fsf@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a08bc514-e351-d0d0-424e-e1a2695510b7@oracle.com>
Date: Mon, 17 Oct 2016 16:19:55 -0700
MIME-Version: 1.0
In-Reply-To: <87h98a96h2.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hillf zj <hillf.zj@alibaba-inc.com>, dave hansen <dave.hansen@linux.intel.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, iamjoonsoo kim <iamjoonsoo.kim@lge.com>

On 10/17/2016 11:27 AM, Aneesh Kumar K.V wrote:
> Jan Stancek <jstancek@redhat.com> writes:
> 
> 
>> Hi Mike,
>>
>> Revert of 67961f9db8c4 helps, I let whole suite run for 100 iterations,
>> there were no issues.
>>
>> I cut down reproducer and removed last mmap/write/munmap as that is enough
>> to reproduce the problem. Then I started introducing some traces into kernel
>> and noticed that on ppc I get 3 faults, while on x86 I get only 2.
>>
>> Interesting is the 2nd fault, that is first write after mapping as PRIVATE.
>> Following condition fails on ppc first time:
>>     if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
>> but it's immediately followed by fault that looks identical
>> and in that one it evaluates as true.
> 
> ok, we miss the _PAGE_PTE in new_pte there. 
> 
> 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
> 				&& (vma->vm_flags & VM_SHARED)));
> 	set_huge_pte_at(mm, address, ptep, new_pte);
> 
> 	hugetlb_count_add(pages_per_huge_page(h), mm);
> 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
> 		/* Optimization, do the COW without a second fault */
> 		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page, ptl);
> 	}
> 
> IMHO that new_pte usage is wrong, because we don't consider flags that
> can possibly be added by set_huge_pte_at there. For pp64 we add _PAGE_PTE 
> 

Thanks for looking at this Aneesh.

>>
>> Same with alloc_huge_page(), on x86_64 it's called twice, on ppc three times.
>> In 2nd call vma_needs_reservation() returns 0, in 3rd it returns 1.
>>
>> ---- ppc -> 2nd and 3rd fault ---
>> mmap(MAP_PRIVATE)
>> hugetlb_fault address: 3effff000000, flags: 55
>> hugetlb_cow old_page: f0000000010fc000
>> alloc_huge_page ret: f000000001100000
>> hugetlb_cow ptep: c000000455b27cf8, pte_same: 0
>> free_huge_page page: f000000001100000, restore_reserve: 1

So, the interesting thing is that since we do not take the optimized path
there is an additional fault.  It looks like the additional fault results
in the originally allocated page being free'ed and reserve count being
incremented.  As mentioned in the description of commit 67961f9db8c4, the
VMA private reserve map will still contain an entry for the page.
Therefore,
when a page allocation happens as the result of the next fault, it will
think the reserved page has already been consumed and not use it.  This is
how we are 'leaking' reserved pages.

>> hugetlb_fault address: 3effff000000, flags: 55
>> hugetlb_cow old_page: f0000000010fc000
>> alloc_huge_page ret: f000000001100000
>> hugetlb_cow ptep: c000000455b27cf8, pte_same: 1
>>
>> --- x86_64 -> 2nd fault ---
>> mmap(MAP_PRIVATE)
>> hugetlb_fault address: 7f71a4200000, flags: 55
>> hugetlb_cow address 0x7f71a4200000, old_page: ffffea0008d20000
>> alloc_huge_page ret: ffffea0008d38000
>> hugetlb_cow ptep: ffff8802314c7908, pte_same: 1
>>
> 
> But I guess we still have issue with respecting reservation here.
> 
> I will look at _PAGE_PTE and see what best we can do w.r.t hugetlb.
> 
> -aneesh

If there was not the additional fault, we would not perform the additional
free and alloc and not see this issue.  However, the logic in 67961f9db8c4
also missed this error case (and I think any time we do not take the
optimized
code path).

I suspect it is would be desirable to fix the code path for Power such that
it does not do the additional fault (free/alloc).  I'll take a look at the
code for commit for 67961f9db8c4.  It certainly misses the error case, and
seems 'too fragile' to depend on the optimized code paths.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
