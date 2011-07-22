Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 80BD86B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 01:15:00 -0400 (EDT)
Subject: Re: [PATCH]vmscan: add block plug for page reclaim
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <4E287EC0.4030208@fusionio.com>
References: <1311130413.15392.326.camel@sli10-conroe>
	 <CAEwNFnDj30Bipuxrfe9upD-OyuL4v21tLs0ayUKYUfye5TcGyA@mail.gmail.com>
	 <1311142253.15392.361.camel@sli10-conroe>
	 <CAEwNFnD3iCMBpZK95Ks+Z7DYbrzbZbSTLf3t6WXDQdeHrE6bLQ@mail.gmail.com>
	 <1311144559.15392.366.camel@sli10-conroe>  <4E287EC0.4030208@fusionio.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jul 2011 13:14:55 +0800
Message-ID: <1311311695.15392.369.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, 2011-07-22 at 03:32 +0800, Jens Axboe wrote:
> On 2011-07-20 08:49, Shaohua Li wrote:
> > On Wed, 2011-07-20 at 14:30 +0800, Minchan Kim wrote:
> >> On Wed, Jul 20, 2011 at 3:10 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> >>> On Wed, 2011-07-20 at 13:53 +0800, Minchan Kim wrote:
> >>>> On Wed, Jul 20, 2011 at 11:53 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> >>>>> per-task block plug can reduce block queue lock contention and increase request
> >>>>> merge. Currently page reclaim doesn't support it. I originally thought page
> >>>>> reclaim doesn't need it, because kswapd thread count is limited and file cache
> >>>>> write is done at flusher mostly.
> >>>>> When I test a workload with heavy swap in a 4-node machine, each CPU is doing
> >>>>> direct page reclaim and swap. This causes block queue lock contention. In my
> >>>>> test, without below patch, the CPU utilization is about 2% ~ 7%. With the
> >>>>> patch, the CPU utilization is about 1% ~ 3%. Disk throughput isn't changed.
> >>>>
> >>>> Why doesn't it enhance through?
> >>> throughput? The disk isn't that fast. We already can make it run in full
> >>
> >> Yes. Sorry for the typo.
> >>
> >>> speed, CPU isn't bottleneck here.
> >>
> >> But you try to optimize CPU. so your experiment is not good.
> > it's not that good, because the disk isn't fast. The swap test is the
> > workload with most significant impact I can get.
> 
> Let me just interject here that a plug should be fine, from 3.1 we'll
> even auto-unplug if a certain depth has been reached. So latency should
> not be a worry. Personally I think the patch looks fine, though some
> numbers would be interesting to see. Cycles spent submitting the actual
> IO, combined with IO statistics what kind of IO patterns were observed
> for plain and with patch would be good.
I can observe the average request size changes. Before the patch, the
average request size is about 90k from iostat (but the variation is
big). With the patch, the request size is about 100k and variation is
small.
how to check the cycles spend submitting the I/O?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
