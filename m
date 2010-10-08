Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DEEF46B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 21:24:23 -0400 (EDT)
Date: Fri, 8 Oct 2010 10:12:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v2] memcg: reduce lock time at move charge (Was Re:
 [PATCH 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-Id: <20101008101222.1aab03ae.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101007161454.84570cf9.akpm@linux-foundation.org>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007162811.c3a35be9.nishimura@mxp.nes.nec.co.jp>
	<20101007164204.83b207c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007170405.27ed964c.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007161454.84570cf9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Oct 2010 16:14:54 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 7 Oct 2010 17:04:05 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Now, at task migration among cgroup, memory cgroup scans page table and moving
> > account if flags are properly set.
> > 
> > The core code, mem_cgroup_move_charge_pte_range() does
> > 
> >  	pte_offset_map_lock();
> > 	for all ptes in a page table:
> > 		1. look into page table, find_and_get a page
> > 		2. remove it from LRU.
> > 		3. move charge.
> > 		4. putback to LRU. put_page()
> > 	pte_offset_map_unlock();
> > 
> > for pte entries on a 3rd level? page table.
> > 
> > This pte_offset_map_lock seems a bit long. This patch modifies a rountine as
> > 
> > 	for 32 pages: pte_offset_map_lock()
> > 		      find_and_get a page
> > 		      record it
> > 		      pte_offset_map_unlock()
> > 	for all recorded pages
> > 		      isolate it from LRU.
> > 		      move charge
> > 		      putback to LRU
> > 	for all recorded pages
> > 		      put_page()
> 
> The patch makes the code larger, more complex and slower!
> 
Before this patch:
   text    data     bss     dec     hex filename
  27163   11782    4100   43045    a825 mm/memcontrol.o

After this patch:
   text    data     bss     dec     hex filename
  27307   12294    4100   43701    aab5 mm/memcontrol.o

hmm, allocating mc.target[] statically might be bad, but I'm now wondering
whether I could allocate mc itself dynamically(I'll try).

> I do think we're owed a more complete description of its benefits than
> "seems a bit long".  Have problems been observed?  Any measurements
> taken?
> 
IIUC, this patch is necessary for "[PATCH] memcg: lock-free clear page writeback"
later, but I agree we should describe it.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
