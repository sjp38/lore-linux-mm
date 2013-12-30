Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F368A6B0037
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 08:45:59 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so11548466pab.6
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 05:45:59 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id ya10si33602560pab.95.2013.12.30.05.45.56
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 05:45:57 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 0/3] Fadvise: Directory level page cache cleaning support
Date: Mon, 30 Dec 2013 21:45:15 +0800
Message-Id: <cover.1388409686.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>, Li Wang <liwang@ubuntukylin.com>

VFS relies on LRU-like page cache eviction algorithm
to reclaim cache space, such general and simple algorithm 
is good regarding its application independence, and is working 
for normal situations. However, sometimes it does not help much
for those applications which are performance sensitive or under 
heavy loads. Since LRU may incorrectly evict going-to-be referenced 
pages out, resulting in severe performance degradation due to 
cache thrashing. Applications have the most knowledge
about the things they are doing, they can always do better if
they are given a chance. This motivates to endow the applications 
more abilities to manipulate the page cache.

Currently, Linux support file system wide cache cleaing by virtue of
proc interface 'drop-caches', but it is very coarse granularity and
was originally proposed for debugging. The other is to do file-level
page cache cleaning through 'fadvise', however, this is sometimes less 
flexible and not easy to use especially in directory wide operations or 
under massive small-file situations.

This patch extends 'fadvise' to support directory level page cache
cleaning. The call to posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) 
with 'fd' referring to a directory will recursively reclaim page cache 
entries of files inside 'fd'. For secruity concern, those inodes
which the caller does not own appropriate permissions will not 
be manipulated.

It is easy to demonstrate the advantages of directory level page 
cache cleaning. We use a machine with a Pentium(R) Dual-Core CPU 
E5800 @ 3.20GHz, and with 2GB memory. Two directories named '1' 
and '3' are created, with each containing X (360 - 460) files, 
and each file with a size of 2MB. The test scripts are as follows,

The test scripts (without cache cleaning)
#!/bin/bash
cp -r 1 2
sync
cp -r 3 4
sync
time grep "data" 1/*

The time on 'grep "data" 1/*' is measured
with/without cache cleaning, under different file counts.
With cache cleaning, we clean all cache entries of files
in '2' before doing 'cp -r 3 4' by using pretty much
the following two statements,
fd = open("2", O_DIRECTORY, 0644);
posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);

The results are as follows (in seconds), 
X: Number of files inside each directory

 X       Without Cleaning     With Cleaning
360          2.385                1.361
380          3.159                1.466
400          3.972                1.558
420          4.823                1.548
440          5.798                1.702
460          6.888                2.197

The page cache is not large enough to buffer all the four
directories, so 'cp -r 3 4' will result in some
entries of '1' to be evicted (due to LRU). When re-accessing '1',
some entries need be reloaded from disk, which is time-consuming.
In this case, cleaning '2' before 'cp -r 3 4' enjoys a good
speedup. 
 
Li Wang (3):
  VFS: Add the declaration of shrink_pagecache_parent
  Add shrink_pagecache_parent
  Fadvise: Add the ability for directory level page cache cleaning

 fs/dcache.c            |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/dcache.h |    1 +
 mm/fadvise.c           |    4 ++++
 3 files changed, 41 insertions(+)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
