Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 039616B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 19:56:07 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3RNu554012795
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 08:56:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 591CB45DE52
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 08:56:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 29B4A45DE51
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 08:56:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0431E1DB803E
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 08:56:05 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A083A1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 08:56:04 +0900 (JST)
Date: Wed, 28 Apr 2010 08:52:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm,migration: During fork(), wait for migration to
 end if migration PTE is encountered
Message-Id: <20100428085203.4336b761.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100427222245.GE8860@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-2-git-send-email-mel@csn.ul.ie>
	<20100427222245.GE8860@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 00:22:45 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> Ok I had a first look:
> 
> On Tue, Apr 27, 2010 at 10:30:50PM +0100, Mel Gorman wrote:
> > 	CPUA			CPU B
> > 				do_fork()
> > 				copy_mm() (from process 1 to process2)
> > 				insert new vma to mmap_list (if inode/anon_vma)
> 
> Insert to the tail of the anon_vma list...
> 
> > 	pte_lock(process1)
> > 	unmap a page
> > 	insert migration_entry
> > 	pte_unlock(process1)
> > 
> > 	migrate page copy
> > 				copy_page_range
> > 	remap new page by rmap_walk()
> 
> rmap_walk will walk process1 first! It's at the head, the vmas with
> unmapped ptes are at the tail so process1 is walked before process2.
> 
> > 	pte_lock(process2)
> > 	found no pte.
> > 	pte_unlock(process2)
> > 				pte lock(process2)
> > 				pte lock(process1)
> > 				copy migration entry to process2
> > 				pte unlock(process1)
> > 				pte unlokc(process2)
> > 	pte_lock(process1)
> > 	replace migration entry
> > 	to new page's pte.
> > 	pte_unlock(process1)
> 
> rmap_walk has to lock down process1 before process2, this is the
> ordering issue I already mentioned in earlier email. So it cannot
> happen and this patch is unnecessary.
> 
> The ordering is fundamental and as said anon_vma_link already adds new
> vmas to the _tail_ of the anon-vma. And this is why it has to add to
> the tail. If anon_vma_link would add new vmas to the head of the list,
> the above bug could materialize, but it doesn't so it cannot happen.
> 
> In mainline anon_vma_link is called anon_vma_chain_link, see the
> list_add_tail there to provide this guarantee.
> 
> Because process1 is walked first by CPU A, the migration entry is
> replaced by the final pte before copy-migration-entry
> runs. Alternatively if copy-migration-entry runs before before
> process1 is walked, the migration entry will be copied and found in
> process 2.
> 

I already explained this doesn't happend and said "I'm sorry".

But considering maintainance, it's not necessary to copy migration ptes
and we don't have to keep a fundamental risks of migration circus.

So, I don't say "we don't need this patch."

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
