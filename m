Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C83A36B0069
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 09:51:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f3so4347511pga.9
        for <linux-mm@kvack.org>; Sat, 20 Jan 2018 06:51:37 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u79si7190193pfi.315.2018.01.20.06.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jan 2018 06:51:36 -0800 (PST)
Date: Sat, 20 Jan 2018 09:51:31 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180120095131.57601321@gandalf.local.home>
In-Reply-To: <20180120121953.GA1096857@devbig577.frc2.facebook.com>
References: <20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180111203057.5b1a8f8f@gandalf.local.home>
	<20180111215547.2f66a23a@gandalf.local.home>
	<20180116194456.GS3460072@devbig577.frc2.facebook.com>
	<20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
	<20180117151509.GT3460072@devbig577.frc2.facebook.com>
	<20180117121251.7283a56e@gandalf.local.home>
	<20180117134201.0a9cbbbf@gandalf.local.home>
	<20180119132052.02b89626@gandalf.local.home>
	<20180120121953.GA1096857@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Sat, 20 Jan 2018 04:19:53 -0800
Tejun Heo <tj@kernel.org> wrote:

> I'm a bit worried tho because this essentially seems like "detect
> recursion, ignore messages" approach.  netcons can have a very large
> surface for bugs.  Suppressing those messages would make them
> difficult to debug.  For example, all our machines have both serial
> console (thus the slowness) and netconsole hooked up and netcons code
> has had its fair share of issues.  This would likely make tracking
> down those problems more challenging.

Well, it's not totally ignoring them. There's a variable that tells
printk how many to print before it starts ignoring them. I picked 3,
but that could very well be 5 or 10. Probably 10 is the best, because
then it would give us enough idea why printk is recursing on itself
without overloading the buffer. And I made it a variable to easily make
it a knob for userspace to tweak if need be.

> 
> Can we discuss pros and cons of this approach against offloading
> before committing to this?

I'm open. I was just thinking about the scenario that you mentioned and
how what the best way to solve it would be.

We need to define the exact problem(s) we are dealing with before we
offer a solution. The one thing I don't want is a solution looking for
a problem. I want a full understanding of what the problem exactly is
and then we can discuss various solutions, and how they solve the
problem(s). Otherwise we are just doing (to quote Linus) code masturbation.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
