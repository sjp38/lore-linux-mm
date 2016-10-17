Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0EC6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:05:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r16so183629128pfg.4
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 22:05:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ih4si24296368pab.37.2016.10.16.22.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 22:05:12 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9H543PH036453
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:05:12 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 264c330fe5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:05:11 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 16 Oct 2016 23:05:11 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs eventually kill my system
In-Reply-To: <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com>
References: <57FF7BB4.1070202@redhat.com> <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com> <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com> <58009BE2.5010805@redhat.com> <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com>
Date: Mon, 17 Oct 2016 10:34:59 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87h98btvk4.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 10/14/2016 01:48 AM, Jan Stancek wrote:
>> On 10/14/2016 01:26 AM, Mike Kravetz wrote:
>>>
>>> Hi Jan,
>>>
>>> Any chance you can get the contents of /sys/kernel/mm/hugepages
>>> before and after the first run of libhugetlbfs testsuite on Power?
>>> Perhaps a script like:
>>>
>>> cd /sys/kernel/mm/hugepages
>>> for f in hugepages-*/*; do
>>> 	n=`cat $f`;
>>> 	echo -e "$n\t$f";
>>> done
>>>
>>> Just want to make sure the numbers look as they should.
>>>
>> 
>> Hi Mike,
>> 
>> Numbers are below. I have also isolated a single testcase from "func"
>> group of tests: corrupt-by-cow-opt [1]. This test stops working if I
>> run it 19 times (with 20 hugepages). And if I disable this test,
>> "func" group tests can all pass repeatedly.
>
> Thanks Jan,
>
> I appreciate your efforts.
>
>> 
>> [1] https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/corrupt-by-cow-opt.c
>> 
>> Regards,
>> Jan
>> 
>> Kernel is v4.8-14230-gb67be92, with reboot between each run.
>> 1) Only func tests
>> System boot
>> After setup:
>> 20      hugepages-16384kB/free_hugepages
>> 20      hugepages-16384kB/nr_hugepages
>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 0       hugepages-16384kB/resv_hugepages
>> 0       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>> 
>> After func tests:
>> ********** TEST SUMMARY
>> *                      16M
>> *                      32-bit 64-bit
>> *     Total testcases:     0     85
>> *             Skipped:     0      0
>> *                PASS:     0     81
>> *                FAIL:     0      4
>> *    Killed by signal:     0      0
>> *   Bad configuration:     0      0
>> *       Expected FAIL:     0      0
>> *     Unexpected PASS:     0      0
>> * Strange test result:     0      0
>> 
>> 26      hugepages-16384kB/free_hugepages
>> 26      hugepages-16384kB/nr_hugepages
>> 26      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 1       hugepages-16384kB/resv_hugepages
>> 0       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>> 
>> After test cleanup:
>>  umount -a -t hugetlbfs
>>  hugeadm --pool-pages-max ${HPSIZE}:0
>> 
>> 1       hugepages-16384kB/free_hugepages
>> 1       hugepages-16384kB/nr_hugepages
>> 1       hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 1       hugepages-16384kB/resv_hugepages
>> 1       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>> 
>
> I am guessing the leaked reserve page is which is triggered by
> running the test you isolated corrupt-by-cow-opt.
>
>
>> ---
>> 
>> 2) Only stress tests
>> System boot
>> After setup:
>> 20      hugepages-16384kB/free_hugepages
>> 20      hugepages-16384kB/nr_hugepages
>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 0       hugepages-16384kB/resv_hugepages
>> 0       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>> 
>> After stress tests:
>> 20      hugepages-16384kB/free_hugepages
>> 20      hugepages-16384kB/nr_hugepages
>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 17      hugepages-16384kB/resv_hugepages
>> 0       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>> 
>> After cleanup:
>> 17      hugepages-16384kB/free_hugepages
>> 17      hugepages-16384kB/nr_hugepages
>> 17      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 17      hugepages-16384kB/resv_hugepages
>> 17      hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>> 
>
> This looks worse than the summary after running the functional tests.
>
>> ---
>> 
>> 3) only corrupt-by-cow-opt
>> 
>> System boot
>> After setup:
>> 20      hugepages-16384kB/free_hugepages
>> 20      hugepages-16384kB/nr_hugepages
>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 0       hugepages-16384kB/resv_hugepages
>> 0       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>> 
>> libhugetlbfs-2.18# env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
>> Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3298
>> Write s to 0x3effff000000 via shared mapping
>> Write p to 0x3effff000000 via private mapping
>> Read s from 0x3effff000000 via shared mapping
>> PASS
>> 20      hugepages-16384kB/free_hugepages
>> 20      hugepages-16384kB/nr_hugepages
>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 1       hugepages-16384kB/resv_hugepages
>> 0       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
>
> Leaked one reserve page
>
>> 
>> # env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
>> Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3312
>> Write s to 0x3effff000000 via shared mapping
>> Write p to 0x3effff000000 via private mapping
>> Read s from 0x3effff000000 via shared mapping
>> PASS
>> 20      hugepages-16384kB/free_hugepages
>> 20      hugepages-16384kB/nr_hugepages
>> 20      hugepages-16384kB/nr_hugepages_mempolicy
>> 0       hugepages-16384kB/nr_overcommit_hugepages
>> 2       hugepages-16384kB/resv_hugepages
>> 0       hugepages-16384kB/surplus_hugepages
>> 0       hugepages-16777216kB/free_hugepages
>> 0       hugepages-16777216kB/nr_hugepages
>> 0       hugepages-16777216kB/nr_hugepages_mempolicy
>> 0       hugepages-16777216kB/nr_overcommit_hugepages
>> 0       hugepages-16777216kB/resv_hugepages
>> 0       hugepages-16777216kB/surplus_hugepages
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

looking at that commit, I am not sure region_chg output indicate a hole
punched. ie, w.r.t private mapping when we mmap, we don't do a
region_chg (hugetlb_reserve_page()). So with a fault later when we
call vma_needs_reservation, we will find region_chg returning >= 0 right ?

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

Not sure how any of this is arch specific. So on both x86 and sparc we
don't find the count going wrong as above ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
