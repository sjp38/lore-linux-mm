Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 61E3F6B0087
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 22:38:47 -0500 (EST)
Date: Wed, 17 Nov 2010 19:34:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/13] IO-less dirty throttling v2
Message-Id: <20101117193431.ec1f4547.akpm@linux-foundation.org>
In-Reply-To: <20101118032141.GP13830@dastard>
References: <20101117042720.033773013@intel.com>
	<20101117150330.139251f9.akpm@linux-foundation.org>
	<20101118020640.GS22876@dastard>
	<20101117180912.38541ca4.akpm@linux-foundation.org>
	<20101118032141.GP13830@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 14:21:41 +1100 Dave Chinner <david@fromorbit.com> wrote:

> > But mainly because we're taking the work accounting away from the user
> > who caused it and crediting it to the kernel thread instead, and that's
> > an actively *bad* thing to do.
> 
> The current foreground writeback is doing work on behalf of the
> system (i.e. doing background writeback) and therefore crediting it
> to the user process. That seems wrong to me; it's hiding the
> overhead of system tasks in user processes.
> 
> IMO, time spent doing background writeback should not be creditted
> to user processes - writeback caching is a function of the OS and
> it's overhead should be accounted as such.

bah, that's bunk.  Using this logic, _no_ time spent in the kernel
should be accounted to the user process and we may as well do away with
system-time accounting altogether.

If userspace performs some action which causes the kernel to consume
CPU resources, that consumption should be accounted to that process.

Yes, writeback can be inaccurate because process A will write back
process B's stuff, but that should even out on average, and it's more
accurate than saying "zero".

> Indeed, nobody has
> realised (until now) just how inefficient it really is because of
> the fact that the overhead is mostly hidden in user process system
> time.

"hidden"?  You do "time dd" and look at the output!

_now_ it's hidden.  You do "time dd" and whee, no system time!  You
need to do complex gymnastics with kernel thread accounting to work out
the real cost of your dd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
