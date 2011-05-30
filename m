Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BDA7A6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 13:54:05 -0400 (EDT)
Date: Mon, 30 May 2011 19:53:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110530175334.GI19505@random.random>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110530143109.GH19505@random.random>
 <20110530153748.GS5044@csn.ul.ie>
 <20110530165546.GC5118@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110530165546.GC5118@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Mon, May 30, 2011 at 05:55:46PM +0100, Mel Gorman wrote:
> Even with drift issues, -1 there should be "impossible". Assuming this
> is a zoneinfo file, that figure is based on global_page_state() which
> looks like

The two cases reproducing this long hang in D state, had from SMP=n
PREEMPT=y. Clearly not common config these days. Also it didn't seem
apparent that any task was running in a code path that kept pages
isolated.

> unsigned long, and callers are using unsigned long, is there any
> possibility the "if (x < 0)" is being optimised out? If you aware

It was eliminated by cpp.

> of users reporting this problem (like the users in thread "iotop:
> khugepaged at 99.99% (2.6.38.3)"), do you know if they had a particular
> compiler in common?

I had no reason to worry about the compiler yet but that's always good
idea to keep in mind. The thread were the bug is reported is the
"iotop" one you mentioned, and there's a tarball attached to one of
the last emails of the thread with the debug data I grepped. It was
/proc/zoneinfo file yes. That's the file I asked when I noticed
something had to be wrong with too_many_isolated and I expected either
nr_isolated or nr_inactive going wrong, it turned out it was
nr_isolated (apparently, I don't have full picture on the problem
yet). I added you in CC to a few emails but you weren't in all
replies.

The debug data you can find on lkml in this email: Message-Id:
<201105232005.56840.johannes.hirte@fem.tu-ilmenau.de>.

The other relevant sysrq+t here http://pastebin.com/raw.php?i=VG28YRbi

better save the latter (I did) as I'm worried it has a timeout on it.

Your patch was for reports with CONFIG_SMP=y? I'd prefer to clear out
this error before improving the too_many_isolated, in fact while
reviewing this code I was not impressed by too_many_isolated. For
vmscan.c if there's an huge nr_active* list and a tiny nr_inactive
(like after a truncate of filebacked pages or munmap of anon memory)
there's no reason to stall, it's better to go ahead and let it refile
more active pages. The too_many_isolated in compaction.c looks a whole
lot better than the vmscan.c one as that takes into account the active
pages too... But I refrained to make any change in this area as I
don't think the bug is in too_many_isolated itself.

I noticed the count[] array is unsigned int, but it looks ok
(especially for 32bit ;) because the isolation is limited.

Both bugs were reported on 32bit x86 UP builds with PREEMPT=y. The
stat accounting seem to use atomics on UP so irqs on off or
PREEMPT=y/n shouldn't matter if the increment is 1 insn long (plus no
irq code should ever mess with nr_isolated)... If it wasn't atomic and
irqs or preempt aren't disabled it could be preempt. To avoid
confusion: it's not proven that PREEMPT is related, it may be an
accident both .config had it on. I'm also unsure why it moves from
-1,0,1 I wouldn't expect a single page to be isolated like -1 pages to
be isolated, it just looks weird...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
