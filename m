Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 490B16B01E3
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 05:03:52 -0400 (EDT)
Date: Fri, 23 Apr 2010 10:03:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100423090329.GI30306@csn.ul.ie>
References: <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com> <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com> <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <20100422141404.GA30306@csn.ul.ie> <p2y28c262361004220718m3a5e3e2ekee1fef7ebdae8e73@mail.gmail.com> <20100422154003.GC30306@csn.ul.ie> <20100422192923.GH30306@csn.ul.ie> <alpine.DEB.2.00.1004221439040.5023@router.home> <20100423085203.b43d1cb3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100423085203.b43d1cb3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 08:52:03AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 22 Apr 2010 14:40:46 -0500 (CDT)
> Christoph Lameter <cl@linux.com> wrote:
> 
> > On Thu, 22 Apr 2010, Mel Gorman wrote:
> > 
> > > vma_adjust() is updating anon VMA information without any locks taken.
> > > In constract, file-backed mappings use the i_mmap_lock. This lack of
> > > locking can result in races with page migration. During rmap_walk(),
> > > vma_address() can return -EFAULT for an address that will soon be valid.
> > > This leaves a dangling migration PTE behind which can later cause a
> > > BUG_ON to trigger when the page is faulted in.
> > 
> > Isnt this also a race with reclaim /  swap?
> > 
> Yes, it's also race in reclaim/swap ...
>   page_referenced()
>   try_to_unmap().
>   rmap_walk()  <==== we hit this case.
> 
> But above 2 are not considered to be critical.
> 
> I'm not sure how this race affect KSM.
> 

I'm not that familiar with KSM but took a look through. Mostly,
accessing the VMA is protected by the mmap_sem with the exception of
rmap_walk_ksm. It needs similar protection for accessing the VMA than
rmap_walk_anon does.

Specifically, this part

                list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
                        vma = vmac->vma;
                        if (rmap_item->address < vma->vm_start ||
                            rmap_item->address >= vma->vm_end)
                                continue;

needs to acquire the vma->anon_vma lock if it differs or in your case
call something similar to vma_address_safe.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
