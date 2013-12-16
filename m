Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 713866B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:00:59 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so5422008pdj.12
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:00:59 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id pt8si9125814pac.192.2013.12.16.07.00.57
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 07:00:58 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: =?UTF-8?q?=5BPATCH=200/5=5D=20VFS=3A=20Directory=20level=20cache=20cleaning?=
Date: Mon, 16 Dec 2013 07:00:04 -0800
Message-Id: <cover.1387205337.git.liwang@ubuntukylin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

Currently, Linux only support file system wide VFS
cache (dentry cache and page cache) cleaning through
'/proc/sys/vm/drop_caches'. Sometimes this is less
flexible. The applications may know exactly whether
the metadata and data will be referenced or not in future,
a desirable mechanism is to enable applications to
reclaim the memory of unused cache entries at a finer
granularity - directory level. This enables applications
to keep hot metadata and data (to be referenced in the
future) in the cache, and kick unused out to avoid
cache thrashing. Another advantage is it is more flexible
for debugging.

This patch extend the 'drop_caches' interface to
support directory level cache cleaning and has a complete
backward compatibility. '{1,2,3}' keeps the same semantics
as before. Besides, "{1,2,3}:DIRECTORY_PATH_NAME" is allowed
to recursively clean the caches under DIRECTORY_PATH_NAME.
For example, 'echo 1:/home/foo/jpg > /proc/sys/vm/drop_caches'
will clean the page caches of the files inside 'home/foo/jpg'.

It is easy to demonstrate the advantage of directory level
cache cleaning. We use a virtual machine configured with
an Intel(R) Xeon(R) 8-core CPU E5506 @ 2.13GHz, and with 1GB
memory.  Three directories named '1', '2' and '3' are created,
with each containing 180000 a?? 280000 files. The test program
opens all files in a directory and then tries the next directory.
The order for accessing the directories is '1', '2', '3',
'1'.

The time on accessing '1' on the second time is measured
with/without cache cleaning, under different file counts.
With cache cleaning, we clean all cache entries of files
in '2' before accessing the files in '3'. The results
are as follows (in seconds),

Note: by default, VFS will move those unreferenced inodes
into a global LRU list rather than freeing them, for this
experiment, we modified iput() to force to free inode as well,
this behavior and related codes are left for further discussion,
thus not reflected in this patch)

Number of files:   180000 200000 220000 240000 260000
Without cleaning:  2.165  6.977  10.032 11.571 13.443
With cleaning:     1.949  1.906  2.336  2.918  3.651

When the number of files is 180000 in each directory,
the metadata cache is large enough to buffer all entries
of three directories, so re-accessing '1' will hit in
the cache, regardless of whether '2' cleaned up or not.
As the number of files increases, the cache can now only
buffer two+ directories. Accessing '3' will result in some
entries of '1' to be evicted (due to LRU). When re-accessing '1',
some entries need be reloaded from disk, which is time-consuming.
In this case, cleaning '2' before accessing '3' enjoys a good
speedup, a maximum 4.29X performance improvements is achieved.
The advantage of directory level page cache cleaning should be 
easier to be demonstrated.

Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>

Li Wang (5):
  VFS: Convert drop_caches to accept string
  VFS: Convert sysctl_drop_caches to string
  VFS: Add the declaration of shrink_pagecache_parent
  VFS: Add shrink_pagecache_parent
  VFS: Extend drop_caches sysctl handler to allow directory level cache
    cleaning

 fs/dcache.c            |   35 +++++++++++++++++++++++++++++++++++
 fs/drop_caches.c       |   45 +++++++++++++++++++++++++++++++++++++--------
 include/linux/dcache.h |    1 +
 include/linux/mm.h     |    3 ++-
 kernel/sysctl.c        |    6 ++----
 5 files changed, 77 insertions(+), 13 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
