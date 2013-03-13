Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 31EB66B0036
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:33:07 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 0/8] remove vm_struct list management
Date: Wed, 13 Mar 2013 15:32:52 +0900
Message-Id: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Anderson <anderson@redhat.com>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Bob Liu <lliubbo@gmail.com>, Pekka Enberg <penberg@kernel.org>, kexec@lists.infradead.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset remove vm_struct list management after initializing vmalloc.
Adding and removing an entry to vmlist is linear time complexity, so
it is inefficient. If we maintain this list, overall time complexity of
adding and removing area to vmalloc space is O(N), although we use
rbtree for finding vacant place and it's time complexity is just O(logN).

And vmlist and vmlist_lock is used many places of outside of vmalloc.c.
It is preferable that we hide this raw data structure and provide
well-defined function for supporting them, because it makes that they
cannot mistake when manipulating theses structure and it makes us easily
maintain vmalloc layer.

For kexec and makedumpfile, I export vmap_area_list, instead of vmlist.
This comes from Atsushi's recommendation.
For more information, please refer below link.
https://lkml.org/lkml/2012/12/6/184

These are based on v3.9-rc2.

Changes from v1
5/8: skip areas for lazy_free
6/8: skip areas for lazy_free
7/8: export vmap_area_list for kexec, instead of vmlist

Joonsoo Kim (8):
  mm, vmalloc: change iterating a vmlist to find_vm_area()
  mm, vmalloc: move get_vmalloc_info() to vmalloc.c
  mm, vmalloc: protect va->vm by vmap_area_lock
  mm, vmalloc: iterate vmap_area_list, instead of vmlist in
    vread/vwrite()
  mm, vmalloc: iterate vmap_area_list in get_vmalloc_info()
  mm, vmalloc: iterate vmap_area_list, instead of vmlist, in
    vmallocinfo()
  mm, vmalloc: export vmap_area_list, instead of vmlist
  mm, vmalloc: remove list management of vmlist after initializing
    vmalloc

 arch/tile/mm/pgtable.c      |    7 +-
 arch/unicore32/mm/ioremap.c |   17 ++--
 arch/x86/mm/ioremap.c       |    7 +-
 fs/proc/Makefile            |    2 +-
 fs/proc/internal.h          |   18 ----
 fs/proc/meminfo.c           |    1 +
 fs/proc/mmu.c               |   60 -------------
 include/linux/vmalloc.h     |   21 ++++-
 kernel/kexec.c              |    2 +-
 mm/nommu.c                  |    3 +-
 mm/vmalloc.c                |  207 +++++++++++++++++++++++++++++--------------
 11 files changed, 170 insertions(+), 175 deletions(-)
 delete mode 100644 fs/proc/mmu.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
