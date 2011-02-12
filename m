Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CD6608D0039
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:48:31 -0500 (EST)
Received: from unknown (HELO cesarb-inspiron.home.cesarb.net) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:48:26 -0000
Message-ID: <4D56D5F9.8000609@cesarb.net>
Date: Sat, 12 Feb 2011 16:48:25 -0200
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: [PATCH 00/24] Refactor sys_swapon
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This patch series refactors the sys_swapon function.

sys_swapon is currently a very large function, with 313 lines (more than 
12 25-line screens), which can make it a bit hard to read. This patch 
series reduces this size by half, by extracting large chunks of related 
code to new helper functions.

One of these chunks of code was nearly identical to the part of 
sys_swapoff which is used in case of a failure return from 
try_to_unuse(), so this patch series also makes both share the same code.

As a side effect of all this refactoring, the compiled code gets a bit 
smaller:

    text	   data	    bss	    dec	    hex	filename
   14012	    944	    276	  15232	   3b80	mm/swapfile.o.before
   13941	    944	    276	  15161	   3b39	mm/swapfile.o.after

Lightly tested on a x86_64 VM.

  mm/swapfile.c |  360 +++++++++++++++++++++++++++----------------------
  1 files changed, 197 insertions(+), 163 deletions(-)

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

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
