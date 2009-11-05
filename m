Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A88736B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 11:50:15 -0500 (EST)
Date: Thu, 5 Nov 2009 16:48:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
	high-order watermarks are being hit (data on latencies available)
Message-ID: <20091105164832.GB25926@csn.ul.ie>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <200911040305.59352.elendil@planet.nl> <20091104154853.GM22046@csn.ul.ie> <200911042157.25020.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200911042157.25020.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 09:57:21PM +0100, Frans Pop wrote:
> On Wednesday 04 November 2009, Mel Gorman wrote:
> > Agreed. I'll start from scratch again trying to reproduce what you're
> > seeing locally. I'll try breaking my network card so that it's making
> > high-order atomics and see where I get. Machines that were previously
> > tied up are now free so I might have a better chance.
> 
> Hmmm. IMO you're looking at this from the wrong side. You don't need to 
> break your network card because the SKB problems are only the *result* of 
> the change, not the *cause*.
> 

They are a symptom though - albeit a dramatic one from the change on
timing.

> I can reproduce the desktop freeze just as easily when I'm using wired 
> (e1000e) networking and when I'm not streaming music at all, but just 
> loading that 3rd gitk instance.
> 

No one likes desktop freezes but it's a bit on the hard side to measure and
reproduce with multiple kernels reliability.  However, I think I might have
something to help this side of things out.

> So it's not
>   "I get a desktop freeze because of high order allocations from wireless
>    during swapping",
> but
>   "during very heavy swapping on a system with an encrypted LMV volume
>    group containing (encrypted) fs and (encrytpted) swap, the swapping
>    gets into some semi-stalled state *causing* a long desktop freeze
>    and, if there also happens to be some process trying higher order
>    allocations, failures of those allocations".
> 

Right, so it's a related problem, but not the root cause.

> I have tried to indicate this in the past, but it may have gotten lost in 
> the complexity of the issue.
> 

I got it all right, but felt that the page allocation problems were both
compounding the problem and easier to measure.

> An important clue is still IMO that during the first part of the freezes 
> there is very little disk activity for a long time. Why would that be when 
> the system is supposed to be swapping like hell?
> 

One possible guess is that the system as a whole decides everything is
congested and waits for something else to make forward progress. I
really think the people who were involved in the writeback changes need
to get in here and help out.

In the interest of getting something more empirical, I sat down from scratch
with the view to recreating your case and I believe I was successful. I was
able to reproduce your problem after a fashion and generate some figures -
crucially including some latency figures.

I don't have a fix for this, but I'm hoping someone will follow the notes
to recreate the reproduction case and add their own instrumentation to pin
this down.

Steps to setup and reproduce are;

1. X86-64 AMD Phenom booted with mem=512MB. Expectation is any machine
	will do as long as it's 512MB for the size of workload involved.

2. A crypted work partition and swap partition was created. On my
   own setup, I gave no passphrase so it'd be easier to activate without
   interaction but there are multiple options. I should have taken better
   notes but the setup goes something like this;

	cryptsetup create -y crypt-partition /dev/sda5
	pvcreate /dev/mapper/crypt-partition
	vgcreate crypt-volume /dev/mapper/crypt-partition
	lvcreate -L 5G -n crypt-logical crypt-volume
	lvcreate -L 2G -n crypt-swap crypt-volume
	mkfs -t ext3 /dev/crypt-volume/crypt-logical
	mkswap /dev/crypt-volume/crypt-swap

3. With the partition mounted on /scratch, I
	cd /scratch
	mkdir music
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git linux-2.6

4. On a normal partition, I expand a tarball containing test scripts available at
	http://www.csn.ul.ie/~mel/postings/latency-20091105/latency-tests-with-results.tar.gz

	There are two helper programs that run as part of the test - a fake
	music player and a fake gitk.

	The fake music player uses rsync with bandwidth limits to start
	downloading a music folder from another machine. It's bandwidth limited
	to simulate playing music over NFS. I believe it generates similar if
	not exact traffic to a music player. It occured to be afterwards that
	if one patched ogg123 to print a line when 1/10th of a seconds worth
	of music was played, it could be used as an indirect measure of desktop
	interactivity and help pin down pesky "audio skips" bug reports.

	The fake gitk is based on observing roughly what gitk does using
	strace. It loads all the logs into a large buffer and then builds a
	very basic hash map of parent to child commits.  The data is stored
	because it was insufficient just to read the logs. It had to be kept in
	an in-memory buffer to generate swap.  It then discards the data and
	does it over again in a loop for a small number of times so the test
	is finite. When it processes a large number of commits, it outputs
	a line to stdout so that stalls can be observed. Ideal behaviour is
	that commits are read at a constant rate and latencies look flat.

	Output from the two programs is piped through another script -
	latency-output. It records how far into the test it was when the
	line was outputted and what the latency was since the last line
	appeared. The latency should always be very smooth. Because pipes
	buffer IO, they are all run by expect_unbuffered which is available
	from expect-dev on Debian at least.

	All the tests are driven via run-test.sh. While the tests run,
	it records the kern.log to track page allocation failures, records
	nr_writeback at regular intervals and tracks Page IO and Swap IO.

5. For running an actual test, a kernel is built, booted, the
	crypted partition activated, lvm restarted,
	/dev/crypt-volume/crypt-logical mounted on /scratch, all
	swap partitions turned off and then the swap partition on
	/dev/crypt-volume/crypt-swap activated. I then run run-test.sh from
	the tarball

6. I tested kernels 2.6.30, 2.6.31, 2.6.32-rc6,
	2.6.32-rc6-revert-8aa7e847, 2.6.32-rc6-patches123 where patches123
	are the patches in this thread and 2.6.32-rc6-patches45 which include
	the account patch and a delay for direct reclaimers posted within
	this thread. To simulate the wireless network card, I patched skbuff
	on all kernels to always allocate at least order-2. However, the
	latencies are expected to occur without order-2 atomic allocations
	from network being involved.

The tarball contains the scripts I used, generated graphs and the raw
data. Broadly speaking;
	2.6.30 was fine with rare fails although I did trigger page
		allocation failures during at least one test
	2.6.31 was mostly fine with occasional fails both ok latency-wise
	2.6.32-rc6 sucked with multiple failures and large latencies. On
		a few occasions, it's possible for this kernel to get into
		a page allocation failure lockup. I left one running and
		it was still locked up spewing out error messages 8 hours
		later. i.e. it's possible to almost live-lock this kernel
		using this workload
	2.6.32-rc6-revert-8aa7e847 smooths out the latencies but is not great.
		I suspect it made more a difference to 2.6.31 than it
		does to mainline

	2.6.32-rc6-patches123 help a little with latencies and has fewer
	failures.
		More importantly, the failures are hard to trigger. It was
		actually rare for a failure to occur. It just happened to
		occur on the final set of results I gathered so I think that's
		important. It's also important that they bring the allocator
		more in line with 2.6.30 behaviour. The most important
		contribion of all was that I couldn't live-lock the kernel
		with these patches applied but I can with the vanilla kernel.

	2.6.32-rc6-patches12345 did not significantly help leading me to
		conclude that the congestion_wait() called in the page
		allocator is not significant.

patches123 are the three patches that formed this thread originally.
Patches 4 and 5 are the accounting patch and the one that makes kswapd sleep
for a short interval before rechecking watermarks.

On the latency front, look at

http://www.csn.ul.ie/~mel/postings/latency-20091105/graphs/gitk-latency.ps
http://www.csn.ul.ie/~mel/postings/latency-20091105/graphs/gitk-latency-smooth.ps

Both graphs are based on the same data but the smooth one (plotted with
smooth bezier in gnuplot but otherwise based on the same data) is easier
to read for doing a direct comparison. The gitk-latency.ps is based on how
the fourth instance of fake-gitk was running. Every X number of commits, it
prints out how many commits it processed. It should be able to process them
at a constant rate so the Y bars should be all levelish.  2.6.30 is mostly
low with small spikes and 2.6.31 is not too bad.  However, mainline has
massive stalls evidenced by the sawtooth like pattern where there were big
delays and latencies. It can't be seen in the graph but on a few occasions,
2.6.32-rc6 live-locked in order-2 allocation failures during the test.

It's not super-clear from the IO statistics if IO was really happening or
not during the stalls and I can't hear the disks for activity. All that can
be seen on the graphs is the huge spike on pages queued during a period of
proce3sses being stalled. What can be said is that this is probably very
similar to the desktop freezes Frans sees.

Because of other reports, the slight improvements on latency and the removal
of a possible live-lock situation, I think patches 1-3 and the accounting
patch posted in this thread should go ahead. Patches 1,2 bring allocator
behaviour more in line with 2.6.30 and are a proper fix. Patch 3 makes a lot
of sense when there are a lot of high-order atomics going on so that kswapd
notices as fast as possible that it needs to do other work. The accounting
patch monitors what's going on with patch 3.

Beyond that, independent of any allocation failure problems, desktop
latency problems have been reported and I believe this is what I'm
seeing with the massive latencties and stalled processes. This could
lead to some very nasty bug reports when 2.6.32 comes out.

I'm going to rerun these through a profiler and see if something obvious
pops out and if not, then bisect 2.6.31..2.6.32-rc6. It would be great
if those involved in the IO-related changes could take a look at the
results and try reproducing the problem monitoring what they think is
important.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
