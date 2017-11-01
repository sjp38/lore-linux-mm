Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B96316B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 13:43:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w105so1623211wrc.20
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 10:43:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a27si453605edb.366.2017.11.01.10.43.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 10:43:48 -0700 (PDT)
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171031153225.218234b4@gandalf.local.home>
 <187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
 <20171101113336.19758220@gandalf.local.home>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <40ed01d3-1475-cd4a-0dff-f7a6ee24d5e9@suse.cz>
Date: Wed, 1 Nov 2017 18:42:25 +0100
MIME-Version: 1.0
In-Reply-To: <20171101113336.19758220@gandalf.local.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On 11/01/2017 04:33 PM, Steven Rostedt wrote:
> On Wed, 1 Nov 2017 09:30:05 +0100
> Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>>
>> But still, it seems to me that the scheme only works as long as there
>> are printk()'s coming with some reasonable frequency. There's still a
>> corner case when a storm of printk()'s can come that will fill the ring
>> buffers, and while during the storm the printing will be distributed
>> between CPUs nicely, the last unfortunate CPU after the storm subsides
>> will be left with a large accumulated buffer to print, and there will be
>> no waiters to take over if there are no more printk()'s coming. What
>> then, should it detect such situation and defer the flushing?
> 
> No!
> 
> If such a case happened, that means the system is doing something
> really stupid.

Hm, what about e.g. a soft lockup that triggers backtraces from all
CPU's? Yes, having softlockups is "stupid" but sometimes they do happen
and the system still recovers (just some looping operation is missing
cond_resched() and took longer than expected). It would be sad if it
didn't recover because of a printk() issue...

> Btw, each printk that takes over, does one message, so the last one to
> take over, shouldn't have a full buffer anyway.

There might be multiple messages per each CPU, e.g. the softlockup
backtraces.

> But still, if you have such a hypothetical situation, the system should
> just crash. The printk is still bounded by the length of the buffer.
> Although it is slow, it will finish.

Finish, but with single CPU doing the printing, which is wrong?

> Which is not the case with the
> current situation. And the current situation (as which this patch
> demonstrates) does happen today and is not hypothetical.

Yep, so ideally it can be fixed without corner cases :)

Vlastimil

> -- Steve
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
