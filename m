Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9627C6B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 04:48:40 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f6so74107608qtd.4
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 01:48:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b124si9055490qkd.125.2016.10.14.01.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 01:48:39 -0700 (PDT)
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
References: <57FF7BB4.1070202@redhat.com>
 <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com>
 <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com>
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <58009BE2.5010805@redhat.com>
Date: Fri, 14 Oct 2016 10:48:34 +0200
MIME-Version: 1.0
In-Reply-To: <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com

On 10/14/2016 01:26 AM, Mike Kravetz wrote:
> 
> Hi Jan,
> 
> Any chance you can get the contents of /sys/kernel/mm/hugepages
> before and after the first run of libhugetlbfs testsuite on Power?
> Perhaps a script like:
> 
> cd /sys/kernel/mm/hugepages
> for f in hugepages-*/*; do
> 	n=`cat $f`;
> 	echo -e "$n\t$f";
> done
> 
> Just want to make sure the numbers look as they should.
> 

Hi Mike,

Numbers are below. I have also isolated a single testcase from "func"
group of tests: corrupt-by-cow-opt [1]. This test stops working if I
run it 19 times (with 20 hugepages). And if I disable this test,
"func" group tests can all pass repeatedly.

[1] https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/corrupt-by-cow-opt.c

Regards,
Jan

Kernel is v4.8-14230-gb67be92, with reboot between each run.
1) Only func tests
System boot
After setup:
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
0       hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

After func tests:
********** TEST SUMMARY
*                      16M
*                      32-bit 64-bit
*     Total testcases:     0     85
*             Skipped:     0      0
*                PASS:     0     81
*                FAIL:     0      4
*    Killed by signal:     0      0
*   Bad configuration:     0      0
*       Expected FAIL:     0      0
*     Unexpected PASS:     0      0
* Strange test result:     0      0

26      hugepages-16384kB/free_hugepages
26      hugepages-16384kB/nr_hugepages
26      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
1       hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

After test cleanup:
 umount -a -t hugetlbfs
 hugeadm --pool-pages-max ${HPSIZE}:0

1       hugepages-16384kB/free_hugepages
1       hugepages-16384kB/nr_hugepages
1       hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
1       hugepages-16384kB/resv_hugepages
1       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

---

2) Only stress tests
System boot
After setup:
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
0       hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

After stress tests:
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
17      hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

After cleanup:
17      hugepages-16384kB/free_hugepages
17      hugepages-16384kB/nr_hugepages
17      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
17      hugepages-16384kB/resv_hugepages
17      hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

---

3) only corrupt-by-cow-opt

System boot
After setup:
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
0       hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

libhugetlbfs-2.18# env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3298
Write s to 0x3effff000000 via shared mapping
Write p to 0x3effff000000 via private mapping
Read s from 0x3effff000000 via shared mapping
PASS
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
1       hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

# env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3312
Write s to 0x3effff000000 via shared mapping
Write p to 0x3effff000000 via private mapping
Read s from 0x3effff000000 via shared mapping
PASS
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
2       hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

(... output cut from ~17 iterations ...)

# env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3686
Write s to 0x3effff000000 via shared mapping
Bus error
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
19      hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

# env LD_LIBRARY_PATH=./obj64 ./tests/obj64/corrupt-by-cow-opt; /root/grab.sh
Starting testcase "./tests/obj64/corrupt-by-cow-opt", pid 3700
Write s to 0x3effff000000 via shared mapping
FAIL    mmap() 2: Cannot allocate memory
20      hugepages-16384kB/free_hugepages
20      hugepages-16384kB/nr_hugepages
20      hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
19      hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
