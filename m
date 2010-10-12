Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 718AD6B00A3
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 23:39:27 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9C3ZBDw025747
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 21:35:11 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9C3dKVL220152
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 21:39:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9C3dJoR030604
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 21:39:20 -0600
Date: Tue, 12 Oct 2010 09:09:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] memcg: reduce lock time at move charge (Was Re:
 [PATCH 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-ID: <20101012033915.GA25875@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
 <20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
 <20101007162811.c3a35be9.nishimura@mxp.nes.nec.co.jp>
 <20101007164204.83b207c6.kamezawa.hiroyu@jp.fujitsu.com>
 <20101007170405.27ed964c.kamezawa.hiroyu@jp.fujitsu.com>
 <20101007161454.84570cf9.akpm@linux-foundation.org>
 <20101008133712.2a836331.kamezawa.hiroyu@jp.fujitsu.com>
 <20101007215556.21412ae6.akpm@linux-foundation.org>
 <20101008141201.c1e3a4e2.kamezawa.hiroyu@jp.fujitsu.com>
 <20101008194131.20b44a9d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101008194131.20b44a9d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-08 19:41:31]:

> On Fri, 8 Oct 2010 14:12:01 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > Sure.  It walks the same data three times, potentially causing
> > > thrashing in the L1 cache.
> > 
> > Hmm, make this 2 times, at least.
> > 
> How about this ?
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Presently, at task migration among cgroups, memory cgroup scans page tables and
> moves accounting if flags are properly set.
> 
> 
> The core code, mem_cgroup_move_charge_pte_range() does
> 
>  	pte_offset_map_lock();
> 	for all ptes in a page table:
> 		1. look into page table, find_and_get a page
> 		2. remove it from LRU.
> 		3. move charge.
> 		4. putback to LRU. put_page()
> 	pte_offset_map_unlock();
> 
> for pte entries on a 3rd level? page table.
> 
> As a planned updates, we'll support dirty-page accounting. Because move_charge()
> is highly race, we need to add more check in move_charge.
> For example, lock_page();-> wait_on_page_writeback();-> unlock_page();
> is an candidate for new check.
>


Is this a change to help dirty limits or is it a generic bug fix.
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
