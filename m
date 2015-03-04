Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 732BC6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:22:08 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so21774652pdb.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 17:22:08 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ck3si2948920pbc.156.2015.03.03.17.22.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 17:22:07 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/4] hugetlbfs: optionally reserve all fs pages at mount time
Date: Tue,  3 Mar 2015 17:21:42 -0800
Message-Id: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

hugetlbfs allocates huge pages from the global pool as needed.  Even if
the global pool contains a sufficient number pages for the filesystem
size at mount time, those global pages could be grabbed for some other
use.  As a result, filesystem huge page allocations may fail due to lack
of pages.

Applications such as a database want to use huge pages for performance
reasons.  hugetlbfs filesystem semantics with ownership and modes work
well to manage access to a pool of huge pages.  However, the application
would like some reasonable assurance that allocations will not fail due
to a lack of huge pages.  At application startup time, the application
would like to configure itself to use a specific number of huge pages.
Before starting, the application will can check to make sure that enough
huge pages exist in the system global pools.  What the application wants
is exclusive use of a subpool of huge pages. 

Add a new hugetlbfs mount option 'reserved' to specify that the number
of pages associated with the size of the filesystem will be reserved.  If
there are insufficient pages, the mount will fail.  The reservation is
maintained for the duration of the filesystem so that as pages are
allocated and free'ed a sufficient number of pages remains reserved.

Comments from RFC addressed/incorporated

Mike Kravetz (4):
  hugetlbfs: add reserved mount fields to subpool structure
  hugetlbfs: coordinate global and subpool reserve accounting
  hugetlbfs: accept subpool reserved option and setup accordingly
  hugetlbfs: document reserved mount option

 Documentation/vm/hugetlbpage.txt | 18 ++++++++------
 fs/hugetlbfs/inode.c             | 15 ++++++++++--
 include/linux/hugetlb.h          |  7 ++++++
 mm/hugetlb.c                     | 53 +++++++++++++++++++++++++++++++++-------
 4 files changed, 75 insertions(+), 18 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
