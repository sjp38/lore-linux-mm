Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8CE546B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 06:43:10 -0400 (EDT)
Date: Fri, 29 Jul 2011 20:43:05 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH]vmscan: add block plug for page reclaim
Message-ID: <20110729104305.GI5404@dastard>
References: <1311130413.15392.326.camel@sli10-conroe>
 <CAEwNFnDj30Bipuxrfe9upD-OyuL4v21tLs0ayUKYUfye5TcGyA@mail.gmail.com>
 <1311142253.15392.361.camel@sli10-conroe>
 <CAEwNFnD3iCMBpZK95Ks+Z7DYbrzbZbSTLf3t6WXDQdeHrE6bLQ@mail.gmail.com>
 <1311144559.15392.366.camel@sli10-conroe>
 <4E287EC0.4030208@fusionio.com>
 <1311311695.15392.369.camel@sli10-conroe>
 <4E2B17A6.6080602@fusionio.com>
 <20110727164523.c2b1d569.akpm@linux-foundation.org>
 <20110729083847.GB1843@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110729083847.GB1843@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Shaohua Li <shaohua.li@intel.com>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, Jul 29, 2011 at 05:38:47PM +0900, Minchan Kim wrote:
> On Wed, Jul 27, 2011 at 04:45:23PM -0700, Andrew Morton wrote:
> > Using an additional 44 bytes of stack on that path is also
> > significant(ly bad).  But we need to fix that problem anyway.  One way
> > we could improve things in mm/vmscan.c is to move the blk_plug into
> > scan_control then get the scan_control off the stack in some manner. 
> > That's easy for kswapd: allocate one scan_control per kswapd at
> > startup.  Doing it for direct-reclaim would be a bit trickier...
> 
> Stack diet in direct reclaim...
> Of course, it's a matter as I pointed out in this patch
> but frankly speaking, it's very annoying to consider stack usage
> whenever we add something in direct reclaim path.

It's a fact of life that direct reclaim has to live with - memory
allocation can occur with a lot of stack already consumed. If you
don't want to care about stack usage, then lets increase the default
stack size to 16k for x86-64.....

> I think better solution is to avoid write in direct reclaim like the approach of Mel.

Yeah, and we should probably stop swapping in the direct reclaim
path, too, because I've seen the stack usage from memory allocation
to swap IO issue exceed 4k on x86-64....

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
