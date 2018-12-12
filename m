Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 317698E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 03:10:41 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so11644527pgu.18
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 00:10:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor24709095plk.32.2018.12.12.00.10.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 00:10:39 -0800 (PST)
Date: Wed, 12 Dec 2018 17:10:34 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212081034.GA32687@jagdpanzerIV>
References: <20181004085515.GC12879@jagdpanzerIV>
 <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
 <20181022100952.GA1147@jagdpanzerIV>
 <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV>
 <20181212064841.GB2746@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212064841.GB2746@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Daniel Wang <wonderfly@google.com>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (12/12/18 01:48), Sasha Levin wrote:
> > > > I guess we still don't have a really clear understanding of what exactly
> > > is going in your system
> > > 
> > > I would also like to get to the bottom of it. Unfortunately I haven't
> > > got the expertise in this area nor the time to do it yet. Hence the
> > > intent to take a step back and backport Steven's patch to fix the
> > > issue that has resurfaced in our production recently.
> > 
> > No problem.
> > I just meant that -stable people can be a bit "unconvinced".
> 
> The -stable people tried adding this patch back in April, but ended up
> getting complaints up the wazoo (https://lkml.org/lkml/2018/4/9/154)
> about how this is not -stable material.

OK, really didn't know that! I wasn't Cc-ed on that AUTOSEL email,
and I wasn't Cc-ed on this whole discussion and found it purely
accidentally while browsing linux-mm list.

I understand what Petr meant by his email. Not arguing; below are just
my 5 cents.

> So yes, testing/acks welcome :)

OK. The way I see it (and I can be utterly wrong here):

The patch set in question, most likely and probably (*and those are
theories*), makes panic() deadlock less likely because panic_cpu waits
for console_sem owner to release uart_port/console_owner locks before
panic_cpu pr_emerg("Kernel panic - not syncing"), dump_stack()-s and
brings other CPUs down via stop IPI or NMI.
So a precondition is
		panic CPU != uart_port->lock owner CPU

If the panic happens on the same CPU which holds the uart_port spin_lock,
then the deadlock is still there, just like before; we have another patch
which attempts to fix this (it makes console drivers re-entrant from
panic()).

So if you are willing to backport this set to -stable, then I wouldn't
mind, probably would be more correct if we don't advertise this as a
"panic() deadlock fix" tho; we know that deadlock is still possible.
And there will be another -stable backport request in a week or so.


In the meantime, I can add my Acked-by to this backport if it helps.

/* Assuming that my theories explain what's happening with
   Daniel's systems. */

	-ss
