Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A64436B026C
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 13:54:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u27so2775305pfg.12
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 10:54:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i193si1558527pgc.763.2017.11.01.10.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 10:54:12 -0700 (PDT)
Date: Wed, 1 Nov 2017 13:54:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too
 long
Message-ID: <20171101135409.0190afb1@gandalf.local.home>
In-Reply-To: <40ed01d3-1475-cd4a-0dff-f7a6ee24d5e9@suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171031153225.218234b4@gandalf.local.home>
	<187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
	<20171101113336.19758220@gandalf.local.home>
	<40ed01d3-1475-cd4a-0dff-f7a6ee24d5e9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Wed, 1 Nov 2017 18:42:25 +0100
Vlastimil Babka <vbabka@suse.cz> wrote:

> On 11/01/2017 04:33 PM, Steven Rostedt wrote:
> > On Wed, 1 Nov 2017 09:30:05 +0100
> > Vlastimil Babka <vbabka@suse.cz> wrote:
> >   
> >>
> >> But still, it seems to me that the scheme only works as long as there
> >> are printk()'s coming with some reasonable frequency. There's still a
> >> corner case when a storm of printk()'s can come that will fill the ring
> >> buffers, and while during the storm the printing will be distributed
> >> between CPUs nicely, the last unfortunate CPU after the storm subsides
> >> will be left with a large accumulated buffer to print, and there will be
> >> no waiters to take over if there are no more printk()'s coming. What
> >> then, should it detect such situation and defer the flushing?  
> > 
> > No!
> > 
> > If such a case happened, that means the system is doing something
> > really stupid.  
> 
> Hm, what about e.g. a soft lockup that triggers backtraces from all
> CPU's? Yes, having softlockups is "stupid" but sometimes they do happen
> and the system still recovers (just some looping operation is missing
> cond_resched() and took longer than expected). It would be sad if it
> didn't recover because of a printk() issue...

I still think such a case would not be huge for the last printer.

> 
> > Btw, each printk that takes over, does one message, so the last one to
> > take over, shouldn't have a full buffer anyway.  
> 
> There might be multiple messages per each CPU, e.g. the softlockup
> backtraces.

And each one does multiple printks, still spreading the love around.

> 
> > But still, if you have such a hypothetical situation, the system should
> > just crash. The printk is still bounded by the length of the buffer.
> > Although it is slow, it will finish.  
> 
> Finish, but with single CPU doing the printing, which is wrong?

I don't think so. This is all hypothetical anyway. I need to implement
my solution, and then lets see if this can actually happen.

> 
> > Which is not the case with the
> > current situation. And the current situation (as which this patch
> > demonstrates) does happen today and is not hypothetical.  
> 
> Yep, so ideally it can be fixed without corner cases :)

If there is any corner cases. I guess the test would be to trigger a
soft lockup on all CPUs to print out a dump at the same time. But then
again, how is a soft lockup on all CPUs not any worse than a single CPU
finishing up the buffer output?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
