Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 665846B0062
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:41:32 -0500 (EST)
Date: Fri, 13 Nov 2009 13:40:04 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] make crypto unplug fix V3
Message-ID: <20091113184004.GA11332@think>
References: <1258054211-2854-1-git-send-email-mel@csn.ul.ie>
 <20091112202748.GC2811@think>
 <20091112220005.GD2811@think>
 <20091113024642.GA7771@think>
 <20091113125812.GB7891@think>
 <20091113173446.GL29804@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091113173446.GL29804@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 05:34:46PM +0000, Mel Gorman wrote:
> On Fri, Nov 13, 2009 at 07:58:12AM -0500, Chris Mason wrote:
> > This is still likely to set your dm data on fire.  It is only meant for
> > testers that start with mkfs and don't have any valuable dm data.
> > 
> 
> The good news is that my room remains fire-free. Despite swap also
> running from dm-crypt, I had no corruption or instability issues.

Ok, definitely not so convincing I'd try and shove it into a late rc.

> 
> Here is an updated set of results for fake-gitk running.
> 
> X86
> 2.6.30-0000000-force-highorder           Elapsed:12:08.908    Failures:0
> 2.6.31-0000000-force-highorder           Elapsed:10:56.283    Failures:0
> 2.6.31-0000006-dm-crypt-unplug           Elapsed:11:51.653    Failures:0
> 2.6.31-0000012-pgalloc-2.6.30            Elapsed:12:26.587    Failures:0
> 2.6.31-0000123-congestion-both           Elapsed:10:55.298    Failures:0
> 2.6.31-0001234-kswapd-quick-recheck      Elapsed:18:01.523    Failures:0
> 2.6.31-0123456-dm-crypt-unplug           Elapsed:10:45.720    Failures:0
> 2.6.31-revert-8aa7e847                   Elapsed:15:08.020    Failures:0
> 2.6.32-rc6-0000000-force-highorder       Elapsed:16:20.765    Failures:4
> 2.6.32-rc6-0000006-dm-crypt-unplug       Elapsed:13:42.920    Failures:0
> 2.6.32-rc6-0000012-pgalloc-2.6.30        Elapsed:16:13.380    Failures:1
> 2.6.32-rc6-0000123-congestion-both       Elapsed:18:39.118    Failures:0
> 2.6.32-rc6-0001234-kswapd-quick-recheck  Elapsed:15:04.398    Failures:0
> 2.6.32-rc6-0123456-dm-crypt-unplug       Elapsed:12:50.438    Failures:0
> 2.6.32-rc6-revert-8aa7e847               Elapsed:20:50.888    Failures:0
> 
> X86-64
> 2.6.30-0000000-force-highorder           Elapsed:10:37.300    Failures:0
> 2.6.31-0000000-force-highorder           Elapsed:08:49.338    Failures:0
> 2.6.31-0000006-dm-crypt-unplug           Elapsed:09:37.840    Failures:0
> 2.6.31-0000012-pgalloc-2.6.30            Elapsed:15:49.690    Failures:0
> 2.6.31-0000123-congestion-both           Elapsed:09:18.790    Failures:0
> 2.6.31-0001234-kswapd-quick-recheck      Elapsed:08:39.268    Failures:0
> 2.6.31-0123456-dm-crypt-unplug           Elapsed:08:20.965    Failures:0
> 2.6.31-revert-8aa7e847                   Elapsed:08:07.457    Failures:0
> 2.6.32-rc6-0000000-force-highorder       Elapsed:18:29.103    Failures:1
> 2.6.32-rc6-0000006-dm-crypt-unplug       Elapsed:25:53.515    Failures:3
> 2.6.32-rc6-0000012-pgalloc-2.6.30        Elapsed:19:55.570    Failures:6
> 2.6.32-rc6-0000123-congestion-both       Elapsed:17:29.255    Failures:2
> 2.6.32-rc6-0001234-kswapd-quick-recheck  Elapsed:14:41.068    Failures:0
> 2.6.32-rc6-0123456-dm-crypt-unplug       Elapsed:15:48.028    Failures:1
> 2.6.32-rc6-revert-8aa7e847               Elapsed:14:48.647    Failures:0
> 
> The numbering in the kernel indicates what patches are applied. I tested
> the dm-crypt patch both in isolation and in combination with the patches
> in this series.
> 
> Basically, the dm-crypt-unplug makes a small difference in performance
> overall, mostly slight gains and losses. There was one massive regression
> with the dm-crypt patch applied to 2.6.32-rc6 but at the moment, I don't
> know what that is.

How consistent are your numbers between runs?  I was trying to match
this up with your last email and things were pretty different.

> 
> In general, the patch reduces the amount of time direct reclaimers are
> spending on congestion_wait.
> 
> > It includes my patch from last night, along with changes to force dm to
> > unplug when its IO queues empty.
> > 
> > The problem goes like this:
> > 
> > Process: submit read bio
> > dm: put bio onto work queue
> > process: unplug
> > dm: work queue finds bio, does a generic_make_request
> > 
> > The end result is that we miss the unplug completely.  dm-crypt needs to
> > unplug for sync bios.  This patch also changes it to unplug whenever the
> > queue is empty, which is far from ideal but better than missing the
> > unplugs.
> > 
> > This doesn't completely fix io stalls I'm seeing with dm-crypt, but its
> > my best guess.  If it works, I'll break it up and submit for real to
> > the dm people.
> > 
> 
> Out of curiousity, how are you measuring IO stalls? In the tests I'm doing,
> the worker processes output their progress and it should be at a steady
> rate. I considered a stall to be an excessive delay between updates which
> is a pretty indirect measure.

I just setup a crypto disk and did dd if=/dev/zero of=/mnt/foo bs=1M

If you watch vmstat 1, there's supposed to be a constant steam of IO to
the disk.  If a whole second goes by with zero IO, we're doing something
wrong, I get a number of multi-second stalls where we are just waiting
for IO to happen.

Most of the time I was able to catch a sysrq-w for it, someone was
waiting on a read to finish.   It isn't completely clear to me if the
unplugging is working properly.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
