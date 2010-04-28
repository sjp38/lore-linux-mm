Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C71B86B01F3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 22:16:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S2GnhI015408
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 11:16:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 27A4B45DE50
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:16:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0769545DE4F
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:16:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EAE891DB803F
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:16:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 87DB51DB803B
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:16:48 +0900 (JST)
Date: Wed, 28 Apr 2010 11:12:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428111248.2797801c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100428014434.GM510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
	<20100427223004.GF8860@random.random>
	<20100427225852.GH8860@random.random>
	<20100428102928.a3b25066.kamezawa.hiroyu@jp.fujitsu.com>
	<20100428014434.GM510@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 03:44:34 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Apr 28, 2010 at 10:29:28AM +0900, KAMEZAWA Hiroyuki wrote:
> > Hmm..Mel's patch 2/3 takes vma->anon_vma->lock in vma_adjust(),
> > so this patch clears vma->anon_vma...
> 
> yep, it should be safe with patch 2 applied too. And I'm unsure why Mel's
> patch locks the anon_vma also when vm_start != start. See the other
> email I sent about patch 2.
> 
> > I think we can unlock this just after move_page_tables().
> 
> Checking this, I can't see where exactly is vma->vm_pgoff adjusted
> during the atomic section I protected with the anon_vma->lock?
> For a moment it looks like these pages become unmovable.
> 
The page can be replaced with migration_pte before the 1st vma_adjust.

The key is 
	(vma, page) <-> address <-> pte <-> page
relationship.

	vma_adjust() 
	(*)
	move_pagetables();
	(**)
	vma_adjust();

At (*), vma_address(vma, page) retruns a _new_ address. But pte is not
updated. This is ciritcal for rmap_walk. We're safe at (**).


> I guess this is why I thought initially that it was move_page_tables
> to adjust the page->index. If it doesn't then the vma->vm_pgoff has to
> be moved down of shift >>PAGE_SHIFT and it doesn't seem to be
> happening which is an unrelated bug.
> 

Anyway, I have no strong opinion about the placement of unlock(anon_vma->lock).

I wonder why we don't see this at testing memory-hotplug is because memory-hotplug
disables a new page allocation in the migration range. So, this exec() is hard to get
a page which can be migration target.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
