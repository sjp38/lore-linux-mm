Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 38F7C6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 08:25:19 -0500 (EST)
Date: Tue, 15 Nov 2011 13:25:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111115132513.GF27150@suse.de>
References: <20111110100616.GD3083@suse.de>
 <20111110142202.GE3083@suse.de>
 <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
 <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
 <20111111101414.GJ3083@suse.de>
 <20111114154408.10de1bc7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111114154408.10de1bc7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 14, 2011 at 03:44:08PM -0800, Andrew Morton wrote:
> On Fri, 11 Nov 2011 10:14:14 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Thu, Nov 10, 2011 at 03:37:32PM -0800, David Rientjes wrote:
> > > On Thu, 10 Nov 2011, Andrew Morton wrote:
> > > 
> > > > > This patch once again prevents sync migration for transparent
> > > > > hugepage allocations as it is preferable to fail a THP allocation
> > > > > than stall.
> > > > 
> > > > Who said?  ;) Presumably some people would prefer to get lots of
> > > > huge pages for their 1000-hour compute job, and waiting a bit to get
> > > > those pages is acceptable.
> > > > 
> > > 
> > > Indeed.  It seems like the behavior would better be controlled with 
> > > /sys/kernel/mm/transparent_hugepage/defrag which is set aside specifically 
> > > to control defragmentation for transparent hugepages and for that 
> > > synchronous compaction should certainly apply.
> > 
> > With khugepaged in place, it's adding a tunable that is unnecessary and
> > will not be used. Even if such a tuneable was created, the default
> > behaviour should be "do not stall".
> 
> (who said?)
> 
> Let me repeat my cruelly unanswered question: do we have sufficient
> instrumentation in place so that operators can determine that this
> change is causing them to get less huge pages than they'd like?
> 

Unless we add a mel_did_it counter to vmstat, they won't be able to
identify that it was this patch in particular.

> Because some people really really want those huge pages.  If we go and
> silently deprive them of those huge pages via changes like this, how do
> they *know* it's happening?
> 

The counters in vmstat will give them a hint but it will not tell them
*why* they are not getting the huge pages they want. That would require
further analysis using a combination of ftrace, /proc/buddyinfo,
/proc/pagetypeinfo and maybe /proc/kpageflags depending on how
important the issue is.

> And what are their options for making the kernel try harder to get
> those pages?
> 

Fine control is limited. If it is really needed, I would not oppose
a patch that allows the use of sync compaction via a new setting in
/sys/kernel/mm/transparent_hugepage/defrag. However, I think it is
a slippery slope to expose implementation details like this and I'm
not currently planning to implement such a patch.

If they have root access, they have the option of writing to
/proc/sys/vm/compact_memory to manually trigger compaction. If
that does not free enough huge pages, they could use
/proc/sys/vm/drop_caches followed by /proc/sys/vm/compact_memory and
then start the target application. If that was too heavy, they could
write a balloon application which forces some percentage of memory
to be reclaimed by allocating anonymous memory, calling mlock on it,
unmapping the memory and then writing to /proc/sys/vm/compact_memory .
It would be very heavy handed but it could be a preparation step for
running a job that absolutely must get huge pages without khugepaged
running.

> And how do we communicate all of this to those operators?

The documentation patch will help to some extent but more creative
manipulation of the system to increase the success rate of huge
page allocations and how to analyse it is not documented. This is
largely because the analysis is conducted on a case-by-case basis.
Mailing "help help" to linux-mm and hoping someone on the internet
can hear you scream may be the only option.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
