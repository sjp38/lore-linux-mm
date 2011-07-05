Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D10AD900134
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 11:55:47 -0400 (EDT)
Date: Wed, 6 Jul 2011 01:55:42 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110705155542.GG1026@dastard>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701145935.GB29530@suse.de>
 <20110702024219.GT561@dastard>
 <20110705141016.GA15285@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110705141016.GA15285@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, xfs@oss.sgi.com, jack@suse.cz, linux-mm@kvack.org

On Tue, Jul 05, 2011 at 03:10:16PM +0100, Mel Gorman wrote:
> On Sat, Jul 02, 2011 at 12:42:19PM +1000, Dave Chinner wrote:
> > On Fri, Jul 01, 2011 at 03:59:35PM +0100, Mel Gorman wrote:
> > BTW, called a workload "fsmark" tells us nothing about the workload
> > being tested - fsmark can do a lot of interesting things. IOWs, you
> > need to quote the command line for it to be meaningful to anyone...
> > 
> 
> My bad.
> 
> ./fs_mark -d /tmp/fsmark-14880 -D 225  -N  22500  -n  3125  -L  15 -t  16  -S0  -s  131072

Ok, so 16 threads, 3125 files per thread, 128k per file, all created
in to the same directory which rolls over when it gets to 22500
files in the directory. Yeah, it generates a bit of memory pressure,
but I think the file sizes are too small to really stress writeback
much. You need to use files that are at least 10MB in size to really
start to mix up the writeback lists and the way they juggle new and
old inodes to try not to starve any particular inode of writeback
bandwidth....

Also, I don't use the "-t <num>" threading mechanism because all it
does is bash on the directory mutex without really improving
parallelism for creates. perf top on my system shows:

           samples  pcnt function                           DSO
             _______ _____ __________________________________ __________________________________

             2799.00  9.3% mutex_spin_on_owner                [kernel.kallsyms]
             2049.00  6.8% copy_user_generic_string           [kernel.kallsyms]
             1912.00  6.3% _raw_spin_unlock_irqrestore        [kernel.kallsyms]

A contended mutex as the prime CPU consumer. That's more CPU than
copying 750MB/s of data.

Hence I normally drive parallelism with fsmark by using multiple "-d
<dir>" options, which runs a thread per directory and a workload
unit per directory and so you don't get directory mutex contention
causing serialisation and interference with what you are really
trying to measure....

> > > As I look through the results I have at the moment, the number of
> > > pages written back was simply really low which is why the problem fell
> > > off my radar.
> > 
> > It doesn't take many to completely screw up writeback IO patterns.
> > Write a few random pages to a 10MB file well before writeback would
> > get to the file, and instead of getting optimal sequential writeback
> > patterns when writeback gets to it, we get multiple disjoint IOs
> > that require multiple seeks to complete.
> > 
> > Slower, less efficient writeback IO causes memory pressure to last
> > longer and hence more likely to result in kswapd writeback, and it's
> > just a downward spiral from there....
> > 
> 
> Yes, I see the negative feedback loop. This has always been a struggle
> in that kswapd needs pages from a particular zone to be cleaned and
> freed but calling writepage can make things slower. There were
> prototypes in the past to give hints to the flusher threads on what
> inode and pages to be freed and they were never met with any degree of
> satisfaction.
> 
> The consensus (amount VM people at least) was as long as that number was
> low, it wasn't much of a problem.

Therein lies the problem. You've got storage people telling you
there is an IO problem with memory reclaim, but the mm community
then put their heads together somewhere private, decide it isn't
a problem worth fixing and do nothing. Rinse, lather, repeat.

I expect memory reclaim to play nicely with writeback that is
already in progress. These subsystems do not work in isolation, yet
memory reclaim treats it that way - as though it is the most
important IO submitter and everything else can suffer while memory
reclaim does it's stuff.  Memory reclaim needs to co-ordinate with
writeback effectively for the system as a whole to work well
together.

> I know you disagree.

Right, that's because it doesn't have to be a very high number to be
a problem. IO is orders of magnitude slower than the CPU time it
takes to flush a page, so the cost of making a bad flush decision is
very high. And single page writeback from the LRU is almost always a
bad flush decision.

> > > > > Oh, now that is too close to just be a co-incidence. We're getting
> > > > > significant amounts of random page writeback from the the ends of
> > > > > the LRUs done by the VM.
> > > > > 
> > > > > <sigh>
> > > 
> > > Does the value for nr_vmscan_write in /proc/vmstat correlate? It must
> > > but lets me sure because I'm using that figure rather than ftrace to
> > > count writebacks at the moment.
> > 
> > The number in /proc/vmstat is higher. Much higher.  I just ran the
> > test at 1000 files (only collapsed to ~3000 iops this time because I
> > ran it on a plain 3.0-rc4 kernel that still has the .writepage
> > clustering in XFS), and I see:
> > 
> > nr_vmscan_write 6723
> > 
> > after the test. The event trace only capture ~1400 writepage events
> > from kswapd, but it tends to miss a lot of events as the system is
> > quite unresponsive at times under this workload - it's not uncommon
> > to have ssh sessions not echo a character for 10s... e.g: I started
> > the workload ~11:08:22:
> > 
> 
> Ok, I'll be looking at nr_vmscan_write as the basis for "badness".

Perhaps you should look at my other reply (and two line "fix") in
the thread about stopping dirty page writeback until after waiting
on pages under writeback.....

> > > A more relevant question is this -
> > > how many pages were reclaimed by kswapd and what percentage is 799
> > > pages of that? What do you consider an acceptable percentage?
> > 
> > I don't care what the percentage is or what the number is. kswapd is
> > reclaiming pages most of the time without affect IO patterns, and
> > when that happens I just don't care because it is working just fine.
> > 
> 
> I do care. I'm looking at some early XFS results here based on a laptop
> (4G). For fsmark with the command line above, the number of pages
> written back by kswapd was 0. The worst test by far was sysbench using a
> particularly large database. The number of writes was 48745 which is
> 0.27% of pages scanned or 0.28% of pages reclaimed. Ordinarily I would
> ignore that.
> 
> If I run this at 1G and get a similar ratio, I will assume that I
> am not reproducing your problem at all unless I know what ratio you
> are seeing.

Single threaded writing of files should -never- cause writeback from
the LRUs. If that is happening, then the memory reclaim throttling
is broken. See my other email.

> So .... How many pages were reclaimed by kswapd and what percentage
> is 799 pages of that?

No idea. That information is long gone....

> You answered my second question. You consider 0% to be the acceptable
> percentage.

No, I expect memory reclaim to behave nicely with writeback that is
already in progress. This subsystems do not work in isolation - they
need to co-ordinate 

> > What I care about is what kswapd is doing when it finds dirty pages
> > and it decides they need to be written back. It's not a problem that
> > they are found or need to be written, the problem is the utterly
> > crap way that memory reclaim is throwing the pages at the filesystem.
> > 
> > I'm not sure how to get through to you guys that single, random page
> > writeback is *BAD*.
> 
> It got through. The feedback during discussions on the VM side was
> that as long as the percentage was sufficiently low it wasn't a problem
> because on occasion, the VM really needs pages from a particular zone.
> A solution that addressed both problems has never been agreed on and
> energy and time runs out before it gets fixed each time.

<sigh>

> > And while I'm ranting, when on earth is the issue-writeback-from-
> > direct-reclaim problem going to be fixed so we can remove the hacks
> > in the filesystem .writepage implementations to prevent this from
> > occurring?
> > 
> 
> Prototyped that too, same thread. Same type of problem, writeback
> from direct reclaim should happen so rarely that it should not be
> optimised for. See https://lkml.org/lkml/2010/6/11/32

Writeback from direct reclaim crashes systems by causing stack
overruns - that's why we've disabled it. It's not an "optimisation"
problem - it's a _memory corruption_ bug that needs to be fixed.....

> At the risk of pissing you off, this isn't new information so I'll
> consider myself duly nudged into revisiting.

No, I've had a rant to express my displeasure at the lack of
progress on this front.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
