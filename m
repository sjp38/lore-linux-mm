Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E34956B005A
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:26:39 -0400 (EDT)
Date: Tue, 28 Apr 2009 17:26:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Swappiness vs. mmap() and interactive response
Message-ID: <20090428092648.GA21226@localhost>
References: <20090428044426.GA5035@eskimo.com> <20090428143019.EBBF.A69D9226@jp.fujitsu.com> <1240904919.7620.73.camel@twins> <20090428090916.GC17038@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428090916.GC17038@localhost>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 05:09:16PM +0800, Wu Fengguang wrote:
> On Tue, Apr 28, 2009 at 09:48:39AM +0200, Peter Zijlstra wrote:
> > On Tue, 2009-04-28 at 14:35 +0900, KOSAKI Motohiro wrote:
> > > (cc to linux-mm and Rik)
> > >
> > >
> > > > Hi,
> > > >
> > > > So, I just set up Ubuntu Jaunty (using Linux 2.6.28) on a quad core phenom box,
> > > > and then I did the following (with XFS over LVM):
> > > >
> > > > mv /500gig/of/data/on/disk/one /disk/two
> > > >
> > > > This quickly caused the system to. grind.. to... a.... complete..... halt.
> > > > Basically every UI operation, including the mouse in Xorg, started experiencing
> > > > multiple second lag and delays.  This made the system essentially unusable --
> > > > for example, just flipping to the window where the "mv" command was running
> > > > took 10 seconds on more than one occasion.  Basically a "click and get coffee"
> > > > interface.
> > >
> > > I have some question and request.
> > >
> > > 1. please post your /proc/meminfo
> > > 2. Do above copy make tons swap-out? IOW your disk read much faster than write?
> > > 3. cache limitation of memcgroup solve this problem?
> > > 4. Which disk have your /bin and /usr/bin?
> > >
> >
> > FWIW I fundamentally object to 3 as being a solution.
> >
> > I still think the idea of read-ahead driven drop-behind is a good one,
> > alas last time we brought that up people thought differently.
>
> The semi-drop-behind is a great idea for the desktop - to put just
> accessed pages to end of LRU. However I'm still afraid it vastly
> changes the caching behavior and wont work well as expected in server
> workloads - shall we verify this?
>
> Back to this big-cp-hurts-responsibility issue. Background write
> requests can easily pass the io scheduler's obstacles and fill up
> the disk queue. Now every read request will have to wait 10+ writes
> - leading to 10x slow down of major page faults.
>
> I reach this conclusion based on recent CFQ code reviews. Will bring up
> a queue depth limiting patch for more exercises..

Sorry - just realized that Elladan's root fs lies in sda - the read side.

Then why shall a single read stream to cause 2000ms major fault delays?
The 'await' value for sda is <10ms, not even close to 2000ms:

> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await  svctm  %util
> sda              67.70     0.00  373.10    0.20    48.47     0.00   265.90     1.94    5.21   2.10  78.32
> sdb               0.00  1889.60    0.00  139.80     0.00    52.52   769.34    35.01  250.45   5.17  72.28
> ---
> sda               5.30     0.00  483.80    0.30    60.65     0.00   256.59     1.59    3.28   1.65  79.72
> sdb               0.00  3632.70    0.00  171.10     0.00    61.10   731.39   117.09  709.66   5.84 100.00
> ---
> sda              51.20     0.00  478.10    1.00    65.79     0.01   281.27     2.48    5.18   1.96  93.72
> sdb               0.00  2104.60    0.00  174.80     0.00    62.84   736.28   108.50  613.64   5.72 100.00
> --
> sda             153.20     0.00  349.40    0.20    60.99     0.00   357.30     4.47   13.19   2.85  99.80
> sdb               0.00  1766.50    0.00  158.60     0.00    59.89   773.34   110.07  672.25   6.30  99.96


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
