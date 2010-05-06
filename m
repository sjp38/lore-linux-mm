Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F35D6200AA
	for <linux-mm@kvack.org>; Thu,  6 May 2010 19:56:26 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o46NuOUx002879
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 08:56:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BE5F45DE5A
	for <linux-mm@kvack.org>; Fri,  7 May 2010 08:56:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AEDBF45DE59
	for <linux-mm@kvack.org>; Fri,  7 May 2010 08:56:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 90E3A1DB8043
	for <linux-mm@kvack.org>; Fri,  7 May 2010 08:56:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BD1F1DB8062
	for <linux-mm@kvack.org>; Fri,  7 May 2010 08:56:23 +0900 (JST)
Date: Fri, 7 May 2010 08:52:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100507085219.5821f721.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100506094621.GZ20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
	<1273065281-13334-2-git-send-email-mel@csn.ul.ie>
	<20100506163837.bf6587ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20100506094621.GZ20979@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 May 2010 10:46:21 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, May 06, 2010 at 04:38:37PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed,  5 May 2010 14:14:40 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > vma_adjust() is updating anon VMA information without locks being taken.
> > > In contrast, file-backed mappings use the i_mmap_lock and this lack of
> > > locking can result in races with users of rmap_walk such as page migration.
> > > vma_address() can return -EFAULT for an address that will soon be valid.
> > > For migration, this potentially leaves a dangling migration PTE behind
> > > which can later cause a BUG_ON to trigger when the page is faulted in.
> > > 
> > > With the recent anon_vma changes, there can be more than one anon_vma->lock
> > > to take in a anon_vma_chain but a second lock cannot be spinned upon in case
> > > of deadlock. The rmap walker tries to take locks of different anon_vma's
> > > but if the attempt fails, locks are released and the operation is restarted.
> > > 
> > > For vma_adjust(), the locking behaviour prior to the anon_vma is restored
> > > so that rmap_walk() can be sure of the integrity of the VMA information and
> > > lists when the anon_vma lock is held. With this patch, the vma->anon_vma->lock
> > > is taken if
> > > 
> > > 	a) If there is any overlap with the next VMA due to the adjustment
> > > 	b) If there is a new VMA is being inserted into the address space
> > > 	c) If the start of the VMA is being changed so that the
> > > 	   relationship between vm_start and vm_pgoff is preserved
> > > 	   for vma_address()
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > I'm sorry I couldn't catch all details but can I make a question ?
> 
> Of course.
> 
> > Why seq_counter is bad finally ? I can't understand why we have
> > to lock anon_vma with risks of costs, which is mysterious struct now.
> > 
> > Adding a new to mm_struct is too bad ?
> > 
> 
> It's not the biggest problem. I'm not totally against this approach but
> some of the problems I had were;
> 
> 1. It introduced new locking. anon_vmas would be covered by RCU,
>    spinlocks and seqlock - each of which is used in different
>    circumstances. The last patch I posted doesn't drastically
>    alter the locking. It just says that if you are taking multiple
>    locks, you must start from the "root" anon_vma.
> 
ok. I just thought a lock-system which we have to find "which lock should I
take" is not very good.


> 2. I wasn't sure if it was usable by transparent hugepage support.
>    Andrea?

Hmm.

> 
> 3. I had similar concerns about it livelocking like the
>    trylock-and-retry although it's not terrible.
> 
Agreed.

> 4. I couldn't convince myself at the time that it wasn't possible for
>    someone to manipulate the list while it was being walked and a VMA would be
>    missed. For example, if fork() was called while rmap_walk was happening,
>    were we guaranteed to find the VMAs added to the list?  I admit I didn't
>    fully investigate this question at the time as I was still getting to
>    grips with anon_vma. I can reinvestigate if you think the "lock the root
>    anon_vma first when taking multiple locks" has a bad cost that is
>    potentially resolved with seqcounter
> 
If no regressions in measurement, I have no objections.

> 5. It added a field to mm_struct. It's the smallest of concerns though.
> 
> Do you think it's a better approach and should be revisited?
> 
> 

If everyone think seqlock is simple, I think it should be. But it seems you all are
going ahead with anon_vma->lock approach. 
(Basically, it's ok to me if it works. We may be able to make it better in later.)

I'll check your V7.

Thank you for answering.

Regards,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
