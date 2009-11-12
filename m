Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DD3426B006A
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 14:30:40 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/5] Reduce GFP_ATOMIC allocation failures, candidate fix V3
Date: Thu, 12 Nov 2009 19:30:30 +0000
Message-Id: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Sorry for the long delay in posting another version. Testing is extremely
time-consuming and I wasn't getting to work on this as much as I'd have liked.

Changelog since V2
  o Dropped the kswapd-quickly-notice-high-order patch. In more detailed
    testing, it made latencies even worse as kswapd slept more on high-order
    congestion causing order-0 direct reclaims.
  o Added changes to how congestion_wait() works
  o Added a number of new patches altering the behaviour of reclaim

Since 2.6.31-rc1, there have been an increasing number of GFP_ATOMIC
failures. A significant number of these have been high-order GFP_ATOMIC
failures and while they are generally brushed away, there has been a large
increase in them recently and there are a number of possible areas the
problem could be in - core vm, page writeback and a specific driver. The
bugs affected by this that I am aware of are;

[Bug #14141] order 2 page allocation failures in iwlagn
[Bug #14141] order 2 page allocation failures (generic)
[Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
[No BZ ID]   Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
[No BZ ID]   page allocation failure message kernel 2.6.31.4 (tty-related)

The following are a series of patches that bring the behaviour of reclaim
and the page allocator more in line with 2.6.30.

Patches 1-3 should be tested first. The testing I've done shows that the
page allocator and behaviour of congestion_wait() is more in line with
2.6.30 than the vanilla kernels.

It'd be nice to have 2 more tests, applying each patch on top noting any
behaviour change. i.e. ideally there would be results for

 o patches 1+2+3
 o patches 1+2+3+4
 o patches 1+2+3+4+5

Of course, any tests results are welcome. The rest of the mail is the
results of my own tests.

I've tested against 2.6.31 and 2.6.32-rc6. I've somewhat replicated the
problem in Bug #14141 and believe the other bugs are variations of the same
style of problem. The basic reproduction case was;

1. X86-64 AMD Phenom and X86 P4 booted with mem=512MB. Expectation is
	any machine will do as long as it's 512MB for the size of workload
	involved.

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
	http://www.csn.ul.ie/~mel/postings/latency-20091112/latency-tests-with-results.tar.gz

	There are two helper programs that run as part of the test - a fake
	music player and a fake gitk.

	The fake music player uses rsync with bandwidth limits to start
	downloading a music folder from another machine. It's bandwidth
	limited to simulate playing music over NFS. I believe it generates
	similar if not exact traffic to a music player. It occured to be
	afterwards that if one patched ogg123 to print a line when 1/10th
	of a seconds worth of music was played, it could be used as an
	indirect measure of desktop interactivity and help pin down pesky
	"audio skips" bug reports.

	The fake gitk is based on observing roughly what gitk does using
	strace. It loads all the logs into a large buffer and then builds a
	very basic hash map of parent to child commits.  The data is stored
	because it was insufficient just to read the logs. It had to be
	kept in an in-memory buffer to generate swap.  It then discards the
	data and does it over again in a loop for a small number of times
	so the test is finite. When it processes a large number of commits,
	it outputs a line to stdout so that stalls can be observed. Ideal
	behaviour is that commits are read at a constant rate and latencies
	look flat.

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

6. Run the test script

To evaluate the patches, I considered three basic metrics.

o The length of time it takes fake-gitk to complete on average
o How often and how long fake-gitk stalled for
o How long was spent in congestion_wait

All generated data is in the tarball.

On X86, the results I got were

2.6.30-0000000-force-highorder           Elapsed:10:59.095  Failures:0

2.6.31-0000000-force-highorder           Elapsed:11:53.505  Failures:0
2.6.31-revert-8aa7e847                   Elapsed:14:01.595  Failures:0
2.6.31-0000012-pgalloc-2.6.30            Elapsed:13:32.237  Failures:0
2.6.31-0000123-congestion-both           Elapsed:12:44.170  Failures:0
2.6.31-0001234-kswapd-quick-recheck      Elapsed:10:35.327  Failures:0
2.6.31-0012345-adjust-priority           Elapsed:11:02.995  Failures:0

2.6.32-rc6-0000000-force-highorder       Elapsed:18:18.562  Failures:0
2.6.32-rc6-revert-8aa7e847               Elapsed:10:29.278  Failures:0
2.6.32-rc6-0000012-pgalloc-2.6.30        Elapsed:13:32.393  Failures:0
2.6.32-rc6-0000123-congestion-both       Elapsed:14:55.265  Failures:0
2.6.32-rc6-0001234-kswapd-quick-recheck  Elapsed:13:35.628  Failures:0
2.6.32-rc6-0012345-adjust-priority       Elapsed:12:41.278  Failures:0

The 0000000-force-highorder is a vanilla kernel patched so that network
receive always results in an order-2 allocation. This machine wasn't
suffering page allocation failures even under this circumstance. However,
note how slow 2.6.32-rc6 is and how much the revert helps. With the patches
applied, there is comparable performance.

Latencies were generally reduced with the patches applied. 2.6.32-rc6 was
particularly crazy with long stalls measured over the duration of the test
but has comparable latencies with 2.6.30 with the patches applied.

congestion_wait behaviour is more in line with 2.6.30 after the
patches with similar amounts of time being spent.  In general,
2.6.32-rc6-0012345-adjust-priority waits for longer than 2.6.30 or the
reverted kernels did. It also waits in more instances such as inside
shrink_inactive_list() where it didn't before. Forcing behaviour like 2.6.30
resulted in good figures but I couldn't justify the patches with anything
more solid than "in tests, it behaves well even though it doesn't make a
lot of sense"

On X86-64, the results I got were

2.6.30-0000000-force-highorder           Elapsed:09:48.545  Failures:0

2.6.31-0000000-force-highorder           Elapsed:09:13.020  Failures:0
2.6.31-revert-8aa7e847                   Elapsed:09:02.120  Failures:0
2.6.31-0000012-pgalloc-2.6.30            Elapsed:08:52.742  Failures:0
2.6.31-0000123-congestion-both           Elapsed:08:59.375  Failures:0
2.6.31-0001234-kswapd-quick-recheck      Elapsed:09:19.208  Failures:0
2.6.31-0012345-adjust-priority           Elapsed:09:39.225  Failures:0

2.6.32-rc6-0000000-force-highorder       Elapsed:19:38.585  Failures:5
2.6.32-rc6-revert-8aa7e847               Elapsed:17:21.257  Failures:0
2.6.32-rc6-0000012-pgalloc-2.6.30        Elapsed:18:56.682  Failures:1
2.6.32-rc6-0000123-congestion-both       Elapsed:16:08.340  Failures:0
2.6.32-rc6-0001234-kswapd-quick-recheck  Elapsed:18:11.200  Failures:7
2.6.32-rc6-0012345-adjust-priority       Elapsed:21:33.158  Failures:0

Failures were down and my impression was that it was much harder to cause
failures. Performance on mainline is still not as good as 2.6.30. On
this particular machine, I was able to force performance to be in line
but not with any patch I could justify in the general case.

Latencies were slightly reduced by applying the patches against 2.6.31.
against 2.6.32-rc6, applying the patches significantly reduced the latencies
but they are still significant. I'll continue to investigate what can be
done to improve this further.

Again, congestion_wait() is more in line with 2.6.30 when the patches
are applied. Similarly to X86, almost identical behaviour can be forced
by waiting on BLK_ASYNC_BOTH for each caller to congestion_wait() in the
reclaim and allocator paths.

Bottom line, the patches made triggering allocation failures much harder
and in a number of instances and latencies are reduced when the system
is under load. I will keep looking around this area - particularly the
performance under load on 2.6.32-rc6 but with 2.6.32 almost out the door,
I am releasing what I have now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
