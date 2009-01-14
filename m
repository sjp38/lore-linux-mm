Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C04FC6B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 22:29:42 -0500 (EST)
Date: Wed, 14 Jan 2009 04:29:32 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
Message-ID: <20090114032932.GC17395@wotan.suse.de>
References: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain> <20090107.125133.214628094.davem@davemloft.net> <20090108030245.e7c8ceaf.akpm@linux-foundation.org> <20090108.082413.156881254.davem@davemloft.net> <alpine.LFD.2.00.0901080842180.3283@localhost.localdomain> <1231433701.14304.24.camel@think.oraclecorp.com> <alpine.LFD.2.00.0901080858500.3283@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0901080858500.3283@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Chris Mason <chris.mason@oracle.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, peterz@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 08, 2009 at 09:05:01AM -0800, Linus Torvalds wrote:
> 
> 
> On Thu, 8 Jan 2009, Chris Mason wrote:
> > 
> > Does it make sense to hook into kupdate?  If kupdate finds it can't meet
> > the no-data-older-than 30 seconds target, it lowers the sync/async combo
> > down to some reasonable bottom.  
> > 
> > If it finds it is going to sleep without missing the target, raise the
> > combo up to some reasonable top.
> 
> I like autotuning, so that sounds like an intriguing approach. It's worked 
> for us before (ie VM).
> 
> That said, 30 seconds sounds like a _loong_ time for something like this. 
> I'd use the normal 5-second dirty_writeback_interval for this: if we can't 
> clean the whole queue in that normal background writeback interval, then 
> we try to lower the tagets. We already have that "congestion_wait()" thing 
> there, that would be a logical place, methinks.
> 
> I'm not sure how to raise them, though. We don't want to raise any limits 
> just because the user suddenly went idle. I think the raising should 
> happen if we hit the sync/async ratio, and we haven't lowered in the last 
> 30 seconds or something like that.

The other problem is that the pagecache is quite far removed from the
block device. Writeback can go to different devices, and those devices
might have different speeds at different times or different patterns.

We might autosize our dirty data to 500MB when doing linear writes because
our block device is happily cleaning them at 100MB/s and latency is
great. But then if some process inserts even 20MB worth of very seeky dirty
pages, the time to flush can go up by an order of magnitude. Let alone
500MB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
