Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 993726B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 16:47:54 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so118887544pdb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:47:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p5si11525189par.19.2015.03.20.13.47.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 13:47:53 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V3 0/4] hugetlbfs: add min_size filesystem mount option
Date: Fri, 20 Mar 2015 13:47:06 -0700
Message-Id: <cover.1426880499.git.mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <andi@firstfloor.org>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>

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

V3:
  Struct init and comment cleanup as suggested by Andrew Morton
  Cleaned up size option argument parsing to hopefully be more clear
  Fixed kbuild warning introduced in V2
  Made documentation more explicit and added descriptions for 'existing'
  pagesize options and ability to specify size as a percent
V2:
  Added ability to specify minimum size. Suggsted by David Rientjes
V1:
  Comments from RFC addressed/incorporated

Mike Kravetz (4):
  hugetlbfs: add minimum size tracking fields to subpool structure
  hugetlbfs: add minimum size accounting to subpools
  hugetlbfs: accept subpool min_size mount option and setup accordingly
  hugetlbfs: document min_size mount option and cleanup

 Documentation/vm/hugetlbpage.txt |  31 +++++---
 fs/hugetlbfs/inode.c             |  90 ++++++++++++++++++-----
 include/linux/hugetlb.h          |  11 ++-
 mm/hugetlb.c                     | 151 +++++++++++++++++++++++++++++++--------
 4 files changed, 224 insertions(+), 59 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
