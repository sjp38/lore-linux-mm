Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3C36B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 22:19:23 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id w128so38810800pfb.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 19:19:23 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id fk1si934747pad.35.2016.02.28.19.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 19:19:22 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id fl4so83946416pad.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 19:19:22 -0800 (PST)
Date: Sun, 28 Feb 2016 19:19:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/5] oom reaper: handle mlocked pages
In-Reply-To: <20160223132157.GD14178@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1602281844180.3975@eggly.anvils>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org> <1454505240-23446-3-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1602221734140.4688@chino.kir.corp.google.com> <20160223132157.GD14178@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 23 Feb 2016, Michal Hocko wrote:
> On Mon 22-02-16 17:36:07, David Rientjes wrote:
> > 
> > Are we concerned about munlock_vma_pages_all() taking lock_page() and 
> > perhaps stalling forever, the same way it would stall in exit_mmap() for 
> > VM_LOCKED vmas, if another thread has locked the same page and is doing an 
> > allocation?
> 
> This is a good question. I have checked for that particular case
> previously and managed to convinced myself that this is OK(ish).
> munlock_vma_pages_range locks only THP pages to prevent from the
> parallel split-up AFAICS.

I think you're mistaken on that: there is also the lock_page()
on every page in Phase 2 of __munlock_pagevec().

> And split_huge_page_to_list doesn't seem
> to depend on an allocation. It can block on anon_vma lock but I didn't
> see any allocation requests from there either. I might be missing
> something of course. Do you have any specific path in mind?
> 
> > I'm wondering if in that case it would be better to do a 
> > best-effort munlock_vma_pages_all() with trylock_page() and just give up 
> > on releasing memory from that particular vma.  In that case, there may be 
> > other memory that can be freed with unmap_page_range() that would handle 
> > this livelock.

I agree with David, that we ought to trylock_page() throughout munlock:
just so long as it gets to do the TestClearPageMlocked without demanding
page lock, the rest is the usual sugarcoating for accurate Mlocked stats,
and leave the rest for reclaim to fix up.

> 
> I have tried to code it up but I am not really sure the whole churn is
> really worth it - unless I am missing something that would really make
> the THP case likely to hit in the real life.

Though I must have known about it forever, it was a shock to see all
those page locks demanded in exit, brought home to us a week or so ago.

The proximate cause in this case was my own change, to defer pte_alloc
to suit huge tmpfs: it had not previously occurred to me that I was
now doing the pte_alloc while __do_fault holds page lock.  Bad Hugh.
But change not yet upstream, so not so urgent for you.

>From time immemorial, free_swap_and_cache() and free_swap_cache() only
ever trylock a page, precisely so that they never hold up munmap or exit
(well, if I looked harder, I might find lock ordering reasons too).

> 
> Just for the reference this is what I came up with (just compile tested).

I tried something similar internally (on an earlier kernel).  Like
you I've set that work aside for now, there were quicker ways to fix
the issue at hand.  But it does continue to offend me that munlock
demands all those page locks: so if you don't get back to it before me,
I shall eventually.

I didn't understand why you complicated yours with the "enforce"
arg to munlock_vma_pages_range(): why not just trylock in all cases?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
