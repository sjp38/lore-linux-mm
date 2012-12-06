Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id CFDB06B0070
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:11:52 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so4763156pad.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:11:52 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 0/8] remove vm_struct list management
Date: Fri,  7 Dec 2012 01:09:27 +0900
Message-Id: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

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

I'm not sure that "7/8: makes vmlist only for kexec" is fine.
Because it is related to userspace program.
As far as I know, makedumpfile use kexec's output information and it only
need first address of vmalloc layer. So my implementation reflect this
fact, but I'm not sure. And now, I don't fully test this patchset.
Basic operation work well, but I don't test kexec. So I send this
patchset with 'RFC'.

Please let me know what I am missing.

This series based on v3.7-rc7 and on top of submitted patchset for ARM.
'introduce static_vm for ARM-specific static mapped area'
https://lkml.org/lkml/2012/11/27/356
But, running properly on x86 without ARM patchset.

Joonsoo Kim (8):
  mm, vmalloc: change iterating a vmlist to find_vm_area()
  mm, vmalloc: move get_vmalloc_info() to vmalloc.c
  mm, vmalloc: protect va->vm by vmap_area_lock
  mm, vmalloc: iterate vmap_area_list, instead of vmlist in
    vread/vwrite()
  mm, vmalloc: iterate vmap_area_list in get_vmalloc_info()
  mm, vmalloc: iterate vmap_area_list, instead of vmlist, in
    vmallocinfo()
  mm, vmalloc: makes vmlist only for kexec
  mm, vmalloc: remove list management operation after initializing
    vmalloc

 arch/tile/mm/pgtable.c      |    7 +-
 arch/unicore32/mm/ioremap.c |   17 +--
 arch/x86/mm/ioremap.c       |    7 +-
 fs/proc/Makefile            |    2 +-
 fs/proc/internal.h          |   18 ---
 fs/proc/meminfo.c           |    1 +
 fs/proc/mmu.c               |   60 ----------
 include/linux/vmalloc.h     |   19 +++-
 mm/vmalloc.c                |  258 +++++++++++++++++++++++++++++--------------
 9 files changed, 204 insertions(+), 185 deletions(-)
 delete mode 100644 fs/proc/mmu.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
