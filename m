Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83C588E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 01:46:53 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k18-v6so11803802otl.16
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 22:46:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n15-v6si771461otb.212.2018.09.29.22.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 22:46:52 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8U5hbkK096829
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 01:46:51 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mtpc036x6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 01:46:51 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <daniel@linux.ibm.com>;
	Sun, 30 Sep 2018 06:46:49 +0100
From: Daniel Black <daniel@linux.ibm.com>
Subject: [PATCH] mm: madvise(MADV_DODUMP) allow hugetlbfs pages
Date: Sun, 30 Sep 2018 15:46:29 +1000
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20180930054629.29150-1-daniel@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mike.kravetz@oracle.com, khlebnikov@openvz.org
Cc: Daniel Black <daniel@linux.ibm.com>

Reproducer, assuming 2M of hugetlbfs available:

Hugetlbfs mounted, size=2M and option user=testuser

  # mount | grep ^hugetlbfs
  hugetlbfs on /dev/hugepages type hugetlbfs (rw,pagesize=2M,user=dan)
  # sysctl vm.nr_hugepages=1
  vm.nr_hugepages = 1
  # grep Huge /proc/meminfo
  AnonHugePages:         0 kB
  ShmemHugePages:        0 kB
  HugePages_Total:       1
  HugePages_Free:        1
  HugePages_Rsvd:        0
  HugePages_Surp:        0
  Hugepagesize:       2048 kB
  Hugetlb:            2048 kB

Code:

  #include <sys/mman.h>
  #include <stddef.h>
  #define SIZE 2*1024*1024
  int main()
  {
    void *ptr;
    ptr = mmap(NULL, SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_HUGETLB | MAP_ANONYMOUS, -1, 0);
    madvise(ptr, SIZE, MADV_DONTDUMP);
    madvise(ptr, SIZE, MADV_DODUMP);
  }

Compile and strace:

  mmap(NULL, 2097152, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_HUGETLB, -1, 0) = 0x7ff7c9200000
  madvise(0x7ff7c9200000, 2097152, MADV_DONTDUMP) = 0
  madvise(0x7ff7c9200000, 2097152, MADV_DODUMP) = -1 EINVAL (Invalid argument)

hugetlbfs pages have VM_DONTEXPAND in the VmFlags driver pages based on
author testing with analysis from Florian Weimer[1].

The inclusion of VM_DONTEXPAND into the VM_SPECIAL defination
was a consequence of the large useage of VM_DONTEXPAND in device
drivers.

A consequence of [2] is that VM_DONTEXPAND marked pages are unable to be
marked DODUMP.

A user could quite legitimately madvise(MADV_DONTDUMP) their hugetlbfs
memory for a while and later request that madvise(MADV_DODUMP) on the
same memory. We correct this omission by allowing madvice(MADV_DODUMP)
on hugetlbfs pages.

[1] https://stackoverflow.com/questions/52548260/madvisedodump-on-the-same-ptr-size-as-a-successful-madvisedontdump-fails-wit
[2] commit 0103bd16fb90 ("mm: prepare VM_DONTDUMP for using in drivers")

Fixes: 0103bd16fb90 ("mm: prepare VM_DONTDUMP for using in drivers")
Reported-by: Kenneth Penza <kpenza@gmail.com>
Signed-off-by: Daniel Black <daniel@linux.ibm.com>
Buglink: https://lists.launchpad.net/maria-discuss/msg05245.html
Cc: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 972a9eaa898b..71d21df2a3f3 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -96,7 +96,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 		new_flags |= VM_DONTDUMP;
 		break;
 	case MADV_DODUMP:
-		if (new_flags & VM_SPECIAL) {
+		if (!is_vm_hugetlb_page(vma) && new_flags & VM_SPECIAL) {
 			error = -EINVAL;
 			goto out;
 		}
-- 
2.19.0
