Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 1A7096B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 13:20:49 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id t12so2154300pdi.7
        for <linux-mm@kvack.org>; Fri, 05 Jul 2013 10:20:48 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V4 0/6] Memcg dirty/writeback page accounting
Date: Sat,  6 Jul 2013 01:18:29 +0800
Message-Id: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: mhocko@suse.cz, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, fengguang.wu@intel.com, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

Hi, list

This is V4 patch series that provide the ability for each memory cgroup to
have independent dirty/writeback page statistics.
Previous version is here:
  V3 - http://lwn.net/Articles/530776/;
  V2 - http://lwn.net/Articles/508452/;
  V1 - http://lwn.net/Articles/504017/;

The first two patches are still doing some cleanup and prepare works. Comparing
to V3, we give up reworking vfs set page dirty routines. Though this may make
following memcg dirty page accounting a little complicated, but it can avoid
exporting a new symbol and make vfs review easier. Patch 3/6 and 4/6 are acctually
doing memcg dirty and writeback page accounting, which adds statistic codes in
several hot paths. So in order to reduce the overheads, patch 5/6 is trying to do
some optimization by jump label: if only root memcg exists, there's no possibllity
of task moving between memcgs, so we can patch some codes out when not used. Note
that we only patch out mem_cgroup_{begin,end}_update_page_stat() at sometimes, but
still leave mem_cgroup_update_page_stat() there because we still need root page stat.
But there seems still some impact on performance, see numbers get by Mel's pft test
(On a 4g memory and 4-core i5 CPU machine):

vanilla  : memcg enabled, patch not applied
account  : memcg enabled, and add dirty/writeback page accounting
patched  : all patches are patched, including optimization in 5/6

* Duration numbers:
             vanilla     account
User          395.02      456.68
System         65.76       69.27
Elapsed       465.38      531.74(+14.3%)

             vanilla     patched
User          395.02      411.57
System         65.76       65.82
Elapsed       465.38      481.14(+3.4%)

* Summary numbers:
vanilla:
Clients User        System      Elapsed     Faults/cpu  Faults/sec  
1       0.02        0.19        0.22        925593.267  905793.990  
2       0.03        0.24        0.14        738464.210  1429302.471 
3       0.04        0.29        0.12        589251.166  1596685.658 
4       0.04        0.38        0.12        472565.657  1694854.626

account:
Clients User        System      Elapsed     Faults/cpu  Faults/sec  
1       0.02        0.20        0.23        878176.374  863037.483 (-4.7%)
2       0.03        0.27        0.16        661140.331  1235796.314(-13.5%)
3       0.03        0.30        0.16        592960.401  1225448.132(-23.3%)
4       0.04        0.31        0.15        567897.251  1296703.568(-23.5%)

patched:
Clients User        System      Elapsed     Faults/cpu  Faults/sec  
1       0.02        0.19        0.22        912709.796  898977.675 (-0.8%)
2       0.03        0.24        0.14        710928.981  1380878.891(-3.4%)
3       0.03        0.30        0.12        584247.648  1571436.530(-1.6%)
4       0.03        0.38        0.12        470335.271  1679938.339(-0.9%)

The performance is lower than vanilla kernel, however I think it's minor. But
note that I found some fluctuation on these numbers for several rounds, I selected
the above at the instance of the majority, I don't know if I missed anything..
I'm not sure if the test case is enough, any advice is welcomed! :)


Change log:
v4 <-- v3:
	1. give up reworking vfs codes
	2. change lock order of memcg->move_lock and mapping->tree_lock
	3. patch out mem_cgroup_{begin,end}_update_page_stat when not used
	4. rebased to since-3.10 branch
v3 <-- v2:
	1. change lock order of mapping->tree_lock and memcg->move_lock
	2. performance optimization in 6/8 and 7/8
v2 <-- v1:
        1. add test numbers
        2. some small fix and comments

Sha Zhengju (6):
      memcg: remove MEMCG_NR_FILE_MAPPED
      fs/ceph: vfs __set_page_dirty_nobuffers interface instead of doing it inside filesystem
      memcg: add per cgroup dirty pages accounting
      memcg: add per cgroup writeback pages accounting
      memcg: patch mem_cgroup_{begin,end}_update_page_stat() out if only root memcg exists
      memcg: Document cgroup dirty/writeback memory statistics

 Documentation/cgroups/memory.txt |    2 +
 fs/buffer.c                      |    9 +++++
 fs/ceph/addr.c                   |   13 +-----
 include/linux/memcontrol.h       |   44 ++++++++++++++++----
 mm/filemap.c                     |   14 +++++++
 mm/memcontrol.c                  |   83 +++++++++++++++++++++++---------------
 mm/page-writeback.c              |   39 +++++++++++++++++-
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |    6 +++
 9 files changed, 158 insertions(+), 56 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
