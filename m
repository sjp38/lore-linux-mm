Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 296A96001DA
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 21:27:08 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0J2R5Qv010851
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 19 Jan 2010 11:27:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5214945DE53
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 11:27:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 33D0645DE50
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 11:27:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FD4E1DB8037
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 11:27:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AB8C11DB8038
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 11:27:04 +0900 (JST)
Date: Tue, 19 Jan 2010 11:23:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/8] vmalloc: simplify vread()/vwrite()
Message-Id: <20100119112343.04f4eff5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100119013303.GA12513@localhost>
References: <20100113135305.013124116@intel.com>
	<20100113135957.833222772@intel.com>
	<20100114124526.GB7518@laptop>
	<20100118133512.GC721@localhost>
	<20100118142359.GA14472@laptop>
	<20100119013303.GA12513@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jan 2010 09:33:03 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:
> > The whole thing looks stupid though, apparently kmap is used to avoid "the
> > lock". But the lock is already held. We should just use the vmap
> > address.
> 
> Yes. I wonder why Kame introduced kmap_atomic() in d0107eb07 -- given
> that he at the same time fixed the order of removing vm_struct and
> vmap in dd32c279983b.
> 
Hmm...I must check my thinking again before answering..

vmalloc/vmap is constructed by 2 layer.
	- vmalloc layer....guarded by vmlist_lock.
	- vmap layer   ....gurderd by purge_lock. etc.

Now, let's see how vmalloc() works. It does job in 2 steps.
vmalloc():
  - allocate vmalloc area to the list under vmlist_lock.
	- map pages.
vfree()
  - free vmalloc area from the list under vmlist_lock.
	- unmap pages under purge_lock.

Now. vread(), vwrite() just take vmlist_lock, doesn't take purge_lock().
It walks page table and find pte entry, page, kmap and access it.

Oh, yes. It seems it's safe without kmap. But My concern is percpu allocator.

It uses get_vm_area() and controls mapped pages by themselves and
map/unmap pages by with their own logic. vmalloc.c is just used for
alloc/free virtual address. 

Now, vread()/vwrite() just holds vmlist_lock() and walk page table
without no guarantee that the found page is stably mapped. So, I used kmap.

If I miss something, I'm very sorry to add such kmap.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
