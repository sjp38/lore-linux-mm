Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 360B66B01F7
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 02:42:17 -0400 (EDT)
Date: Tue, 16 Mar 2010 17:42:09 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: lockdep page lock
Message-ID: <20100316064209.GK2869@laptop>
References: <20100315155859.GE2869@laptop>
 <20100316062032.GB22651@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100316062032.GB22651@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 16, 2010 at 07:20:32AM +0100, Ingo Molnar wrote:
> 
> * Nick Piggin <npiggin@suse.de> wrote:
> 
> > Page lock has very complex dependencies, so it would be really nice to add 
> > lockdep support for it.
> 
> Just wondering - has your patch shown any suspect areas of code already, in 
> the testing you did?

Not yet. Although I only did basic stress testing with tmpfs and ext3 so
far. It would get even further useful for fs developers combined with
annotating more bit locks like buffer lock.

BTW. I tried adding a might_fault() under page lock to see the infamous
old page_lock -> mmap_sem deadlock, but it didn't warn. Explicitly doing
a down_write/up_write of mmap_sem did warn. But it took a while to build
the required chains, so I may have just been unlucky.

 
> Maybe it should be test-driven for a while, in a non-append-only tree such as 
> -mm, to see whether it's finding real bugs.

I think it should be very useful for filesystem developers. It doesn't
seem too intrusive (and I will make it less so, by not open-coding the
mutex_release/mutex_acquire pairs when changing page mapping).

Filesystems and mm/vfs/fs lock interactions may be the most complex in
the kernel...

If you are worried about struct page bloat, it's already getting bloated
by ptl spinlock in there. But it could always be configurable.

No it isn't ready for -mm yet, let alone an append-only tree, I just
wanted to get opinions from mm and fs (and lockdep) people.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
