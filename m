Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B6DBB6B0085
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 00:42:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o984gaOF019678
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 8 Oct 2010 13:42:37 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A5EA945DE55
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:42:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 808CB45DE4E
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:42:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C9E31DB8055
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:42:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0900B1DB8050
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:42:36 +0900 (JST)
Date: Fri, 8 Oct 2010 13:37:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] memcg: reduce lock time at move charge (Was Re:
 [PATCH 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-Id: <20101008133712.2a836331.kamezawa.hiroyu@jp.fujitsu.com>
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
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
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

Slower ?

> I do think we're owed a more complete description of its benefits than
> "seems a bit long".  Have problems been observed?  Any measurements
> taken?
> 

I'll rewrite the whole patch against today's mmotom.

Thanks,
-Kame

> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
