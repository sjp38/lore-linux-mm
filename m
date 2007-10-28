Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9SKYGT0003413
	for <linux-mm@kvack.org>; Mon, 29 Oct 2007 07:34:16 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9SKYH4n1712224
	for <linux-mm@kvack.org>; Mon, 29 Oct 2007 07:34:17 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9SKY11Y028784
	for <linux-mm@kvack.org>; Mon, 29 Oct 2007 07:34:01 +1100
Date: Mon, 29 Oct 2007 02:02:19 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] [-mm PATCH] Memory controller fix swap charging context in unuse_pte()
Message-ID: <20071028203219.GA7145@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20071005041406.21236.88707.sendpatchset@balbir-laptop> <Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com> <4713A2F2.1010408@linux.vnet.ibm.com> <Pine.LNX.4.64.0710221933570.21262@blonde.wat.veritas.com> <471F3732.5050407@linux.vnet.ibm.com> <Pine.LNX.4.64.0710252002540.25735@blonde.wat.veritas.com> <4724F0BC.1020209@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4724F0BC.1020209@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 29, 2007 at 01:57:40AM +0530, Balbir Singh wrote:
Hugh Dickins wrote:

[snip]
 
> Without your mem_cgroup mods in mm/swap_state.c, unuse_pte makes
> the right assignments (I believe).  But I find that swapout (using
> 600M in a 512M machine) from a 200M cgroup quickly OOMs, whereas
> it behaves correctly with your mm/swap_state.c.
> 

On my UML setup, I booted the UML instance with 512M of memory and
used the swapout program that you shared. I tried two things


1. Ran swapout without any changes. The program ran well without
   any OOM condition occuring, lot of reclaim occured.
2. Ran swapout with the changes to mm/swap_state.c removed (diff below)
   and I still did not see any OOM. The reclaim count was much lesser
   since swap cache did not get accounted back to the cgroup from
   which pages were being evicted.

I am not sure why I don't see the OOM that you see, still trying. May be
I missing something obvious at this late hour in the night :-)

Output of the tests
-------------------

balbir@ubuntu:/container/swapout$ cat memory.limit_in_bytes
209715200
balbir@ubuntu:/container/swapout$ cat memory.usage_in_bytes
65536
balbir@ubuntu:/container/swapout$ cat tasks
1815
1847
balbir@ubuntu:/container/swapout$ ps
  PID TTY          TIME CMD
 1815 pts/0    00:00:00 bash
 1848 pts/0    00:00:00 ps
balbir@ubuntu:/container/swapout$ ~/swapout
balbir@ubuntu:/container/swapout$ echo $?
0
balbir@ubuntu:/container/swapout$ cat memory.failcnt
18

Diff to remove mods from swap_state.c (for testing only)
--------------------------------------------------------

--- mm/swap_state.c.org	2007-10-29 01:42:14.000000000 +0530
+++ mm/swap_state.c	2007-10-29 01:52:48.000000000 +0530
@@ -79,10 +79,6 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PageSwapCache(page));
 	BUG_ON(PagePrivate(page));
 
-	error = mem_cgroup_cache_charge(page, current->mm, gfp_mask);
-	if (error)
-		goto out;
-
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
 		write_lock_irq(&swapper_space.tree_lock);
@@ -94,14 +90,11 @@ static int __add_to_swap_cache(struct pa
 			set_page_private(page, entry.val);
 			total_swapcache_pages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
-		} else
-			mem_cgroup_uncharge_page(page);
+		}
 
 		write_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
-	} else
-		mem_cgroup_uncharge_page(page);
-out:
+	}
 	return error;
 }
 
@@ -141,7 +134,6 @@ void __delete_from_swap_cache(struct pag
 	BUG_ON(PageWriteback(page));
 	BUG_ON(PagePrivate(page));
 
-	mem_cgroup_uncharge_page(page);
 	radix_tree_delete(&swapper_space.page_tree, page_private(page));
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
