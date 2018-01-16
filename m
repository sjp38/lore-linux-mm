Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 760DE6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 05:14:03 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so2803076plr.14
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 02:14:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n64si1583162pfj.112.2018.01.16.02.14.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 02:14:02 -0800 (PST)
Date: Tue, 16 Jan 2018 11:13:55 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116101355.iy7q3pqxzzlpdiht@pathway.suse.cz>
References: <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116022349.GD6607@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Tue 2018-01-16 11:23:49, Sergey Senozhatsky wrote:
> On (01/15/18 15:45), Petr Mladek wrote:
> > > I think adding the preempt_disable() would fix printk() but let non
> > > printk console_unlock() still preempt.
> > 
> > I would personally remove cond_resched() from console_unlock()
> > completely.
> 
> hmm, not so sure. I think it's there for !PREEMPT systems which have
> to print a lot of messages. the case I'm speaking about in particular
> is when we register a CON_PRINTBUFFER console and need to console_unlock()
> (flush) all of the messages we currently have in the logbuf. we better
> have that cond_resched() there, I think.

Good point. I agree that we should keep the cond_resched() there
at least for now.


> > Sleeping in console_unlock() increases the chance that more messages
> > would need to be handled. And more importantly it reduces the chance
> > of a successful handover.
> > 
> > As a result, the caller might spend there very long time, it might
> > be getting increasingly far behind. There is higher risk of lost
> > messages. Also the eventual taker might have too much to proceed
> > in preemption disabled context.
> 
> yes.
> 
> > Removing cond_resched() is in sync with printk() priorities.
> 
> hmm, not sure. we have sleeping console_lock()->console_unlock() path
> for PREEMPT kernels, that cond_resched() makes the !PREEMPT kernels to
> have the same sleeping console_lock()->console_unlock().
> 
> printk()->console_unlock() seems to be a pretty independent thing,
> unfortunately (!), yet sleeping console_lock()->console_unlock()
> messes up with it a lot.

IMHO, the problem here is that console_lock is used to synchronize
too many things. It would be great to separate printk() duties
into a separate lock in the long term.

Anyway, I see it the following way. Most console_lock() callers
do the following things:

void foo()
{
	console_lock()
	foo_specific_work();
	console_unlock();
}

where console_unlock() flushes the printk buffer before actually
releasing the lock.

IMHO, it would make sense if flushing the printk buffer behaves
the same when called either from printk() or from any other path.
I mean that it should be aggressive and allow an effective
hand off.

It should be safe as long as foo_specific_work() does not take
too much time.

>From other side. The cond_resched() in console_unlock() should
be obsoleted by the hand-shake code.


> > The highest one is to get the messages out.
> > 
> > Finally, removing cond_resched() should make the behavior more
> > predictable (never preempted)
> 
> but we are always preempted in PREEMPT kernels when the current
> console_sem owner acquired the lock via console_lock(), not via
> console_trylock(). cond_resched() does the same, but for !PREEMPT.

I agree that the situation is more complicated for cond_resched()
called after console_lock(). I do not resist on removing it now.

Just one more thing. The time axe looks like:

+ cond_resched added into console_unlock in v4.5-rc1, Jan 15, 2016
     (commit 8d91f8b15361dfb438ab6)

+ preemtion enabled in printk in, v4.6-rc1, Mar 17, 2016
     (commit 6b97a20d3a7909daa0662)

They both were obvious solutions that helped to reduce the risk
of soft-lockups. The first one handled evidently safe scenarios.
The second one was even more aggressive. I would say that
they both were more or less add-hoc solutions that did not
take into account the other side effects (delaying output,
even loosing messages).

I would not say that one is a diametric difference between them.
Therefore if we remove one for a reason, we should think about
reverting the other as well. But again. I am fine if we remove
only one now.

Does this make any sense?

Best Regard,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
