Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 13A746B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 10:03:02 -0400 (EDT)
Date: Thu, 1 Sep 2011 15:02:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] compaction: compact unevictable page
Message-ID: <20110901140254.GH14369@suse.de>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <8ef02605a7a76b176167d90a285033afa8513326.1321112552.git.minchan.kim@gmail.com>
 <20110831111954.GB17512@redhat.com>
 <20110831144150.GA1860@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110831144150.GA1860@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, Aug 31, 2011 at 11:41:50PM +0900, Minchan Kim wrote:
> On Wed, Aug 31, 2011 at 01:19:54PM +0200, Johannes Weiner wrote:
> > On Sun, Nov 13, 2011 at 01:37:42AM +0900, Minchan Kim wrote:
> > > Now compaction doesn't handle mlocked page as it uses __isolate_lru_page
> > > which doesn't consider unevicatable page. It has been used by just lumpy so
> > > it was pointless that it isolates unevictable page. But the situation is
> > > changed. Compaction could handle unevictable page and it can help getting
> > > big contiguos pages in fragment memory by many pinned page with mlock.
> > 
> > This may result in applications unexpectedly faulting and waiting on
> > mlocked pages under migration.  I wonder how realtime people feel
> > about that?
> 
> I didn't consider it but it's very important point.
> The migrate_page can call pageout on dirty page so RT process could wait on the
> mlocked page during very long time.

On the plus side, the filesystem that is likely to suffer from this
is btrfs. The other important cases avoid the writeout.

> I can mitigate it with isolating mlocked page in case of !sync but still we can't
> guarantee the time because we can't know how many vmas point the page so that try_to_unmap
> could spend lots of time.
> 

This loss of guarantee arguably violates POSIX 1B as part of the
real-time extension. The wording is "The function mlock shall cause
those whole pages containing any part of the address space of the
process starting at address addr and continuing for len bytes to be
memory resident until unlocked or until the process exits or execs
another process image."

It defines locking as "memory locking guarantees the residence of
portions of the address space. It is implementation defined whether
locking memory guarantees fixed translation between virtual addresses
(as seen by the process) and physical addresses."

As it's up to the implementation whether to preserve the physical
page mapping, it's allowed for compaction to move that page. However,
as it mlock is recommended for use by time-critical applications,
I fear we would be breaking developer expectations on the behaviour
of mlock even if it is permitted by POSIX.

> We can think it's a trade off between high order allocation VS RT latency.
> Now I am biasing toward RT latency as considering mlock man page.
> 
> Any thoughts?
> 

At the very least it should not be the default behaviour. I do not have
suggestions on how it could be enabled though. It's a bit obscure to
have as a kernel parameter or even a proc tunable and it's not a perfect
for /sys/kernel/mm/transparent_hugepage/defrag either.

How big of a problem is it that mlocked pages are not compacted at the
moment?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
