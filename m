Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 511DC6B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:20:43 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5503766pbb.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 03:20:42 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 0/6] Per-cgroup page stat accounting
Date: Fri, 27 Jul 2012 18:20:32 +0800
Message-Id: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: fengguang.wu@intel.com, gthelen@google.com, akpm@linux-foundation.org, yinghan@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Hi, list

This V2 patch series provide the ability for each memory cgroup to have independent
dirty/writeback page statistics which can provide information for per-cgroup
direct reclaim or some.

In the first three prepare patches, we have done some cleanup and reworked vfs
set page dirty routines to make "modify page info" and "dirty page accouting" stay
in one function as much as possible for the sake of memcg bigger lock(test numbers
are in the specific patch).

Kame, I tested these patches on linux mainline v3.5, because I cannot boot up the kernel
under linux-next :(. But these patches are cooked on top of your recent memcg patches
(I backport them to mainline) and I think there is no hunk with the mm tree.
So If there's no other problem, I think it could be considered for merging.



Following is performance comparison between before/after the series:

Test steps(Mem-24g, ext4):
drop_cache; sync
cat /proc/meminfo|grep Dirty (=4KB)
fio (buffered/randwrite/bs=4k/size=128m/filesize=1g/numjobs=8/sync) 
cat /proc/meminfo|grep Dirty(=648696kB)

We test it for 10 times and get the average numbers:
Before:
write: io=1024.0MB, bw=334678 KB/s, iops=83669.2 , runt=  3136 msec
lat (usec): min=1 , max=26203.1 , avg=81.473, stdev=275.754

After:
write: io=1024.0MB, bw=325219 KB/s, iops= 81304.1 , runt=  3226.9 msec
lat (usec): min=1 , max=17224 , avg=86.194, stdev=298.183



There is about 2.8% performance decrease. But I notice that once memcg is enabled,
the root_memcg exsits and all pages allocated are belong to it, so they will go
through the root memcg statistics routines which bring some overhead. 
Moreover,in case of memcg_is_enable && no cgroups, we can get root memcg stats
just from global numbers which can avoid both accounting overheads and many if-test
overheads. Later I'll work further into it.

Any comments are welcomed. : )



Change log:
v2 <-- v1:
	1. add test numbers
	2. some small fix and comments

Sha Zhengju (6):
	memcg-remove-MEMCG_NR_FILE_MAPPED.patch
	Make-TestSetPageDirty-and-dirty-page-accounting-in-o.patch
	Use-vfs-__set_page_dirty-interface-instead-of-doing-.patch
	memcg-add-per-cgroup-dirty-pages-accounting.patch
	memcg-add-per-cgroup-writeback-pages-accounting.patch
	memcg-Document-cgroup-dirty-writeback-memory-statist.patch

 Documentation/cgroups/memory.txt |    2 +
 fs/buffer.c                      |   36 +++++++++++++++--------
 fs/ceph/addr.c                   |   20 +------------
 include/linux/buffer_head.h      |    2 +
 include/linux/memcontrol.h       |   30 ++++++++++++++-----
 mm/filemap.c                     |    9 ++++++
 mm/memcontrol.c                  |   58 +++++++++++++++++++-------------------
 mm/page-writeback.c              |   48 ++++++++++++++++++++++++++++---
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |    6 ++++
 10 files changed, 141 insertions(+), 74 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
