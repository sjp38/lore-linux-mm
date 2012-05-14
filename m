Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id CDC616B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 09:39:49 -0400 (EDT)
Date: Mon, 14 May 2012 14:39:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Allow migration of mlocked page?
Message-ID: <20120514133944.GF29102@suse.de>
References: <4FAC9786.9060200@kernel.org>
 <20120511131404.GQ11435@suse.de>
 <4FB08920.4010001@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FB08920.4010001@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

On Mon, May 14, 2012 at 01:25:04PM +0900, Minchan Kim wrote:
> > <SNIP>
> >
> > If CMA decide they want to alter mlocked pages in this way, it's sortof
> > ok. While CMA is being used, there are no expectations on the RT
> > behaviour of the system - stalls are expected. In their use cases, CMA
> > failing is far worse than access latency to an mlocked page being
> > variable while CMA is running.
> > 
> > Compaction on the other hand is during the normal operation of the
> > machine. There are applications that assume that if anonymous memory
> > is mlocked() then access to it is close to zero latency. They are
> > not RT-critical processes (or they would disable THP) but depend on
> > this. Allowing compaction to migrate mlocked() pages will result in bugs
> > being reported by these people.
> > 
> > I've received one bug this year about access latency to mlocked() regions but
> > it turned out to be a file-backed region and related to when the write-fault
> > is incurred. The ultimate fix was in the application but we'll get new bug
> > reports if anonymous mlocked pages do not preserve the current guarantees
> > on access latency.
> > 
> 
> If so, what do you think about migration of mlocked pages by migrate_pages, cpuset_migrate_mm and memcg?

migrate_pages() is a core function used by a variety of different callers. It
*optionally* could move mlocked pages and it would be up to the caller to
specify if that was allowed.

cpuset_migrate_mm() should be allowed to move mlocked() pages because it's
called in a path where the pages are on a node that should not longer be
accessible to the processes. In this case, the latency hit is unavoidable
and a bug reporter that says "there is an unexpected latency accessing memory
while a process moves memory to another node" will be told to get a clue.

Where does memcg call migrate_pages()?

> I think they all is done by under user's control while compaction happens regardless of user.
> So do you think that's why compaction shouldn't migrate mlocked page?
> 

Yes. If the user takes an explicit action that causes latencies when
accessing an mlocked anonymous region while the pages are migrated, that's
fine. I still do not think that THP and khugepaged should cause unexpected
latencies accessing mlocked anonymous regions because it is beyond the
control of the application.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
