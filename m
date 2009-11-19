Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF6076B007B
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 03:12:27 -0500 (EST)
Date: Thu, 19 Nov 2009 08:12:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/7] Reduce GFP_ATOMIC allocation failures, candidate
	fix V3
Message-ID: <20091119081219.GB1119@csn.ul.ie>
References: <1258054211-2854-1-git-send-email-mel@csn.ul.ie> <20091112202748.GC2811@think> <20091112220005.GD2811@think> <20091113024642.GA7771@think> <4B018157.3080707@redhat.com> <20091116183613.GG27677@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091116183613.GG27677@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Milan Broz <mbroz@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 16, 2009 at 01:36:13PM -0500, Chris Mason wrote:
> On Mon, Nov 16, 2009 at 05:44:07PM +0100, Milan Broz wrote:
> > On 11/13/2009 03:46 AM, Chris Mason wrote:
> > > On Thu, Nov 12, 2009 at 05:00:05PM -0500, Chris Mason wrote:
> > > 
> > > [ ...]
> > > 
> > >>
> > >> The punch line is that the btrfs guy thinks we can solve all of this with
> > >> just one more thread.  If we change dm-crypt to have a thread dedicated
> > >> to sync IO and a thread dedicated to async IO the system should smooth
> > >> out.
> > 
> > Please, can you cc DM maintainers with these kind of patches? dm-devel list at least.
> > 
> 
> Well, my current patch is a hack.  If I had come up with a proven theory
> (hopefully Mel can prove it ;), it definitely would have gone through
> the dm-devel lists.
> 

I can't prove it for sure but the workload might not be targetted enough
to show better or worse read latencies.

I adjusted the workload to run fake-gitk multiple times to get a better
sense of the deviation between runs

On X86-64, the timings were
2.6.30-0000000-force-highorder                Elapsed:10:52.218(stddev:008.085)   Failures:0
2.6.31-0000000-force-highorder                Elapsed:11:32.258(stddev:130.779)   Failures:0
2.6.31-0012345-kswapd-stay-awake-when-min     Elapsed:09:34.662(stddev:022.239)   Failures:0
2.6.31-0123456-dm-crypt-unplug                Elapsed:10:28.718(stddev:060.897)   Failures:0
2.6.32-rc6-0000000-force-highorder            Elapsed:27:53.686(stddev:207.508)   Failures:37
2.6.32-rc6-0012345-kswapd-stay-awake-when-min Elapsed:27:26.735(stddev:221.214)   Failures:6
2.6.32-rc6-0123456-dm-crypt-unplug            Elapsed:27:35.462(stddev:205.017)   Failures:4

On X86, they were
2.6.30-0000000-force-highorder                Elapsed:13:36.768(stddev:019.514)   Failures:0
2.6.31-0000000-force-highorder                Elapsed:16:27.922(stddev:134.839)   Failures:0
2.6.31-0000006-dm-crypt-unplug                Elapsed:15:47.160(stddev:183.488)   Failures:0
2.6.31-0012345-kswapd-stay-awake-when-min     Elapsed:18:32.458(stddev:182.164)   Failures:0
2.6.31-0123456-dm-crypt-unplug                Elapsed:17:07.482(stddev:210.404)   Failures:0
2.6.32-rc6-0000000-force-highorder            Elapsed:26:08.763(stddev:123.926)   Failures:4
2.6.32-rc6-0000006-dm-crypt-unplug            Elapsed:17:57.550(stddev:254.412)   Failures:1
2.6.32-rc6-0012345-kswapd-stay-awake-when-min Elapsed:25:03.435(stddev:234.685)   Failures:1
2.6.32-rc6-0123456-dm-crypt-unplug            Elapsed:25:21.382(stddev:211.252)   Failures:0

(I forgot to queue up the dm-crypt patches on their own for X86-64 which
is why the results are missing).

While the dm-crypt patch shows small differences, they are well within
the noise for each run of fake-gitk so I can't draw any major conclusion
from it.

On X86 for 2.6.31, roughly the same amount of time is spent in
congestion_wait() with or without the patch. On 2.6.32-rc6, the time
kswapd spends congestioned on the ASYNC queue is reduced by about 20%
both when compared against mainline and compared against the other
patches in the series applied. There is very little difference to the
congestion on the SYNC queue.

On X86-64 for 2.6.31, the story is slightly different. I don't think
it's an architecture thing because the X86-64 machine has twice as many
cores as the X86 test machine. Here, congestion_wait() spent on the
ASYNC queue remains roughly the same but the time spent on the SYNC
queue for direct reclaim is reduced by almost a third. Against
2.6.32-rc6, there was very little difference.

Again, it's hard to draw solid conclusions from this. I know from other
testing that the low_latency tunable for the IO scheduler is an important
factor for the performance of this test on 2.6.32-rc6 so if disabled, it
mgiht show a clearer picture, but right now I can't say for sure it's an
improvement.

> > Note that the crypt requests can be already processed synchronously or asynchronously,
> > depending on used crypto module (async it is in the case of some hw acceleration).
> > 
> > Adding another queue make the situation more complicated and because the crypt
> > requests can be queued in crypto layer I am not sure that this solution will help
> > in this situation at all.
> > (Try to run that with AES-NI acceleration for example.)
> 
> The problem is that async threads still imply a kind of ordering.
> If there's a fifo serviced by one thread or 10, the latency ramifications
> are very similar for a new entry on the list.  We have to wait for a
> large portion of the low-prio items in order to service a high prio
> item.
> 
> With a queue dedicated to sync requests and one dedicated to async,
> you'll get better read latencies.  Btrfs has a similar problem around
> the crc helper threads and it ends up solving things with two different
> lists (high and low prio) processed by one thread.
> 
> -chris
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
