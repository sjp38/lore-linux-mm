Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 097756B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 18:54:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ry6so215562018pac.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 15:54:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u79si32563970pfg.5.2016.10.17.15.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 15:54:04 -0700 (PDT)
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
References: <57FF7BB4.1070202@redhat.com>
 <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com>
 <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com>
 <58009BE2.5010805@redhat.com>
 <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com>
 <87h98btvk4.fsf@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f8821116-dfe2-4c47-2add-c6e18f2e9fa6@oracle.com>
Date: Mon, 17 Oct 2016 15:53:52 -0700
MIME-Version: 1.0
In-Reply-To: <87h98btvk4.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com

On 10/16/2016 10:04 PM, Aneesh Kumar K.V wrote:
> Mike Kravetz <mike.kravetz@oracle.com> writes:
> 
>> On 10/14/2016 01:48 AM, Jan Stancek wrote:
>>> On 10/14/2016 01:26 AM, Mike Kravetz wrote:
>>>>
>>>> Hi Jan,
>>>>
>>>> Any chance you can get the contents of /sys/kernel/mm/hugepages
>>>> before and after the first run of libhugetlbfs testsuite on Power?
>>>> Perhaps a script like:
>>>>
>>>> cd /sys/kernel/mm/hugepages
>>>> for f in hugepages-*/*; do
>>>> 	n=`cat $f`;
>>>> 	echo -e "$n\t$f";
>>>> done
>>>>
>>>> Just want to make sure the numbers look as they should.
>>>>
>>>
>>> Hi Mike,
>>>
>>> Numbers are below. I have also isolated a single testcase from "func"
>>> group of tests: corrupt-by-cow-opt [1]. This test stops working if I
>>> run it 19 times (with 20 hugepages). And if I disable this test,
>>> "func" group tests can all pass repeatedly.
>>
>> Thanks Jan,
>>
>> I appreciate your efforts.
>>
>>>
>>> [1] https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/corrupt-by-cow-opt.c
>>>
>>> Regards,
>>> Jan
>>>
>>> Kernel is v4.8-14230-gb67be92, with reboot between each run.
>>> 1) Only func tests
>>> System boot
>>> After setup:
>>> 20      hugepages-16384kB/free_hugepages
>>> 20      hugepages-16384kB/nr_hugepages
>>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 0       hugepages-16384kB/resv_hugepages
>>> 0       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>>
>>> After func tests:
>>> ********** TEST SUMMARY
>>> *                      16M
>>> *                      32-bit 64-bit
>>> *     Total testcases:     0     85
>>> *             Skipped:     0      0
>>> *                PASS:     0     81
>>> *                FAIL:     0      4
>>> *    Killed by signal:     0      0
>>> *   Bad configuration:     0      0
>>> *       Expected FAIL:     0      0
>>> *     Unexpected PASS:     0      0
>>> * Strange test result:     0      0
>>>
>>> 26      hugepages-16384kB/free_hugepages
>>> 26      hugepages-16384kB/nr_hugepages
>>> 26      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 1       hugepages-16384kB/resv_hugepages
>>> 0       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>>
>>> After test cleanup:
>>>  umount -a -t hugetlbfs
>>>  hugeadm --pool-pages-max ${HPSIZE}:0
>>>
>>> 1       hugepages-16384kB/free_hugepages
>>> 1       hugepages-16384kB/nr_hugepages
>>> 1       hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 1       hugepages-16384kB/resv_hugepages
>>> 1       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>>
>>
>> I am guessing the leaked reserve page is which is triggered by
>> running the test you isolated corrupt-by-cow-opt.
>>
>>
>>> ---
>>>
>>> 2) Only stress tests
>>> System boot
>>> After setup:
>>> 20      hugepages-16384kB/free_hugepages
>>> 20      hugepages-16384kB/nr_hugepages
>>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 0       hugepages-16384kB/resv_hugepages
>>> 0       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>>
>>> After stress tests:
>>> 20      hugepages-16384kB/free_hugepages
>>> 20      hugepages-16384kB/nr_hugepages
>>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 17      hugepages-16384kB/resv_hugepages
>>> 0       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>>
>>> After cleanup:
>>> 17      hugepages-16384kB/free_hugepages
>>> 17      hugepages-16384kB/nr_hugepages
>>> 17      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 17      hugepages-16384kB/resv_hugepages
>>> 17      hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>>
>>
>> This looks worse than the summary after running the functional tests.
>>
>>> ---
>>>
>>> 3) only corrupt-by-cow-opt
>>>
>>> System boot
>>> After setup:
>>> 20      hugepages-16384kB/free_hugepages
>>> 20      hugepages-16384kB/nr_hugepages
>>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 0       hugepages-16384kB/resv_hugepages
>>> 0       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>>
>>> libhugetlbfs-2.18# env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
>>> Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3298
>>> Write s to 0x3effff000000 via shared mapping
>>> Write p to 0x3effff000000 via private mapping
>>> Read s from 0x3effff000000 via shared mapping
>>> PASS
>>> 20      hugepages-16384kB/free_hugepages
>>> 20      hugepages-16384kB/nr_hugepages
>>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 1       hugepages-16384kB/resv_hugepages
>>> 0       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>
>> Leaked one reserve page
>>
>>>
>>> # env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
>>> Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3312
>>> Write s to 0x3effff000000 via shared mapping
>>> Write p to 0x3effff000000 via private mapping
>>> Read s from 0x3effff000000 via shared mapping
>>> PASS
>>> 20      hugepages-16384kB/free_hugepages
>>> 20      hugepages-16384kB/nr_hugepages
>>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>>> 0       hugepages-16384kB/nr_overcommit_hugepages
>>> 2       hugepages-16384kB/resv_hugepages
>>> 0       hugepages-16384kB/surplus_hugepages
>>> 0       hugepages-16777216kB/free_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages
>>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>>> 0       hugepages-16777216kB/resv_hugepages
>>> 0       hugepages-16777216kB/surplus_hugepages
>>
>> It is pretty consistent that we leak a reserve page every time this
>> test is run.
>>
>> The interesting thing is that corrupt-by-cow-opt is a very simple
>> test case.  commit 67961f9db8c4 potentially changes the return value
>> of the functions vma_has_reserves() and vma_needs/commit_reservation()
>> for the owner (HPAGE_RESV_OWNER) of private mappings.  running the
>> test with and without the commit results in the same return values for
>> these routines on x86.  And, no leaked reserve pages.
> 
> looking at that commit, I am not sure region_chg output indicate a hole
> punched. ie, w.r.t private mapping when we mmap, we don't do a
> region_chg (hugetlb_reserve_page()). So with a fault later when we
> call vma_needs_reservation, we will find region_chg returning >= 0 right ?
> 

Let me try to explain.

When a private mapping is created, hugetlb_reserve_pages to reserve
huge pages for the mapping.  A reserve map is created and installed
in the (vma_private) VMA.  No reservation entries are actually created
for the mapping.  But, hugetlb_acct_memory() is called to reserve
pages for the mapping in the global pool.  This will adjust (increment)
the global reserved huge page counter (resv_huge_pages).

As pages within the private mapping are faulted in, huge_page_alloc() is
called to allocate the pages.  Within alloc_huge_page, vma_needs_reservation
is called to determine if there is a reservation for this allocation.
If there is a reservation, the global count is adjusted (decremented).
In any case where a page is returned to the caller, vma_commit_reservation
is called and an entry for the page is created in the reserve map (VMA
vma_private) of the mapping.

Once a page is instantiated within the private mapping, an entry exists
in the reserve map and the reserve count has been adjusted to indicate
that the reserve has been consumed.  Subsequent faults will not instantiate
a new page unless the original is somehow removed from the mapping.  The
only way a user can remove a page from the mapping is via a hole punch or
truncate operation.  Note that hole punch and truncate for huge pages
only to apply to hugetlbfs backed mappings and not anonymous mappings.

hole punch and truncate will unmap huge pages from any private private
mapping associated with the same offset in the hugetlbfs file.  However,
they will not remove entries from the VMA private_data reserve maps.
Nor, will they adjust global reserve counts based on private mappings.

Now suppose a subsequent fault happened for a page private mapping removed
via hole punch or truncate.  Prior to commit 67961f9db8c4,
vma_needs_reservation ALWAYS returned false to indicate that a reservation
existed for the page.  So, alloc_huge_page would consume a reserved page.
The problem is that the reservation was consumed at the time of the first
fault and no longer exist.  This caused the global reserve count to be
incorrect.

Commit 67961f9db8c4 looks at the VMA private reserve map to determine if
the original reservation was consumed.  If an entry exists in the map, it
is assumed the reservation was consumed and no longer exists.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
