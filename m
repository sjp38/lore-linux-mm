Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2H5DCrh002801
	for <linux-mm@kvack.org>; Sat, 17 Mar 2007 01:13:12 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2H5DCW9038400
	for <linux-mm@kvack.org>; Fri, 16 Mar 2007 23:13:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2H5DBlu010038
	for <linux-mm@kvack.org>; Fri, 16 Mar 2007 23:13:12 -0600
Date: Fri, 16 Mar 2007 22:13:09 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: FADV_DONTNEED on hugetlbfs files broken
Message-ID: <20070317051308.GA5522@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kenchen@google.com
Cc: linux-mm@kvack.org, agl@us.ibm.com, dwg@au1.ibm.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Hi Ken,

git commit 6649a3863232eb2e2f15ea6c622bd8ceacf96d76 "[PATCH] hugetlb:
preserve hugetlb pte dirty state" fixed one bug and caused another (or,
at least, a regression): FADV_DONTNEED no longer works on hugetlbfs
files. git-bisect revealed this commit to be the cause. I'm still trying
to figure out what the solution is (but it is also the start of the
weekend :) Maybe it's not a bug, but it is a change in behavior, and I
don't think it was clear from the commit message.

Thanks,
Nish

---

Background:

I found this while trying to add some code to libhugetlbfs to minimize
the number of hugepages used by the segment remapping code
(git://ozlabs.org/~dgibson/git/libhugetlbfs.git).  The general sequence
of code is:

1) Map hugepage-backed file in, MAP_SHARED.
2) Copy smallpage-backed segment data into hugepage-backed file.
3) Unmap hugepage-backed file.
4) Unmap smallpage-backed segment.
5) Map hugepage-backed file in its place, MAP_PRIVATE.

(From what I understand, step 5) will take advantage of the fact that
the mapping from step 1) is still in the page cache and thus not
actually use any more huge pages)

Now, if this segment is writable, we are going to take a COW fault on
the PRIVATE mapping at some point (most likely) and then have twice as
many hugepages in use as need to be. So, I added some code to the
remapping to add two more steps:

6) If the segment is writable, for each hugepage in the hugepage-backed
file, force a COW.
7) Invoke posix_fadvise(fd, 0, 0, FADV_DONTNEED) on the hugepage-backed
file to drop the SHARED mapping out of the page cache.

Now, the problem I'm seeing on a very dummy program, test.c:

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

int array[8*1024*1024];

int main() {
	getchar();
	return 0;
}

relinked with libhugetlbfs

gcc -o test -B/path/to/ld/symlinked/to/ld.hugetlbfs -Wl,--hugetlbfs-link=BDT -L/path/to/libhugetlbfs.so

resulted in different behavior with 2.6.19 and 2.6.21-rc4 (on an x86_64
and on a powerpc):

2.6.19: Start out using 2 hugepages (one for each segment), the COW
causes us to go to 3 hugepages, and the fadvise drops us back down to 2
pages.

2.6.21-rc4: Start out using 2 hugepages, the COW causes us to go to 3
hugepages, and the fadvise has no effect.

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
