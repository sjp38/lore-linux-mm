Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB45IxW2002088
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Dec 2008 14:18:59 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 560D545DE61
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:18:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3384345DE55
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:18:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0559D1DB8038
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:18:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89A711DB803E
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:18:58 +0900 (JST)
Date: Thu, 4 Dec 2008 14:18:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mmotm] Documentation update
Message-Id: <20081204141809.c5ae304a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4937649A.4050503@oracle.com>
References: <20081204132111.63f1b300.kamezawa.hiroyu@jp.fujitsu.com>
	<4937649A.4050503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Thanks! very helpful.

On Wed, 03 Dec 2008 21:03:22 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > mmotm-2008-12-03 includes memcg-explain-details-and-test-document.patch
> > 
> > But it's still rough and not complete.
> > I'd like to update it to be readable becasue memcg is a blackbox for the most
> > of developpers but it has many hooks to global VM.
> > 
> > If you have reuqest as "explain xxx in detail", please tell me.
> > I'll not send this out for a while.
> >  
> > Of course, your own patch is welcome.
> > 
> > -Kame
> > 
> > ==
> >  Documentation/controllers/memcg_test.txt |  216 ++++++++++++++++++++++++++-----
> >  mm/memcontrol.c                          |    4 
> >  2 files changed, 189 insertions(+), 31 deletions(-)
> > 
> > Index: mmotm-2.6.28-Dec03/Documentation/controllers/memcg_test.txt
> > ===================================================================
> > --- mmotm-2.6.28-Dec03.orig/Documentation/controllers/memcg_test.txt
> > +++ mmotm-2.6.28-Dec03/Documentation/controllers/memcg_test.txt
> > @@ -1,59 +1,74 @@
> >  Memory Resource Controller(Memcg)  Implementation Memo.
> > -Last Updated: 2009/12/03
> > +Last Updated: 2009/12/04
> 
> It's still 2008 AFAIK.
> 
yes..

> > +Base Kernel Version: 2.6.28-rc7-mm.
> >  
> >  Because VM is getting complex (one of reasons is memcg...), memcg's behavior
> >  is complex. This is a document for memcg's internal behavior and some test
> > -patterns tend to be racy.
> > +patterns tend to be racy. Please note that explanation about implementation
> 
> This is a document about ... and ...
> 
> This is awkward.  The two "abouts" should be related or at least have the
> same phrase structure.  Maybe you could just drop the "and some test patterns
> tend to be racy." ??
> 
ok, thanks.

> > +details can be very old.
> >  
> > -1. charges
> > +(*) Topics on API should be in Documentation/controllers/memory.txt)
> > +
> > +0. How to record usage ?
> > +   2 objects are used.
> > +   page_cgroup ....an object per page.
> > +   swap_cgroup ... an entry per swp_entry
> > +   Both of them are allocated at boot.
> 
> Allocated for all known pages and possible swap pages?
Allocated for all known pages and all swap entries found at swapon().

> How are allocations for memory hotplug handled?
> 
handle by memory hotplug event notfier chain.

will add text.


> > +
> > +   The page_cgroup has USED bit and double count against a page_cgroup never
> > +   occurs. swap_cgroup is used only when a charged page is swapped-out.
> > +
> > +1. Charge
> >  
> >     a page/swp_entry may be charged (usage += PAGE_SIZE) at
> >  
> >  	mem_cgroup_newpage_newpage()
> 
> I can't find that function in mmotm-2008-12-03.  Is it there or does the
> function name have a duplicate _newpage ?
> 
mem_cgroup_newpage_charge() 

> > -	  called at new page fault and COW.
> > +	  Called at new page fault and Copy-On-Write.
> >  
> >  	mem_cgroup_try_charge_swapin()
> > -	  called at do_swap_page() and swapoff.
> > -	  followed by charge-commit-cancel protocol.
> > -	  (With swap accounting) at commit, charges recorded in swap is removed.
> > +	  Called at do_swap_page() (page fault on swap entry) and swapoff.
> > +	  Followed by charge-commit-cancel protocol. (With swap accounting)
> > +	  At commit, charges recorded in swap_cgroup is removed.
> 
> 	                                             are removed.
> 
will fix.


> >  
> >  	mem_cgroup_cache_charge()
> > -	  called at add_to_page_cache()
> > +	  Called at add_to_page_cache()
> >  
> > -	mem_cgroup_cache_charge_swapin)()
> > -	  called by shmem's swapin processing.
> > +	mem_cgroup_cache_charge_swapin()
> > +	  Called at shmem's swapin.
> >  
> >  	mem_cgroup_prepare_migration()
> > -	  called before migration. "extra" charge is done
> > -	  followed by charge-commit-cancel protocol.
> > +	  Called before migration. "extra" charge is done and followed by
> > +	  charge-commit-cancel protocol.
> >  	  At commit, charge against oldpage or newpage will be committed.
> >  
> > -2. uncharge
> > +2. Uncharge
> >    a page/swp_entry may be uncharged (usage -= PAGE_SIZE) by
> >  
> >  	mem_cgroup_uncharge_page()
> > -	  called when an anonymous page is unmapped. If the page is SwapCache
> > -	  uncharge is delayed until mem_cgroup_uncharge_swapcache().
> > +	  Called when an anonymous page is fully unmapped .i.e mapcount goes
> 
> 	                                   fully unmapped.  I.e., mapcount goes
> 
will fix.

> > +	  to 0. If the page is SwapCache, uncharge is delayed until
> > +	  mem_cgroup_uncharge_swapcache().
> >  
> >  	mem_cgroup_uncharge_cache_page()
> > -	  called when a page-cache is deleted from radix-tree. If the page is
> > +	  Called when a page-cache is deleted from radix-tree. If the page is
> >  	  SwapCache, uncharge is delayed until mem_cgroup_uncharge_swapcache()
> 
> End with '.' like above description does.
> 
will add '.'

> >  
> >  	mem_cgroup_uncharge_swapcache()
> > -	  called when SwapCache is removed from radix-tree. the charge itself
> > +	  Called when SwapCache is removed from radix-tree. The charge itself
> >  	  is moved to swap_cgroup. (If mem+swap controller is disabled, no
> >  	  charge to swap.)
> >  
> >  	mem_cgroup_uncharge_swap()
> > -	  called when swp_entry's refcnt goes down to be 0. charge against swap
> > +	  Called when swp_entry's refcnt goes down to be 0. Charge against swap
> 
> 	                                      down to 0.
> 
ok,

> >  	  disappears.
> >  
> >  	mem_cgroup_end_migration(old, new)
> > -	at success of migration -> old is uncharged (if necessary), charge
> > -	to new is committed. at failure, charge to old is committed.
> > +	At success of migration -> old is uncharged (if necessary), a charge
> > +	to new page is committed. at failure, charge to old page is committed.
> 
> 	                          At
> 
will fix. I tend to forget use capical...sorry.


> >  
> >  3. charge-commit-cancel
> > -	In some case, we can't know this "charge" is valid or not at charge.
> > +	In some case, we can't know this "charge" is valid or not at charging.
> 
> 	                                                             charging
> 
> > +	(Because of races.)
> 
> 	(because of races).
> 
Oh, sure.


> >  	To handle such case, there are charge-commit-cancel functions.
> >  		mem_cgroup_try_charge_XXX
> >  		mem_cgroup_commit_charge_XXX
> > @@ -68,23 +83,153 @@ patterns tend to be racy.
> >  
> >  	At cancel(), simply usage -= PAGE_SIZE.
> >  
> > -4. Typical Tests.
> > +Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
> > +
> > +4. Anonymous
> > +	Anonymous page is newly allocated at
> > +		  - page fault into MAP_ANONYMOUS mapping.
> > +		  - Copy-On-Write.
> > + 	It is charged right after it's allocated before doing any page table
> > +	related operations. Of course, it's uncharged when another page is used
> > +	for the fault address.
> > +
> > +	At freeing anonymous page (by exit() or munmap()), zap_pte() is called
> > +	and pages for ptes are freed one by one.(see mm/memory.c). Uncharges
> 
> 	                                    one (see mm/memory.c). Uncharges
> 
will fix.

> > +	are done at page_remove_rmap() when page_mapcount() goes down to 0.
> > +
> > +	Yet another page freeing is by page-reclaim(vmscan.c) and anonymous
> 
> 	                               page-reclaim (vmscan.c)
> 
will fix.

> > +	pages are swapped-out. In this case, the page is marked as
> 
> 	          swapped out.
> 
will fix.

> > +	PageSwapCache(). uncharge() routine doesn't uncharge the page marked
> > +	as SwapCache(). It's delayed until __delete_from_swap_cache().
> > +
> > +	4.1 Swap-in.
> > +	At swap-in, the page is taken from swap-cache.There are 2 cases.
> 
> 	                                   swap-cache. There
> 
ok.

> > +
> > +	(a) If the SwapCache is newly allocated and read, it has no charges.
> > +	(b) If the SwapCache have been mapped by some process, it has been
> 
> 	I would say:         has been
> 
will fix


> > +	    charged already.
> > +	In case (a), we charge it. In case (b), we don't charge it.
> > +	(But racy state between (a) and (b) exists. We do check it.)
> > +	At charging, a charge recorded in swap_cgroup is moved to page_cgroup.
> > +
> > +	4.2 Swap-out.
> > +	At swap-out, typical state transition is below.
> > +
> > +	(a) add to swap cache. (marked as SwapCache)
> > +	    swp_entry's refcnt += 1.
> > +	(b) fully unmapped.
> > +	    swp_entry's refcnt += # of ptes.
> > +	(c) write back to swap.
> > +	(d) delete from swap cache. (remove from SwapCache)
> > +	    swp_entry's refcnt -= 1.
> > +
> > +
> > +	At (b), the page is marked as SwapCache and not uncharged.
> > +	At (d), the page is removed from SwapCache and a charge in page_cgroup
> > +	is moved to swap_cgroup.
> > +
> > +	Finally, at task exits,
> 
> 	            task exit,
> 
ok


> > +	(e) zap_pte() is called and swp_entry's refcnt -=1 -> 0.
> > +	Here, a charge in swap_cgroup disappears.
> > +
> > +5. Page Cache
> > +   	Page Cache is charged at
> > +	- add_to_page_cache_locked().
> > +
> > +	uncharged at
> > +	- __remove_from_page_cache().
> > +
> > +	The logic is very clear. (About migration, see below)
> > +	Note: __remove_from_page_cache() is called by remove_from_page_cache()
> > +	and __remove_mapping().
> > +
> > +6. Shmem(tmpfs) Page Cache
> > +	Memcg's charge/uncharge have special handlers of shmem. The best way
> > +	to understand shmem's page state transition is to read mm/shmem.c.
> > +	But brief explanation of the behavior of memcg around shmem will be
> > +	helpful to understand the logic.
> > +
> > +	Shmem's page (just leaf page, not direct/indirect block) can be on
> > +		- radix-tree of shmem's inode.
> > +		- SwapCache.
> > +		- Both on radix-tree and SwapCache. This happens at swap-in.
> 
> 		                                                    swap-in
> 
> > +		  and swap-out,
> 
> 		  and swap-out.
> 
Sure


> > +
> > +	It's charged when...
> > +	- A new page is added to shmem's radix-tree.
> > +	- A swp page is read. (move a charge from swap_cgroup to page_cgroup)
> > +	It's uncharged when
> > +	- A page is removed from radix-tree and not SwapCache.
> > +	- When SwapCache is removed, a charge is moved to swap_cgroup.
> > +	- When swp_entry's refcnt goes down to 0, a charge in swap_cgroup
> > +	  disappears.
> > +
> > +7. Page Migration
> > +   	One of the most complicated logic is page-migration-handler.
> 
> This needs to be "most complicated functions" or "most complicated pieces
> of logic".  or something like that.
> 

ok, will consider here again.

> > +	memcg have 2 routine. Assume migrate page's contents from OLDPAGE
> 
> 	      has 2 routines. Assume that we are migrating a page's contents
> 	from OLDPAGE to NEWPAGE.
> 
ok, it's better.


> > +	to NEWPAGE.
> > +
> > +	Usual migration logic is..
> > +	(a) remove the page from LRU.
> > +	(b) allocate NEWPAGE (migration target)
> > +	(c) lock by lock_page().
> > +	(d) unmap all mappings.
> > +	(e-1) If necessary, replace entry in radix-tree.
> > +	(e-2) move contents of a page.
> > +	(f) map all mappings again.
> > +	(g) pushback the page to LRU.
> > +	(-) OLDPAGE will be freed.
> > +
> > +	Before (g), memcg should complete the all works.
> 
> should complete what??
> 
Ah...memcg should complete all charge/uncharge to OLDPAGE/NEWPAGE.

> > +
> > +	The point is....
> > +	- If OLDPAGE is anonymous, all charges will be dropped at (d)
> > +	- If OLDPAGE is SwapCache, charges will be kept at (g)
> > +	- If OLDPAGE is page-cache, charges will be kept at (g)
> > +	At (e-1)(e-2) and (f), there are no hooks of memcg.
> > +
> > +	memcg provides following hooks.
> > +	- mem_cgroup_prepare_migration(OLDPAGE)
> > +	  Called at (b) and account a charge (usage += PAGE_SIZE) against
> 
> 	                to account a charge
> or	                and accounts a change
> 
will fix


> > +	  memcg which "OLDPAGE" belongs to.
> > +
> > +        - mem_cgroup_end_migration(OLDPAGE, NEWPAGE)
> > +	  Called after (f) before (g).
> > +	  If OLDPAGE is used, commit OLDPAGE again. If OLDPAGE is already
> > +	  charged, a charge by prepare_migration() is automatically canceled.
> > +	  If NEWPAGE is used, commit NEWPAGE and uncharge OLDPAGE.
> > +
> > +	  But zap_pte()(by exit or munmap) can be called while migration,
> 
> 	      zap_pte() (by exit or munmap) can be called during migration, so
> 
will fix


> > +	  we have to check OLDPAGE/NEWPAGE is a valid page after commit().
> 
> 	             check if OLDPAGE/NEWPAGE
> 
will fix

> > +
> > +8. LRU
> > +        Each memcg has its own private LRU. Now, it's handling is under global
> > +	VM's control (means that it's handled under global zone->lru_lock).
> > +	Almost all routines around memcg's LRU is called by global LRU's
> 
> 	                                       are called
> 
will fix

> > +	list management functions under zone->lru_lock().
> > +
> > +	One special function is mem_cgroup_isolate_pages(). This scans
> > +	memcg's private LRU and call __isolate_lru_page().
> > +	(By __isolate_lru_page(), the page is removed from private LRU, too)
> 
> 	                                                                too.)
> 
> >  
> > -  Tests for racy cases.
> >  
> > -  4.1 small limit to memcg.
> > +9. Typical Tests.
> > +
> > + Tests for racy cases.
> > +
> > + 9.1 Small limit to memcg.
> >  	When you do test to do racy case, it's good test to set memcg's limit
> >  	to be very small rather than GB. Many races found in the test under
> >  	xKB or xxMB limits.
> >  	(Memory behavior under GB and Memory behavior under MB shows very
> >  	 different situation.)
> >  
> > -  4.2 shmem
> > + 9.2 Shmem
> >  	Historically, memcg's shmem handling was poor and we saw some amount
> >  	of troubles here. This is because shmem is page-cache but can be
> >  	SwapCache. Test with shmem/tmpfs is always good test.
> >  
> > -  4.3 migration
> > + 9.3 Migration
> >  	For NUMA, migration is an another special. To do easy test, cpuset
> 
> 	                          another special {test | case}.
> 
ok.


> >  	is useful. Following is a sample script to do migration.
> >  
> > @@ -118,20 +263,20 @@ patterns tend to be racy.
> >  	G2_TASK=`cat ${G2}/tasks`
> >  	move_task "${G1_TASK}" ${G2} &
> >  	--
> > -  4.4 memory hotplug.
> > + 9.4 Memory hotplug.
> >  	memory hotplug test is one of good test.
> >  	to offline memory, do following.
> >  	# echo offline > /sys/devices/system/memory/memoryXXX/state
> >  	(XXX is the place of memory)
> >  	This is an easy way to test page migration, too.
> >  
> > - 4.5 mkdir/rmdir
> > + 9.5 mkdir/rmdir
> >  	When using hierarchy, mkdir/rmdir test should be done.
> >  	tests like following.
> 
> 	Use tests like the following:
> 
O.K.


> >  
> > -	#echo 1 >/opt/cgroup/01/memory/use_hierarchy
> > -	#mkdir /opt/cgroup/01/child_a
> > -	#mkdir /opt/cgroup/01/child_b
> > +	echo 1 >/opt/cgroup/01/memory/use_hierarchy
> > +	mkdir /opt/cgroup/01/child_a
> > +	mkdir /opt/cgroup/01/child_b
> >  
> >  	set limit to 01.
> >  	add limit to 01/child_b
> > @@ -143,3 +288,12 @@ patterns tend to be racy.
> >  	/opt/cgroup/01/child_c
> >  
> >  	running new jobs in new group is also good.
> > +
> > + 9.6 Mount with other subsystems.
> > +	Mounting with other subsystems is a good test because there ia a
> 
> 	                                                            is a
> 
will fix

> > +	race and lock dependency with other cgroup subsystems.
> > +
> > +	example)
> > +	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
> > +
> > +	and do task move, mkdir, rmdir etc...under this.
> > Index: mmotm-2.6.28-Dec03/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.28-Dec03.orig/mm/memcontrol.c
> > +++ mmotm-2.6.28-Dec03/mm/memcontrol.c
> > @@ -6,6 +6,10 @@
> >   * Copyright 2007 OpenVZ SWsoft Inc
> >   * Author: Pavel Emelianov <xemul@openvz.org>
> >   *
> > + * Documentations are available at
> 
>       Documentation is available at:
> 
> > + * 	Documentation/controllers/memory.txt
> > + * 	Documentation/controllers/memcg_test.txt
> > + *
> >   * This program is free software; you can redistribute it and/or modify
> >   * it under the terms of the GNU General Public License as published by
> >   * the Free Software Foundation; either version 2 of the License, or
> 
> 
> HTH.
> 
Yeah! Very helpful :) Thanks a lot.

-Kame



> ~Randy
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
