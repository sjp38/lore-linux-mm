Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C7BED6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 16:18:42 -0400 (EDT)
Date: Tue, 4 Aug 2009 21:48:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090804204857.GA32092@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <4A787D84.2030207@redhat.com> <20090804121332.46df33a7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090804121332.46df33a7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, mingo@elte.hu, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 04, 2009 at 12:13:32PM -0700, Andrew Morton wrote:
> On Tue, 04 Aug 2009 14:27:16 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > Andrew Morton wrote:
> > > On Tue,  4 Aug 2009 19:12:26 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > >> This patch adds a simple post-processing script for the page-allocator-related
> > >> trace events. It can be used to give an indication of who the most
> > >> allocator-intensive processes are and how often the zone lock was taken
> > >> during the tracing period. Example output looks like
> > >>
> > >> find-2840
> > >>  o pages allocd            = 1877
> > >>  o pages allocd under lock = 1817
> > >>  o pages freed directly    = 9
> > >>  o pcpu refills            = 1078
> > >>  o migrate fallbacks       = 48
> > >>    - fragmentation causing = 48
> > >>      - severe              = 46
> > >>      - moderate            = 2
> > >>    - changed migratetype   = 7
> > > 
> > > The usual way of accumulating and presenting such measurements is via
> > > /proc/vmstat.  How do we justify adding a completely new and different
> > > way of doing something which we already do?
> > 
> > Mel's tracing is more akin to BSD process accounting,
> > where these statistics are kept on a per-process basis.
> 
> Is that useful?  Any time I've wanted to find out things like this, I
> just don't run other stuff on the machine at the same time.
> 

For some workloads, there will be multiple helper processes making it harder
to just not run other stuff on the machine at the same time. When looking at
just global statistics, it might be very easy to jump to the wrong conclusion
based on oprofile output or other aggregated figures.

> Maybe there are some scenarios where it's useful to filter out other
> processes, but are those scenarios sufficiently important to warrant
> creation of separate machinery like this?
> 

> > Nothing in /proc allows us to see statistics on a per
> > process basis on process exit.
> 
> Can this script be used to monitor the process while it's still running?
> 

Not in it's current form. It was intended as an illustration of how the events
can be used to generate a high-level picture and more suited to off-line
rather than on-line analysis. For on-line analysis, the parser would need to
be a lot more efficient than regular expressions and string matching in perl.

But, lets say you had asked me to give a live report on page allocator
activity on a per-process basis, I could have slapped together a
systemtap script in 5 minutes that looked something like .....
*scribbles*

==== BEGIN TAP SCRIPT ====
global page_allocs

probe kernel.trace("mm_page_alloc") {
  page_allocs[execname()]++
}

function print_count() {
  printf ("%-25s %-s\n", "#Pages Allocated", "Process Name")
  foreach (proc in page_allocs-)
    printf("%-25d %s\n", page_allocs[proc], proc)
  printf ("\n")
  delete page_allocs
}

probe timer.s(5) {
        print_count()
}
==== END SYSTEMTAP SCRIPT ====

This would tell me every 5 seconds what the most active processes
were that were allocating pages. Obviously I could have used the
mm_page_alloc_zone_locked point if the question was related to the zone lock
and lock_stat was not available. If I had oprofile output telling me a lot
of time was spent in the page allocator, I could then use a script like this
to better pin down which process might be responsible.

Incidentally, I ran this on my laptop which is running a patched kernel. Sample
output looks like

#Pages Allocated          Process Name
3683                      Xorg
40                        awesome
34                        konqueror
4                         thinkfan
2                         hald-addon-stor
2                         kjournald
1                         akregator

#Pages Allocated          Process Name
7715                      Xorg
2545                      modprobe
2489                      kio_http
1593                      akregator
405                       kdeinit
246                       khelper
158                       gconfd-2
52                        kded
27                        awesome
20                        gnome-terminal
7                         pageattr-test
5                         swapper
3                         hald-addon-stor
3                         lnotes
3                         thinkfan
2                         kjournald
1                         notes2
1                         pdflush
1                         konqueror

Straight off looking at that, I wonder what Xorg was doing and where modprobe
came out of :/. I don't think modprobe was from systemtap itself because it
was running too long at the point I cut & pasted the output.

> Also, we have a counter for "moderate fragmentation causing migrate
> fallbacks". 

Which counter is that? There are breakdowns all right of how many pageblocks
there are of each migratetype but it's a bit trickier to catch when
fragmentation is really occuring and to what extent. Just measuring the
frequency it occurs at may be enough to help tune min_free_kbytes for example.

> There must be hundreds of MM statistics which can be
> accumulated once we get down to this level of detail.  Why choose these
> nine?
> 

Because the page allocator is where I'm currently looking and these were
the points I wanted to draw reasonable conclusions on what sort of behaviour
the page allocator was seeing.

> Is there a plan to add the rest later on?

Depending on how this goes, I will attempt to do a similar set of trace
points for tracking kswapd and direct reclaim with the view to identifying
when stalls occur due to reclaim, when lumpy reclaim is kicking in, how long
it's taken and how often is succeeds/fails.

> 
> Or are these nine more a proof-of-concept demonstration-code thing?  If
> so, is it expected that developers will do an ad-hoc copy-n-paste to
> solve a particular short-term problem and will then toss the tracepoint
> away?  I guess that could be useful, although you can do the same with
> vmstat.
> 

Adding and deleting tracepoints, rebuilding and rebooting the kernel is
obviously usable by developers but not a whole pile of use if
recompiling the kernel is not an option or you're trying to debug a
difficult-to-reproduce-but-is-happening-now type of problem.

Of the CC list, I believe Larry Woodman has the most experience with
these sort of problems in the field so I'm hoping he'll make some sort
of comment.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
