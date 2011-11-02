Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 329486B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 12:31:57 -0400 (EDT)
Date: Wed, 2 Nov 2011 17:30:56 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 1/2] vmscan: promote shared file mapped pages
Message-ID: <20111102163056.GG19965@redhat.com>
References: <20110808110658.31053.55013.stgit@localhost6>
 <CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
 <4E3FD403.6000400@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E3FD403.6000400@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Gene Heskett <gene.heskett@gmail.com>

On Mon, Aug 08, 2011 at 04:18:11PM +0400, Konstantin Khlebnikov wrote:
> Pekka Enberg wrote:
> >Hi Konstantin,
> >
> >On Mon, Aug 8, 2011 at 2:06 PM, Konstantin Khlebnikov
> ><khlebnikov@openvz.org>  wrote:
> >>Commit v2.6.33-5448-g6457474 (vmscan: detect mapped file pages used only once)
> >>greatly decreases lifetime of single-used mapped file pages.
> >>Unfortunately it also decreases life time of all shared mapped file pages.
> >>Because after commit v2.6.28-6130-gbf3f3bc (mm: don't mark_page_accessed in fault path)
> >>page-fault handler does not mark page active or even referenced.
> >>
> >>Thus page_check_references() activates file page only if it was used twice while
> >>it stays in inactive list, meanwhile it activates anon pages after first access.
> >>Inactive list can be small enough, this way reclaimer can accidentally
> >>throw away any widely used page if it wasn't used twice in short period.
> >>
> >>After this patch page_check_references() also activate file mapped page at first
> >>inactive list scan if this page is already used multiple times via several ptes.
> >>
> >>Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> >
> >Both patches seem reasonable but the changelogs don't really explain
> >why you're doing the changes. How did you find out about the problem?
> >Is there some workload that's affected? How did you test your changes?
> >
> 
> I found this while trying to fix degragation in rhel6 (~2.6.32) from rhel5 (~2.6.18).
> There a complete mess with >100 web/mail/spam/ftp containers,
> they share all their files but there a lot of anonymous pages:
> ~500mb shared file mapped memory and 15-20Gb non-shared anonymous memory.
> In this situation major-pagefaults are very costly, because all containers share the same page.
> In my load kernel created a disproportionate pressure on the file memory, compared with the anonymous,
> they equaled only if I raise swappiness up to 150 =)
> 
> These patches actually wasn't helped a lot in my problem,
> but I saw noticable (10-20 times) reduce in count and average time of major-pagefault in file-mapped areas.
> 
> Actually both patches are fixes for commit v2.6.33-5448-g6457474,
> because it was aimed at one scenario (singly used pages),
> but it breaks the logic in other scenarios (shared and/or executable pages)

I suspect that while saving shared/executable mapped file pages more
aggressively helps to some extent, the underlying problem is that we
tip the lru balance (comparing the recent_scanned/recent_rotated
ratios) in favor of file pages too much and in unexpected places.

For mapped file, we do:

add to lru:	recent_scanned++
cycle:		recent_scanned++
[ activate:	recent_scanned++, recent_rotated++ ]
[ deactivate:	recent_scanned++, recent_rotated++ ]
reclaim:	recent_scanned++

while for anon:

add to lru:	recent_scanned++, recent_rotated++
reactivate:	recent_scanned++, recent_rotated++
deactivate:	recent_scanned++, recent_rotated++
[ activate:	recent_scanned++, recent_rotated++ ]
[ deactivate:	recent_scanned++, recent_rotated++ ]
reclaim:	recent_scanned++

As you can see, even a long-lived file page tips the balance to the
file list twice: on creation and during the used-once detection.  A
thrashing file working set as in Konstantin's case will actually be
seen as a lucrative source of reclaimable pages.

Tipping the balance with each new file LRU page was meant to steer the
reclaim focus towards streaming IO pages and away from anonymous pages
but wouldn't it be easier to just not swap above a certain priority to
have the same effect?  With enough used-once file pages, we should not
reach that priority threshold.

Tipping the balance for inactive list rotation has been there from the
beginning, but I don't quite understand why.  It probably was not a
problem as the conditions for inactive cycling applied to both file
and anon equally, but with used-once detection for file and deferred
file writeback from direct reclaim, we tend to cycle more file pages
on the inactive list than anonymous ones.  Those rotated pages should
be a signal to favor file reclaim, though.

Here are three (currently under testing) RFC patches that 1. prevent
swapping above DEF_PRIORITY-2, 2. treat inactive list rotations to be
neutral wrt. the inter-LRU balance, and 3. revert the file list boost
on lru addition.

The result looks like this:

file:

add to lru:
[ activate:	recent_scanned++, recent_rotated++ ]
[ deactivate:	recent_scanned++, recent_rotated++ ]
reclaim:	recent_scanned++

mapped file:

add to lru:
cycle:		recent_scanned++, recent_rotated++
[ activate:	recent_scanned++, recent_rotated++ ]
[ deactivate:	recent_scanned++, recent_rotated++ ]
reclaim:	recent_scanned++

anon:
add to lru:	recent_scanned++, recent_rotated++
reactivate:	recent_scanned++, recent_rotated++
deactivate:	recent_scanned++, recent_rotated++
[ activate:	recent_scanned++, recent_rotated++ ]
[ deactivate:	recent_scanned++, recent_rotated++ ]
reclaim:	recent_scanned++

As you can see, this still behaves under the assumption that refaults
from swap are more costly than from the fs, but we keep considering
anonymous pages when the file working set is thrashing.

What do reclaim people think about this?

Konstantin, would you have the chance to try this set directly with
your affected workload if nobody spots any obvious problems?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
