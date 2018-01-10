Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C51D96B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:05:21 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m7so11816198pgv.17
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:05:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p14si5577022pli.680.2018.01.10.10.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:05:20 -0800 (PST)
Date: Wed, 10 Jan 2018 13:05:17 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110130517.6ff91716@vmware.local.home>
In-Reply-To: <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 06:05:47 -0800
Tejun Heo <tj@kernel.org> wrote:

> On Wed, Jan 10, 2018 at 02:24:16PM +0100, Petr Mladek wrote:
> > This is the last version of Steven's console owner/waiter logic.
> > Plus my proposal to hide it into 3 helper functions. It is supposed
> > to keep the code maintenable.
> > 
> > The handshake really works. It happens about 10-times even during
> > boot of a simple system in qemu with a fast console here. It is
> > definitely able to avoid some softlockups. Let's see if it is
> > enough in practice.
> > 
> > From my point of view, it is ready to go into linux-next so that
> > it can get some more test coverage.
> > 
> > Steven's patch is the v4, see
> > https://lkml.kernel.org/r/20171108102723.602216b1@gandalf.local.home  
> 
> At least for now,
> 
>  Nacked-by: Tejun Heo <tj@kernel.org>

And I NACK your NACK!

> 
> Maybe this can be a part of solution but it's really worrying how the
> whole discussion around this subject is proceeding.  You guys are
> trying to railroad actual problems.  Please address actual technical
> problems.

WE ARE!

I presented the issue at Kernel Summit and everyone agreed with me that
the issue my patch solves is a real issue. You have yet to demonstrate
how this does not solve issues.

I presented the history of printk, where it use to serialize all
printks. This was a problem when you had n CPUs doing printks at the
same time, because the n'th CPU had to wait for the n-1 CPUs to print
before it could. This was obviously an issue.

The "solution" to that was to have the first printk do the printing,
and all other printks that come in while it is printing just load their
data into the log buffer and continue. The first printk would get stuck
printing for everyone else. This was fine when we had 4 CPUs, but now
that we have boxes with 100s of CPUs, this is definitely an issue. I
demonstrated that this caused printk() to be unbounded, and there were
real word scenarios that could easily cause a printk to never stop
printing.

My solution is to make printk() have a max bounded time to print. This
is how we solve things in the Real Time world, and it makes perfect
sense in this context. The point being, the max a printk() could
print, and that is if it was really unlucky, which would be really
unlikely because it would mean we had a burst of printks followed by no
printks, the bounded time is what it takes to print the entire buffer.

My solution takes printk from its current unbounded state, and makes it
fixed bounded. Which means printk() is now a O(1) algorithm.

The solution is simple, everyone at KS agreed with it, there should be
no controversy here.

You on the other hand are showing unrealistic scenarios, and crying
that it's what you see in production, with no proof of it.

My printk solution is solid, with no risk of regressions of current
printk usages.

If anything, I'll pull theses patches myself, and push them to Linus
directly. I'll Cc you and you can make your argument to NACK them, and
I'll make mine to take them.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
