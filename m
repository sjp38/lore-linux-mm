Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEC3B6B0260
	for <linux-mm@kvack.org>; Tue,  4 May 2010 06:32:34 -0400 (EDT)
Date: Tue, 4 May 2010 11:32:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
	and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100504103213.GB20979@csn.ul.ie>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie> <20100429162120.GC22108@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100429162120.GC22108@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 29, 2010 at 06:21:20PM +0200, Andrea Arcangeli wrote:
> Hi Mel,
> 
> did you see my proposed fix?

I did when I got back - sorry for the delay. The patchset I sent out was what
I had fully tested and was confident worked. I picked up the version of the
patch that was sent to Linus by Rik for merging.

> I'm running with it applied, I'd be
> interested if you can test it.

Unfortunately, the same bug triggers after about 18 minutes. The objective of
your fix is very simple - have a VMA covering the new range so that rmap can
find it. However, no lock is held during move_page_tables() because of the
need to call the page allocator. Due to the lack of locking, is it possible
that something like the following is happening?

Exec Process				Migration Process
begin move_page_tables
					begin rmap walk
					take anon_vma locks
					find new location of pte (do nothing)
copy migration pte to new location
#### Bad PTE now in place
					find old location of pte
					remove old migration pte
					release anon_vma locks
remove temporary VMA
some time later, bug on migration pte

Even with the care taken, a migration PTE got copied and then left behind. What
I haven't confirmed at this point is if the ordering of the walk in "migration
process" is correct in the above scenario. The order is important for
the race as described to happen.

If the above is wrong, there is still a race somewhere else.

> Surely it will also work for new
> anon-vma code in upstream, because at that point there's just 1
> anon-vma and nothing else attached to the vma.
> 
> http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=6efa1dfa5152ef8d7f26beb188d6877525a9dd03
> 
> I think it's wrong to try to handle the race in rmap walk by making
> magic checks on vm_flags VM_GROWSDOWN|GROWSUP and
> vma->vm_mm->map_count == 1,

How bad is that magic check really? Is there a scenario when it's
the wrong thing to do?

I agree that migration skipping specific pages of the temporary stack is
unfortunate and having exec-aware informtion in migration is an odd dependency
at best. On the other hand, it's not as bad as skipping other regions as exec
will finish and allow the pages to be moved again. The impact to compaction
or transparent support would appear to be minimal.

> when we can fix it fully and simply in
> exec.c by indexing two vmas in the same anon-vma with a different
> vm_start so the pages will be found at all times by the rmap_walk.
> 

If it can be simply fixed in exec, then I'll agree. Your patch looked simple
but unfortunately it doesn't fix the problem and it does introduce another
call to kmalloc() in the exec path. It's probably something that would only
be noticed by microbenchmarks though so I'm less concerned about that aspect.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
