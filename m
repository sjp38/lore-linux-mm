Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 9069A6B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 07:43:56 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so1984647pbc.26
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 04:43:55 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V5 0/8] Add memcg dirty/writeback page accounting
Date: Thu,  1 Aug 2013 19:43:22 +0800
Message-Id: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, gthelen@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

Hi,

This is V5 patch series that provide the ability for each memory cgroup to
have independent dirty/writeback page statistics.
Previous version is here:
  V4 - http://www.spinics.net/lists/cgroups/msg08200.html;
  V3 - http://lwn.net/Articles/530776/;
  V2 - http://lwn.net/Articles/508452/;
  V1 - http://lwn.net/Articles/504017/;

The first three patches are doing some cleanup and prepare works. The first two
is nothing changed since V3 and patch 3/8 is a new one to check proper locks held.
Patch 4/8 and 5/8 are doing memcg dirty and writeback page accounting, which adds
statistic codes in several hot paths.

Patch 6/8 and 7/8 are trying to wipe off the overheads introduced in by previous
two patches, and this is the main changes towards V3. Patch 6 is a prepare one
to make nocpu_base available for all usages not only hotplug cases. I stealed it
from Glauber Costa - http://www.spinics.net/lists/cgroups/msg06233.html. Patch 7
is doing some optimization by jump label: if only root memcg exists, we don't
need to do page stat accounting and transfer global page stats to root only when
the first non-root memcg is created.  

Some perforcemance numbers got by Mel's pft test (On a 4g memory and 4-core
i5 CPU machine):

vanilla  : memcg enabled, patch not applied
patched  : all patches are patched

* Duration numbers:
             vanilla     patched
User          385.38      379.47
System         65.12       66.46
Elapsed       457.46      452.21

* Summary numbers:
vanilla:
Clients User        System      Elapsed     Faults/cpu  Faults/sec  
1       0.03        0.18        0.21        931682.645  910993.850  
2       0.03        0.22        0.13        760431.152  1472985.863 
3       0.03        0.29        0.12        600495.043  1620311.084 
4       0.04        0.37        0.12        475380.531  1688013.267

patched:
Clients User        System      Elapsed     Faults/cpu  Faults/sec  
1       0.02        0.19        0.22        915362.875  898763.732  
2       0.03        0.23        0.13        757518.387  1464893.996 
3       0.03        0.30        0.12        592113.126  1611873.469 
4       0.04        0.38        0.12        472203.393  1680013.271

We can see the performance gap is minor.

Change log:
v5 <-- v4:
	1. add patch 3 to check proper lock held suggested by Michal Hock
        2. add another two interfaces which should call mem_cgroup_begin/end_
	   update_page_stat() in dirty page accounting
        3. make nobase_cpu not only used in hotplug cases
        4. don't account root memcg page stats if only root exist
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

Glauber Costa (1):
      memcg: make nocpu_base available for non-hotplug

Sha Zhengju (7):
      memcg: remove MEMCG_NR_FILE_MAPPED
      fs/ceph: vfs __set_page_dirty_nobuffers interface instead of doing it inside filesystem
      memcg: check for proper lock held in mem_cgroup_update_page_stat
      memcg: add per cgroup dirty pages accounting
      memcg: add per cgroup writeback pages accounting
      memcg: patch mem_cgroup_{begin,end}_update_page_stat() out if only root memcg exists
      memcg: Document cgroup dirty/writeback memory statistics

 Documentation/cgroups/memory.txt |    2 +
 fs/buffer.c                      |   13 +++
 fs/ceph/addr.c                   |   13 +--
 include/linux/memcontrol.h       |   47 ++++++++--
 mm/filemap.c                     |   17 +++-
 mm/memcontrol.c                  |  189 +++++++++++++++++++++++++++++---------
 mm/page-writeback.c              |   39 +++++++-
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |   12 +++
 mm/vmscan.c                      |    7 ++
 10 files changed, 273 insertions(+), 70 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
