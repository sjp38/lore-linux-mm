Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 467216B0071
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 16:48:22 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so119645605pac.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:48:22 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fe5si11515967pdb.39.2015.03.20.13.48.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 13:48:21 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V3 4/4] hugetlbfs: document min_size mount option and cleanup
Date: Fri, 20 Mar 2015 13:47:10 -0700
Message-Id: <0a9330b14a050bdf8ebb9c02722e9bbdd13eaa3f.1426880500.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426880499.git.mike.kravetz@oracle.com>
References: <cover.1426880499.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426880499.git.mike.kravetz@oracle.com>
References: <cover.1426880499.git.mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <andi@firstfloor.org>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>

Add min_size mount option to the hugetlbfs documentation.  Also,
add the missing pagesize option and mention that size can be
specified as bytes or a percentage of huge page pool.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 Documentation/vm/hugetlbpage.txt | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index f2d3a10..b32b9cd 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -267,21 +267,34 @@ call, then it is required that system administrator mount a file system of
 type hugetlbfs:
 
   mount -t hugetlbfs \
-	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,nr_inodes=<value> \
-	none /mnt/huge
+	-o uid=<value>,gid=<value>,mode=<value>,pagesize=<value>,size=<value>,\
+	min_size=<value>,nr_inodes=<value> none /mnt/huge
 
 This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
 /mnt/huge.  Any files created on /mnt/huge uses huge pages.  The uid and gid
 options sets the owner and group of the root of the file system.  By default
 the uid and gid of the current process are taken.  The mode option sets the
 mode of root of file system to value & 01777.  This value is given in octal.
-By default the value 0755 is picked. The size option sets the maximum value of
-memory (huge pages) allowed for that filesystem (/mnt/huge). The size is
-rounded down to HPAGE_SIZE.  The option nr_inodes sets the maximum number of
-inodes that /mnt/huge can use.  If the size or nr_inodes option is not
-provided on command line then no limits are set.  For size and nr_inodes
-options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For
-example, size=2K has the same meaning as size=2048.
+By default the value 0755 is picked. If the paltform supports multiple huge
+page sizes, the pagesize option can be used to specify the huge page size and
+associated pool.  pagesize is specified in bytes.  If pagesize is not specified
+the paltform's default huge page size and associated pool will be used. The
+size option sets the maximum value of memory (huge pages) allowed for that
+filesystem (/mnt/huge).  The size option can be specified in bytes, or as a
+percentage of the specified huge page pool (nr_hugepages).  The size is
+rounded down to HPAGE_SIZE boundary.  The min_size option sets the minimum
+value of memory (huge pages) allowed for the filesystem.  min_size can be
+specified in the same way as size, either bytes or a percentage of the
+huge page pool.  At mount time, the number of huge pages specified by
+min_size are reserved for use by the filesystem.  If there are not enough
+free huge pages available, the mount will fail.  As huge pages are allocated
+to the filesystem and freed, the reserve count is adjusted so that the sum
+of allocated and reserved huge pages is always at least min_size.  The option
+nr_inodes sets the maximum number of inodes that /mnt/huge can use.  If the
+size, min_size or nr_inodes option is not provided on command line then
+no limits are set.  For pagesize, size, min_size and nr_inodes options, you
+can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For example, size=2K
+has the same meaning as size=2048.
 
 While read system calls are supported on files that reside on hugetlb
 file systems, write system calls are not.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
