Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E56C6B1DA5
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 21:23:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l15-v6so402633pff.5
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 18:23:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i128sor43509679pgc.75.2018.11.19.18.23.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 18:23:20 -0800 (PST)
Date: Tue, 20 Nov 2018 11:23:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: request for 4.14-stable: fd5f7cde1b85 ("printk: Never set
 console_may_schedule in console_trylock()")
Message-ID: <20181120022315.GA4231@jagdpanzerIV>
References: <20181111202045.vocb3dthuquf7h2y@debian>
 <20181119151807.GE5340@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119151807.GE5340@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: stable@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>

On (11/19/18 16:18), Greg Kroah-Hartman wrote:
> On Sun, Nov 11, 2018 at 08:20:45PM +0000, Sudip Mukherjee wrote:
> > Hi Greg,
> > 
> > This was not marked for stable but seems it should be in stable.
> > Please apply to your queue of 4.14-stable.
> 
> Now queued up, thanks.

Very sorry for the late reply!

Greg, Sudip, the commit in question is known to be controversial. It
does fix some lockups, but it also does make printk non-atomic in some
cases: the printing task can get preempted which can cause printk
stalls (no messages on serial consoles, until the printing task gets
rescheduled again) in some dark-corner cases.

I think Tetsuo is the only person who ever reported printk stalls,
probably because he is the only person who is testing very tough
OOM-scenarios on a regular basis.

So, long story short, I call that commit "a mistake" and we have
reverted it upstream, to make printk always atomic (just like it
should be).

As of printk lockups, Steven Rostedt has contributed a much better
solution.

	-ss
