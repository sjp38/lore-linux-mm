Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C61656B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:36:31 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 0/8] avoid allocation in show_numa_map()
Date: Wed, 27 Apr 2011 19:35:41 -0400
Message-Id: <1303947349-3620-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Recently a concern was raised[1] that performing an allocation while holding a
reference on a tasks mm could lead to a stalemate in the oom killer.  The
concern was specific to the goings-on in /proc.  Hugh Dickins stated the issue
thusly:

    ...imagine what happens if the system is out of memory, and the mm
    we're looking at is selected for killing by the OOM killer: while we
    wait in __get_free_page for more memory, no memory is freed from the
    selected mm because it cannot reach exit_mmap while we hold that
    reference.

The primary goal of this series is to eliminate repeated allocation/free cycles
currently happening in show_numa_maps() while we hold a reference to an mm.

The strategy is to perform the allocation once when /proc/pid/numa_maps is
opened, before a reference on the target tasks mm is taken.

Unfortunately, show_numa_maps() is implemented in mm/mempolicy.c while the
primary procfs implementation  lives in fs/proc/task_mmu.c.  This makes
clean cooperation between show_numa_maps() and the other seq_file operations
(start(), stop(), etc) difficult.


Patches 1-5 convert show_numa_maps() to use the generic walk_page_range()
functionality instead of the mempolicy.c specific page table walking logic.
Also, get_vma_policy() is exported.  This makes the show_numa_maps()
implementation independent of mempolicy.c. 

Patch 6 moves show_numa_maps() and supporting routines over to
fs/proc/task_mmu.c.

Finally, patches 7 and 8 provide minor cleanup and eliminates the troublesome
allocation.

 
Please note that moving show_numa_maps() into fs/proc/task_mmu.c essentially
reverts 1a75a6c825 and 48fce3429d.  Also, please see the discussion at [2].  My
main justifications for moving the code back into task_mmu.c is:

  - Having the show() operation "miles away" from the corresponding
    seq_file iteration operations is a maintenance burden. 
    
  - The need to export ad hoc info like struct proc_maps_private is
    eliminated.


These patches are based on v2.6.39-rc5.


Please note that this series is VERY LIGHTLY TESTED.  I have been using
CONFIG_NUMA_EMU=y thus far as I will not have access to a real NUMA system for
another week or two.


--
steve


[1] lkml.org/lkml/2011/4/25/496
[2] marc.info/?t=113149255100001&r=1&w=2


Stephen Wilson (8):
      mm: export get_vma_policy()
      mm: use walk_page_range() instead of custom page table walking code
      mm: remove MPOL_MF_STATS
      mm: make gather_stats() type-safe and remove forward declaration
      mm: remove check_huge_range()
      mm: proc: move show_numa_map() to fs/proc/task_mmu.c
      proc: make struct proc_maps_private truly private
      proc: allocate storage for numa_maps statistics once


 fs/proc/internal.h        |    8 ++
 fs/proc/task_mmu.c        |  190 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/mempolicy.h |    3 +
 include/linux/proc_fs.h   |    8 --
 mm/mempolicy.c            |  164 +--------------------------------------
 5 files changed, 200 insertions(+), 173 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
