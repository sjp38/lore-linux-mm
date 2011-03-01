Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E52D88D003F
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:00 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 00/24] Refactor sys_swapon
Date: Tue,  1 Mar 2011 20:28:24 -0300
Message-Id: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D6D7FEA.80800@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

This patch series refactors the sys_swapon function.

sys_swapon is currently a very large function, with 313 lines (more than
12 25-line screens), which can make it a bit hard to read. This patch
series reduces this size by half, by extracting large chunks of related
code to new helper functions.

One of these chunks of code was nearly identical to the part of
sys_swapoff which is used in case of a failure return from
try_to_unuse(), so this patch series also makes both share the same
code.

As a side effect of all this refactoring, the compiled code gets a bit
smaller (from v1 of this patch series):

   text       data        bss        dec        hex    filename
  14012        944        276      15232       3b80    mm/swapfile.o.before
  13941        944        276      15161       3b39    mm/swapfile.o.after

The v1 of this patch series was lightly tested on a x86_64 VM.

Changes from v1:
  Rebased from v2.6.38-rc4 to v2.6.38-rc7.

Cesar Eduardo Barros (24):
  sys_swapon: use vzalloc instead of vmalloc/memset
  sys_swapon: remove changelog from function comment
  sys_swapon: do not depend on "type" after allocation
  sys_swapon: separate swap_info allocation
  sys_swapon: simplify error return from swap_info allocation
  sys_swapon: simplify error flow in alloc_swap_info
  sys_swapon: remove initial value of name variable
  sys_swapon: move setting of error nearer use
  sys_swapon: remove did_down variable
  sys_swapon: remove bdev variable
  sys_swapon: do only cleanup in the cleanup blocks
  sys_swapon: use a single error label
  sys_swapon: separate bdev claim and inode lock
  sys_swapon: simplify error flow in claim_swapfile
  sys_swapon: move setting of swapfilepages near use
  sys_swapon: separate parsing of swapfile header
  sys_swapon: simplify error flow in read_swap_header
  sys_swapon: call swap_cgroup_swapon earlier
  sys_swapon: separate parsing of bad blocks and extents
  sys_swapon: simplify error flow in setup_swap_map_and_extents
  sys_swapon: remove nr_good_pages variable
  sys_swapon: move printk outside lock
  sys_swapoff: change order to match sys_swapon
  sys_swapon: separate final enabling of the swapfile

 mm/swapfile.c |  360 +++++++++++++++++++++++++++++++--------------------------
 1 files changed, 197 insertions(+), 163 deletions(-)

-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
