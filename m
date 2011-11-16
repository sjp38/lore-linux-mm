Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BB8076B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 08:31:04 -0500 (EST)
Date: Wed, 16 Nov 2011 14:30:56 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111116133056.GC3306@redhat.com>
References: <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
 <20111111101414.GJ3083@suse.de>
 <20111114154408.10de1bc7.akpm@linux-foundation.org>
 <20111115132513.GF27150@suse.de>
 <alpine.DEB.2.00.1111151303230.23579@chino.kir.corp.google.com>
 <20111115234845.GK27150@suse.de>
 <alpine.DEB.2.00.1111151554190.3781@chino.kir.corp.google.com>
 <20111116041350.GA3306@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111116041350.GA3306@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 16, 2011 at 05:13:50AM +0100, Andrea Arcangeli wrote:
> After checking my current thp vmstat I think Andrew was right and we
> backed out for a good reason before. I'm getting significantly worse
> success rate, not sure why it was a small reduction in success rate
> but hey I cannot exclude I may have broke something with some other
> patch. I've been running it together with a couple more changes. If
> it's this change that reduced the success rate, I'm afraid going
> always async is not ok.

I wonder if the high failure rate when shutting off "sync compaction"
and forcing only "async compaction" for THP (your patch queued in -mm)
is also because of ISOLATE_CLEAN being set in compaction from commit
39deaf8. ISOLATE_CLEAN skipping PageDirty means all tmpfs/anon pages
added to swapcache (or removed from swapcache which sets the dirty bit
on the page because the pte may be mapped clean) are skipped entirely
by async compaction for no good reason. That can't possibly be ok,
because those don't actually require any I/O or blocking to be
migrated. PageDirty is a "blocking/IO" operation only for filebacked
pages. So I think we must revert 39deaf8, instead of cleaning it up
with my cleanup posted in Message-Id 20111115020831.GF4414@redhat.com .

ISOLATED_CLEAN still looks right for may_writepage, for reclaim dirty
bit set on the page is a I/O event, for migrate it's not if it's
tmpfs/anon.

Did you run your compaction tests with some swap activity?

Reducing the async compaction effectiveness while there's some swap
activity then also leads in more frequently than needed running sync
compaction and page reclaim.

I'm hopeful however that by running just 2 passes of migrate_pages
main loop with the "avoid overwork in migrate sync mode" patch, we can
fix the excessive hanging. If that works number of passes could
actually be a tunable, and setting it to 1 (instead of 2) would then
provide 100% "async compaction" behavior again. And if somebody
prefers to stick to 10 he can... so then he can do trylock pass 0,
lock_page pass1, wait_writeback pass2, wait pin pass3, finally migrate
pass4. (something 2 passes alone won't allow). So making the migrate
passes/force-threshold tunable (maybe only for the new sync=2
migration mode) could be good idea. Or we could just return to sync
true/false and have the migration tunable affect everything but that
would alter the reliability of sys_move_pages and other numa things
too, where I guess 10 passes are ok. This is why I added a sync=2 mode
for migrate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
