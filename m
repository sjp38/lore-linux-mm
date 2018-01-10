Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4396B025F
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 17:44:56 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id v193so900394qka.15
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 14:44:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e64sor12573353qkb.113.2018.01.10.14.44.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 14:44:54 -0800 (PST)
Date: Wed, 10 Jan 2018 14:44:51 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110224451.GI3460072@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180110181252.GK3668920@devbig577.frc2.facebook.com>
 <20180110134157.1c3ce4b9@vmware.local.home>
 <20180110185747.GO3668920@devbig577.frc2.facebook.com>
 <20180110141758.1f88e1a0@vmware.local.home>
 <20180110193451.GB3460072@devbig577.frc2.facebook.com>
 <20180110144455.66fe53c9@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110144455.66fe53c9@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

On Wed, Jan 10, 2018 at 02:44:55PM -0500, Steven Rostedt wrote:
> Yes, there can be the case that printks are added via an interrupt, but
> then again, it's an issue that a single CPU. And printks from interrupt
> context should be considered critical, part of the ASAP category. If
> they are not critical, then they shouldn't be doing printks. That may
> be a place were we can add a "printk_delay", for things like non
> critical printks in interrupt context, that can trigger offloading?

Ideally, if we can annoate all those, that would be great.  I don't
feel too confident about that tho.  Here is one network driver that we
deal with often.

  $ wc -l $(git ls-files drivers/net/ethernet/mellanox/mlx5) | tail -1
    48029 total

It's close to 50k lines of code and AFAICT this seems to be the trend.
Most things which are happening in the driver are complicated and
sometimes lead to surprising behaviors.  With memory allocation
failures thrown in, idk.

I think our exposure to this sort of problem is pretty wide and we
can't reasonably keep close eyes on them, especially for problems
which only happen under high stress conditions which aren't tested
that easily.

> > Oh yeah, sure.  It might actually be pretty simple to combine into
> > your solution.  For example, can't we just always make sure that
> > there's at least one sleepable context which participates in your
> > pingpongs, which only kicks in when a particular context is trapped
> > too long?
> 
> The solution can be extended to that if the need exists, yes.

I think it'd be really great if the core code can protect itself
against these things going haywire.  We can ignore messages generated
while being recursive from netconsole, but that would mean, for
example, if that giant driver messes up in that path (netconsole under
memory pressure), it'd be painful to debug.  So, if we can, it'd be
really great to have a generic protection which can handle these
situations.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
