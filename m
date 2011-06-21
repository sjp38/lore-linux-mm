Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7E56B0173
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 05:36:48 -0400 (EDT)
Date: Tue, 21 Jun 2011 10:36:40 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: make the threshold of enabling THP configurable
Message-ID: <20110621093640.GD9396@suse.de>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <1308587683-2555-2-git-send-email-amwang@redhat.com>
 <20110620165955.GB9396@suse.de>
 <4DFF8050.9070201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4DFF8050.9070201@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 01:16:00AM +0800, Cong Wang wrote:
> ??? 2011???06???21??? 00:59, Mel Gorman ??????:
> >On Tue, Jun 21, 2011 at 12:34:29AM +0800, Amerigo Wang wrote:
> >>Don't hard-code 512M as the threshold in kernel, make it configruable,
> >>and set 512M by default.
> >>
> >
> >I'm not seeing the gain here either. This is something that is going to
> >be set by distributions and probably never by users. If the default of
> >512 is incorrect, what should it be? Also, the Kconfig help message has
> >spelling errors.
> >
> 
> Sorry for spelling errors, I am not an English speaker.
> 
> Hard-coding is almost never a good thing in kernel, enforcing 512
> is not good either. Since the default is still 512, I don't think this
> will affect much users.
> 
> I do agree to improve the help message, like Dave mentioned in his reply,
> but I don't like enforcing a hard-coded number in kernel.
> 
> BTW, why do you think 512 is suitable for *all* users?
> 

Fragmentation avoidance benefits from tuning min_free_kbytes to a higher
value and minimising fragmentation-related problems is crucial if THP is
to allocate its necessary pages.

THP tunes min_free_kbytes automatically and this value is in part
related to the number of zones. At 512M on a single node machine, the
recommended min_free_kbytes is close to 10% of memory which is barely
tolerable as it is. At 256M, it's 17%, at 128M, it's 34% so tuning the
value lower has diminishing returns as the performance impact of giving
up such a high percentage of free memory is not going to be offset by
reduced TLB misses. Tuning it to a higher value might make some sense
if the higher min_free_kbytes was a problem but it would be much more
rational to tune it as a sysctl than making it a compile-time decision.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
