Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 22D3A5F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 13:31:25 -0400 (EDT)
Date: Fri, 15 Oct 2010 12:31:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when
 per cpu page cache flushed
In-Reply-To: <20101014114541.8B89.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010151224370.24683@router.home>
References: <20101013160640.ADC9.A69D9226@jp.fujitsu.com> <20101013132246.GO30667@csn.ul.ie> <20101014114541.8B89.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Oct 2010, KOSAKI Motohiro wrote:

> Initial variable ZVC commit (df9ecaba3f1) says
>
> >     [PATCH] ZVC: Scale thresholds depending on the size of the system
> >
> >     The ZVC counter update threshold is currently set to a fixed value of 32.
> >     This patch sets up the threshold depending on the number of processors and
> >     the sizes of the zones in the system.
> >
> >     With the current threshold of 32, I was able to observe slight contention
> >     when more than 130-140 processors concurrently updated the counters.  The
> >     contention vanished when I either increased the threshold to 64 or used
> >     Andrew's idea of overstepping the interval (see ZVC overstep patch).
> >
> >     However, we saw contention again at 220-230 processors.  So we need higher
> >     values for larger systems.
>
> So, I'm worry about your patch reintroduce old cache contention issue that Christoph
> observed when run 128-256cpus system.  May I ask how do you think this issue?

The load that I ran with was a test that concurrently faulted pages on a
large number of processors. This is a bit artificial and is only of
performance concern during startup of a large HPC job. The frequency of
counter updates during regular processing should pose a much lighter load
on the system. The automatic adaption of the thresholds should

1. Preserve the initial startup performance (since the threshold will be
unmodified on a system just starting).

2. Reduce the overhead of establish a more accurate zone state (because
reclaim can then cause the thresholds to be adapted).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
