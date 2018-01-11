Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26A2A6B026B
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 06:51:06 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id z83so1309841wmc.5
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 03:51:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si2669516wra.111.2018.01.11.03.51.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 03:51:04 -0800 (PST)
Date: Thu, 11 Jan 2018 12:50:59 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111115059.GA24419@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111103845.GB477@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu 2018-01-11 19:38:45, Sergey Senozhatsky wrote:
> On (01/11/18 10:34), Petr Mladek wrote:
> [..]
> > > except that handing off a console_sem to atomic task when there
> > > is   O(logbuf) > watchdog_thresh   is a regression, basically...
> > > it is what it is.
> > 
> > How this could be a regression? Is not the victim that handles
> > other printk's random? What protected the atomic task to
> > handle the other printks before this patch?
> 
> the non-atomic -> atomic context console_sem transfer. we previously
> would have kept the console_sem owner to its non-atomic owner. we now
> will make sure that if printk from atomic context happens then it will
> make it to console_unlock() loop.
> emphasis on O(logbuf) > watchdog_thresh.

Sergey, please, why do you completely and repeatedly ignore that
argument about statistical effects?

Yes, the above scenario is possible. But Steven's patch might also move the
owner from atomic context to a non-atomic one. The chances should be
more or less equal. The main advantage is that the owner is moved.
This should statistically lower the chance of a soft-lockup.

> 
> > Or do you have a system that started to suffer from softlockups
> > with this patchset and did not do this before?
> [..]
> > Do you know about any system where this patch made the softlockup
> > deterministically or statistically more likely, please?
> 
> I have explained many, many times why my boards die just like before.
> why would I bother collecting any numbers...

Is it with your own printk stress tests or during "normal" work?

If it is during a normal work, is there any chance that we
could have a look at the logs?

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
