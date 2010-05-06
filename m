Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3E266B027B
	for <linux-mm@kvack.org>; Thu,  6 May 2010 09:46:12 -0400 (EDT)
Date: Thu, 6 May 2010 14:45:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100506134550.GA8704@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org> <20100505155454.GT20979@csn.ul.ie> <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org> <4BE2C6E8.2030609@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BE2C6E8.2030609@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 06, 2010 at 09:40:56AM -0400, Rik van Riel wrote:
> On 05/05/2010 01:34 PM, Linus Torvalds wrote:
>
>>   - you always lock the _deepest_ anon_vma you can find.
>
> The emphasis should be on "always" :)
>
>> That means just a single lock. And the "deepest" anon_vma is well-defined
>> for all anon_vma's, because each same_anon_vma chain is always rooted in
>> the original anon_vma that caused it.
>
> It should work, but only if we always take the deepest
> anon_vma lock.
>
> Not just in the migration code, but also in mmap, munmap,
> mprotect (for split_vma), expand_stack, etc...
>
> Otherwise we will still not provide exclusion of migrate
> vs. those events.
>

Are you sure?

I thought this as well but considered a situation something like

root anon_vma          <--- rmap_walk starts here
     anon_vma a
     anon_vma b
     anon_vma c        <--- an munmap/mmap/mprotect/etc here
     anon_vma d
     anon_vma e

The rmap_walk takes the root lock and then locks a, b, c, d and e as it
walks along.

The mSomething event happens on c and takes the lock

if rmap_walk gets there first, it takes the lock and the mSomething
event waits until the full rmap_walk is complete (delayed slightly but
no biggie).

if mSomething gets there first, rmap_walk will wait on taking the lock.
Again, there could be some delays but no biggie.

What am I missing?

> I'm guessing that means changing both anon_vma_lock and
> page_lock_anon_vma to always take the deepest anon_vma
> lock - not introducing a new function that is only called
> by the migration code.
>

That would be the case all right but I'd prefer to have PeterZ's patches
that do full reference counting of anon_vma first instead of introducing
RCU to those paths.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
