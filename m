Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9876B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:53:41 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so48111618obc.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 16:53:41 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x6si6434956obg.3.2015.03.16.16.53.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 16:53:40 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V2 0/4]  hugetlbfs: add min_size filesystem mount option
Date: Mon, 16 Mar 2015 16:53:25 -0700
Message-Id: <cover.1426549010.git.mike.kravetz@oracle.com>
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
Before starting, the application can check to make sure that enough huge
pages exist in the system global pools.  However, there are no guarantees
that those pages will be available when needed by the application.  What
the application wants is exclusive use of a subset of huge pages.

Add a new hugetlbfs mount option 'min_size=<value>' to indicate that
the specified number of pages will be available for use by the filesystem.
At mount time, this number of huge pages will be reserved for exclusive
use of the filesystem.  If there is not a sufficient number of free pages,
the mount will fail.  As pages are allocated to and freeed from the
filesystem, the number of reserved pages is adjusted so that the specified
minimum is maintained.

V2:
  Added ability to specify minimum size. (David Rientjes)
V1:
  Comments from RFC addressed/incorporated

Mike Kravetz (4):
  hugetlbfs: add minimum size tracking fields to subpool structure
  hugetlbfs: add minimum size accounting to subpools
  hugetlbfs: accept subpool min_size mount option and setup accordingly
  hugetlbfs: document min_size mount option

 Documentation/vm/hugetlbpage.txt |  21 ++++--
 fs/hugetlbfs/inode.c             |  75 ++++++++++++++++-----
 include/linux/hugetlb.h          |   5 +-
 mm/hugetlb.c                     | 138 ++++++++++++++++++++++++++++++++-------
 4 files changed, 190 insertions(+), 49 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
