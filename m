Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17F8A6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 06:51:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x24so14636503pge.13
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 03:51:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z75si6540964pfd.119.2018.01.18.03.51.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 03:51:39 -0800 (PST)
Date: Thu, 18 Jan 2018 12:51:30 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180118115130.eomcbftg4qvmrui7@pathway.suse.cz>
References: <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
 <20180111215547.2f66a23a@gandalf.local.home>
 <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117200551.GW3460072@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117200551.GW3460072@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed 2018-01-17 12:05:51, Tejun Heo wrote:
> Hello, Steven.
> 
> On Wed, Jan 17, 2018 at 12:12:51PM -0500, Steven Rostedt wrote:
> > From what I gathered, you said an OOM would trigger, and then the
> > network console would not be able to allocate memory and it would
> > trigger a printk too, and cause an infinite amount of printks.
> 
> Yeah, it falls into back-and-forth loop between the OOM code and
> netconsole path.
> 
> > This could very well be a great place to force offloading. If a printk
> > is called from within a printk, at the same context (normal, softirq,
> > irq or NMI), then we should trigger the offloading.
> 
> I was thinking more of a timeout based approach (ie. if stuck for
> longer than X or X messages, offload), but if local feedback loop is
> the only thing we're missing after your improvements, detecting that
> specific condition definitely works and is likely a better approach in
> terms of message delivery guarantee.

I think that we could combine both. The recursion can be detected
rather easily and immediately so there is no reason to wait.

Once we have the code for offloading from recursion then we could
kick_offload_thread() also from other reasons, e.g. when
console_unlock() takes too long.

I think that Sergey is already playing with this. It seems
that we all could be happy in the end.


Best Regards,
Petr

PS: I am sorry for the answer yesterday. Tejun's mail did not mention
any details about the problem. I evidently forgot them. I have OOM
and printk issues associated with Tetsuo. So I messed it. Believe
me. It is a big relief to realize that we are not in the cycle
again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
