Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 75BA06B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:40:07 -0500 (EST)
Date: Mon, 19 Dec 2011 14:40:02 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/11] Reduce compaction-related stalls and improve
 asynchronous migration of dirty pages v6
Message-ID: <20111219144002.GN3487@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <20111216145600.908fc77e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111216145600.908fc77e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 16, 2011 at 02:56:00PM -0800, Andrew Morton wrote:
> On Wed, 14 Dec 2011 15:41:22 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Short summary: There are severe stalls when a USB stick using VFAT
> > is used with THP enabled that are reduced by this series. If you are
> > experiencing this problem, please test and report back and considering
> > I have seen complaints from openSUSE and Fedora users on this as well
> > as a few private mails, I'm guessing it's a widespread issue. This
> > is a new type of USB-related stall because it is due to synchronous
> > compaction writing where as in the past the big problem was dirty
> > pages reaching the end of the LRU and being written by reclaim.
> > 
> > Am cc'ing Andrew this time and this series would replace
> > mm-do-not-stall-in-synchronous-compaction-for-thp-allocations.patch.
> > I'm also cc'ing Dave Jones as he might have merged that patch to Fedora
> > for wider testing and ideally it would be reverted and replaced by
> > this series.
> 
> So it appears that the problem is painful for distros and users and
> that we won't have this fixed until 3.2 at best, and that fix will be a
> difficult backport for distributors of earlier kernels.
> 

It is only difficult because the series "Do not call ->writepage[s]
from direct reclaim and use a_ops->writepages() where possible"
is also required. If both are put into -stable, then the backport
is straight forward but I was skeptical that -stable will take two
series that are this far reaching for a performance problem.

> To serve those people better, I'm wondering if we should merge
> mm-do-not-stall-in-synchronous-compaction-for-thp-allocations now, make
> it available for -stable backport and then revert it as part of this
> series?   ie: give people a stopgap while we fix it properly?

If -stable cannot take both series then this is probably the
only realistic option. I'd be ok with this but it will hurt THP
allocation success rates on those kernels so that will hurt other
people like Andrea and David Rientjes. It's between a rock and a hard
place. Another realistic option might be for distros to disable THP
by default on 3.0 and 3.1.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
