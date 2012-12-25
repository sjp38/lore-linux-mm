Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 5F4E96B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 12:18:54 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rp2so4436170pbb.15
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 09:18:53 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V3 0/8] Per-cgroup page stat accounting
Date: Wed, 26 Dec 2012 01:18:39 +0800
Message-Id: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

Hi, list

This is V3 patch series that provide the ability for each memory cgroup to
have independent dirty/writeback page statistics which can provide information
for per-cgroup direct reclaim or some.

In the first three prepare patches, we have done some cleanup and reworked vfs
set page dirty routines to make "modify page info" and "dirty page accouting" stay
in one function as much as possible for the sake of memcg bigger lock(test numbers
are in the specific patch). There is no change comparing to V2.

Patch 4/8 and 5/8 are acctually doing memcg dirty and writeback page accounting.
We change lock orders of mapping->tree_lock and memcg->move_lock to prevent
deadlock. Test numbers of previous version show that there is some performance
decrease after patching the accouting once memcg is enabled. The reason is that
if no memcg exists but root_mem_cgroup, all allocated pages are belonging to root memcg
and they will go through root memcg statistics routines which brings overheads.
So we do some optimization in patch 6/8 and 7/8: patch 6 chooses to give up accounting
root memcg stat but changes behavior of memcg_stat_show() instead; patch 7 uses jump
label to disable memcg page stat accounting code when not in use which is inspired by
a similar optimization from Glauber Costa
(memcg: make it suck faster; https://lkml.org/lkml/2012/9/25/154).

On a 4g memory and 4-core i5 CPU machine, we pushing 1G data through 600M memcg
(memory.limit_in_bytes=600M, memory.memsw.limit_in_bytes=1500M) by fio:
fio (ioengine=sync/write/buffered/bs=4k/size=1g/numjobs=2/group_reporting/thread)

Following is performance comparison between before/after the whole series
(test it for 10 times and get the average numbers):
Before:
write: io=2048.0MB, bw=214527KB/s, iops=53631.2 , runt= 9880.1msec
lat (usec): min=1 , max=1685.06K, avg=36.182, stdev=3153.97

After:
write: io=2048.0MB, bw=193069KB/s, iops=48266.6 , runt= 11078.6msec
lat (usec): min=1 , max=1634.26K, avg=40.598, stdev=3135.81

Note that now the impact is little(~1%).

Any comments are welcomed. : )

Change log:
v3 <--v2
	1. change lock order of mapping->tree_lock and memcg->move_lock
	2. performance optimization in 6/8 and 7/8
v2 <-- v1:
        1. add test numbers
        2. some small fix and comments

Sha Zhengju (8):
	memcg-remove-MEMCG_NR_FILE_MAPPED.patch
	Make-TestSetPageDirty-and-dirty-page-accounting-in-o.patch
	use-vfs-__set_page_dirty-interface-instead-of-doing-.patch
	memcg-add-per-cgroup-dirty-pages-accounting.patch
	memcg-add-per-cgroup-writeback-pages-accounting.patch
	memcg-Don-t-account-root_mem_cgroup-page-statistics.patch
	memcg-disable-memcg-page-stat-accounting-code-when-n.patch
	memcg-Document-cgroup-dirty-writeback-memory-statist.patch

 Documentation/cgroups/memory.txt |    2 +
 fs/buffer.c                      |   37 +++++++----
 fs/ceph/addr.c                   |   20 +-----
 include/linux/buffer_head.h      |    2 +
 include/linux/memcontrol.h       |   39 ++++++++---
 mm/filemap.c                     |   10 +++
 mm/memcontrol.c                  |  134 ++++++++++++++++++++++++++++++--------
 mm/page-writeback.c              |   56 ++++++++++++++--
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |    6 ++
 10 files changed, 235 insertions(+), 75 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
