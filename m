Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 30A7A6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 13:11:50 -0500 (EST)
Received: by qadz32 with SMTP id z32so4897839qad.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 10:11:49 -0800 (PST)
Date: Thu, 9 Feb 2012 19:11:43 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120209181141.GF22552@somewhere.redhat.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
 <1327591185.2446.102.camel@twins>
 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
 <20120201170443.GE6731@somewhere.redhat.com>
 <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
 <20120202162420.GE9071@somewhere.redhat.com>
 <alpine.DEB.2.00.1202021028120.6221@router.home>
 <20120209155246.GD22552@somewhere.redhat.com>
 <4F33ED71.2090304@tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F33ED71.2090304@tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 09, 2012 at 10:59:45AM -0500, Chris Metcalf wrote:
> On 2/9/2012 10:52 AM, Frederic Weisbecker wrote:
> > On Thu, Feb 02, 2012 at 10:29:57AM -0600, Christoph Lameter wrote:
> >> On Thu, 2 Feb 2012, Frederic Weisbecker wrote:
> >>
> >>>> Some pinned timers might be able to get special treatment as well - take for
> >>>> example the vmstat work being schedule every second, what should we do with
> >>>> it for CPU isolation?
> >>> Right, I remember I saw these vmstat timers on my way when I tried to get 0
> >>> interrupts on a CPU.
> >>>
> >>> I think all these timers need to be carefully reviewed before doing anything.
> >>> But we certainly shouldn't adopt the behaviour of migrating timers by default.
> >>>
> >>> Some timers really needs to stay on the expected CPU. Note that some
> >>> timers may be shutdown by CPU hotplug callbacks. Those wouldn't be migrated
> >>> in case of CPU offlining. We need to keep them.
> >>>
> >>>> It makes sense to me to have that stop scheduling itself when we have the tick
> >>>> disabled for both idle and a nohz task.
> >> The vmstat timer only makes sense when the OS is doing something on the
> >> processor. Otherwise if no counters are incremented and the page and slab
> >> allocator caches are empty then there is no need to run the vmstat timer.
> > So this is a typical example of a timer we want to shutdown when the CPU is idle
> > but we want to keep it running when we run in adaptive tickless mode (ie: shutdown
> > the tick while the CPU is busy).
> 
> We would want to stop the timer as long as the processor is running
> exclusively userspace code.  Christoph's point is that in either the idle
> case or the userspace-only case, the vmstats won't be incrementing anyway. 
> Presumably you'd restart the timer when you enter the kernel, then when it
> fires and does its work, you might notice that when you return to userspace
> no further information will be collected, so stop the timer at that point. 
> Or, perhaps you could just proactively call refresh_cpu_vm_stats() just
> before stopping the tick and returning "permanently" to userspace, to make
> sure the stats are all properly updated.

Ah good point. I believe that many timers considered as deferrable during idle
may also be considered that way for userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
