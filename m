Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id l431TbAC021245
	for <linux-mm@kvack.org>; Thu, 3 May 2007 02:29:37 +0100
Received: from an-out-0708.google.com (anab36.prod.google.com [10.100.53.36])
	by spaceape13.eur.corp.google.com with ESMTP id l431TFVs018102
	for <linux-mm@kvack.org>; Thu, 3 May 2007 02:29:31 +0100
Received: by an-out-0708.google.com with SMTP id b36so347865ana
        for <linux-mm@kvack.org>; Wed, 02 May 2007 18:29:30 -0700 (PDT)
Message-ID: <b040c32a0705021829o3139497eyd76f97f59827389b@mail.gmail.com>
Date: Wed, 2 May 2007 18:29:30 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] fix leaky resv_huge_pages when cpuset is in use
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

The internal hugetlb resv_huge_pages variable can permanently leak
nonzero value in the error path of hugetlb page fault handler when
hugetlb page is used in combination of cpuset.  The leaked count can
permanently trap N number of hugetlb pages in unusable "reserved"
state.

Steps to reproduce the bug:

  (1) create two cpuset, user1 and user2
  (2) reserve 50 htlb pages in cpuset user1
  (3) attempt to shmget/shmat 50 htlb page inside cpuset user2
  (4) kernel oom the user process in step 3
  (5) ipcrm the shm segment

At this point resv_huge_pages will have a count of 49, even though
there are no active hugetlbfs file nor hugetlb shared memory segment
in the system.  The leak is permanent and there is no recovery method
other than system reboot. The leaked count will hold up all future use
of that many htlb pages in all cpusets.

The culprit is that the error path of alloc_huge_page() did not
properly undo the change it made to resv_huge_page, causing
inconsistent state.


Signed-off-by: Ken Chen <kenchen@google.com>


--- ./mm/hugetlb.c.orig	2007-05-02 18:12:36.000000000 -0700
+++ ./mm/hugetlb.c	2007-05-02 18:15:45.000000000 -0700
@@ -140,6 +140,8 @@ static struct page *alloc_huge_page(stru
 	return page;

 fail:
+	if (vma->vm_flags & VM_MAYSHARE)
+		resv_huge_pages++;
 	spin_unlock(&hugetlb_lock);
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
