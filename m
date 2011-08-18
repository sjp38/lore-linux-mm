Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2F268900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 05:09:25 -0400 (EDT)
Date: Thu, 18 Aug 2011 11:09:06 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] vmscan: promote shared file mapped pages
Message-ID: <20110818090906.GA2045@cmpxchg.org>
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
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

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

How much unmapped cache do you have around in this scenario?

> In this situation major-pagefaults are very costly, because all containers share the same page.
> In my load kernel created a disproportionate pressure on the file memory, compared with the anonymous,
> they equaled only if I raise swappiness up to 150 =)
> 
> These patches actually wasn't helped a lot in my problem,
> but I saw noticable (10-20 times) reduce in count and average time of major-pagefault in file-mapped areas.

If disabling the used-once detection for shared executable pages does
not help, then the real reason for the regression you observe seems to
be a different one.

Reduced major faults in file mapped areas without other context don't
have to be a good sign per se.  Which memory was reclaimed instead?
Did swapping increase?

It would be good to find a fix that actually helps your workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
