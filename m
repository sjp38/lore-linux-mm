Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E756D6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 12:05:34 -0500 (EST)
Date: Thu, 8 Jan 2009 09:05:01 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
In-Reply-To: <1231433701.14304.24.camel@think.oraclecorp.com>
Message-ID: <alpine.LFD.2.00.0901080858500.3283@localhost.localdomain>
References: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>  <20090107.125133.214628094.davem@davemloft.net>  <20090108030245.e7c8ceaf.akpm@linux-foundation.org>  <20090108.082413.156881254.davem@davemloft.net>  <alpine.LFD.2.00.0901080842180.3283@localhost.localdomain>
 <1231433701.14304.24.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, peterz@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>



On Thu, 8 Jan 2009, Chris Mason wrote:
> 
> Does it make sense to hook into kupdate?  If kupdate finds it can't meet
> the no-data-older-than 30 seconds target, it lowers the sync/async combo
> down to some reasonable bottom.  
> 
> If it finds it is going to sleep without missing the target, raise the
> combo up to some reasonable top.

I like autotuning, so that sounds like an intriguing approach. It's worked 
for us before (ie VM).

That said, 30 seconds sounds like a _loong_ time for something like this. 
I'd use the normal 5-second dirty_writeback_interval for this: if we can't 
clean the whole queue in that normal background writeback interval, then 
we try to lower the tagets. We already have that "congestion_wait()" thing 
there, that would be a logical place, methinks.

I'm not sure how to raise them, though. We don't want to raise any limits 
just because the user suddenly went idle. I think the raising should 
happen if we hit the sync/async ratio, and we haven't lowered in the last 
30 seconds or something like that.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
