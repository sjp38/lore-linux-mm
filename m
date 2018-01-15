Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6A686B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 05:17:50 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id h1so8248751wre.20
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 02:17:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si1900554wme.238.2018.01.15.02.17.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 02:17:48 -0800 (PST)
Date: Mon, 15 Jan 2018 11:17:43 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
References: <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180113072834.GA1701@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hi Sergey,

I wonder if there is still some miss understanding.

Steven and me are trying to get this patch in because we believe
that it is a step forward. We know that it is not perfect. But
we believe that it makes things better. In particular, it limits
the time spent in console_unlock() in atomic context. It does
not make it worse in preemptible context.

It does not block further improvements, including offloading
to the kthread. We will happily discuss and review further
improvements, it they prove to be necessary.

The advantage of this approach is that it is incremental. It should
be easier for review and analyzing possible regressions.

What is the aim of your mails, please?
Do you want to say that this patch might cause regressions?
Or do you want to say that it does not solve all scenarios?

Please, answer the above questions. I am still confused.


On Sat 2018-01-13 16:28:34, Sergey Senozhatsky wrote:
> On (01/12/18 07:21), Steven Rostedt wrote:
> [..]
> > Yep, but I'm still not convinced you are seeing an issue with a single
> > printk.
> 
> what do you mean by this?
> 
> > An OOM does not do everything in one printk, it calls hundreds.
> > Having hundreds of printks is an issue, especially in critical sections.
> 
> unless your console_sem owner is preempted. as long as it is preempted
> it doesn't really matter how many times we call printk from which CPUs
> and from which sections, but what matters - who is going to print that all
> out when console_sem is running again and how much time will it take.
> that's what I'm saying.

Yes, this is a problem. We might need to solve it. But the same
problem is there even without the patch. Therefore we might
solve it later. Do you agree, please?


> [..]
> > > with slow serial console, call_console_drivers() takes enough time to
> > > to make preemption of a current console_sem owner right after it irqrestore()
> > > highly possible; unless there is a spinning console_waiter. which easily may
> > > not be there; but can come in while current console_sem is preempted, why not.
> > > so when preempted console_sem owner comes back - it suddenly has a whole bunch
> > > of new messages to print and on one to hand off printing to. in a super
> > > imperfect and ugly world, BTW, this is how console_unlock() still can be
> > > O(infinite): schedule between the printed lines [even !PREEMPT kernel tries
> > 
> > I'm not fixing console_unlock(), I'm fixing printk().
> 
> which is not what I was talking about. the point was that you said
> 
> 
>  :                                                .... and what about the
>  : printks that haven't gotten out yet? Delay them to something else, and
>  : if the machine were to crash in the transfer, we lost all that data.
>  :
>  : My method, there's really no delay between a hand off. There's always
>  : an active CPU doing printing. It matches the current method which works
>  : well for getting information out. A delayed approach will break that
> 
> 
> that is not true. we can have preemption "during" hand off. hand off,
> thus, is a "delayed approach", by definition. so if you consider the
> possibility of "if the machine were to crash in the transfer, we lost
> all that data" and if you consider this to be important [otherwise you
> wouldn't bring that up, would you] then the reality is that your patch
> has the same problem as printk_kthread.
> 
> so very schematically, for hand-off it's something like
> 
> 	if (... console_trylock_spinning()) // grabbed the ownership
> 
> 		<< ... preempted ... >>
> 
> 		console_unlock();
> 
> 
> for printk_kthread it's something like
> 
> 		wake_up_process(printk_kthread);
> 		up(console_sem);

Good question!

Is this really the same? The console_trylock_spinning() caller will
get preempted only when interrupts (timers?) still work. This is
a sign that the system is still somehow living. Also this information
is quite up-to-date because you checked this after a relatively
short busy wait.

On the other hand, wake_up_process() just puts printk_kthread
into a running state. It does not check if the processes are
still actively being rescheduled on the system. It might check
some flags. But they might be pretty outdated when this is
done after half of the watchdog limit.


In each case, the preemption after console_trylock_spinning()
has the same effect like preemption in console_unlock().
It is possible already now. Therefore I do not consider
this as a regression.


> hence the following:
> 
> [..]
> > > reverting 6b97a20d3a7909daa06625d4440c2c52d7bf08d7 may be the right
> > > thing after all.
> 
> this was cryptic and misleading. sorry.
> some clarifications.
> 
> what I meant was that with 6b97a20d3a7909daa06625d4440c2c52d7bf08d7
> I think I badly broke printk() [some of paths]. I know what I tried
> to fix (and you don't have to explain to me what a lock up is) with
> that patch, but I don't think the patch ended up to be a clear win.
> a very simple explanation would be:
> 
> instead of having a direct nonpreemptible path
> 
> 	logbuf -> for(;;) call_console_drivers -> happy user
> 
> we now have
> 
> 	logbuf -> for(;;) { call_console_drivers, scheduler ... ???} -> happy user
> 
> which is a big change. with a non-zero potential for regressions.
> and it didn't take long to find out that not all "happy users" were
> exactly happy with the new scheme of things. glance through Tetsuo's
> emails [see links in my another email], Tetsuo reported that printk can
> stall for minutes now. basically, the worse the system state is the lower
> printk throughput can be [down to zero chars in the worst case]. that's
> why I think that my patch was a mistake. and that's why in my out-of-tree
> patches I'm moving towards the non-preemptible path from logbuf through
> console to a happy user [just like it used to be]. but, obviously, I can't
> just restore preempt_disable()/preempt_enable() in vprintk_emit(). that's
> why I bound console_unlock() to watchdog threshold and move towards the
> batched non-preemptible print outs (enabling preemption and up()-ing the
> console_sem at the end of each print out batch). this is not super good,
> preemption is still here, but at least not after every line console_unlock()
> prints. up() console_sem also increases chances that, for instance, systemd
> or any other task that is sleeping in TASK_UNINTERRUPTIBLE on console_sem
> now has a chance to be woken up sooner (not only after we flush all pending
> logbuf messages and finally up() the console_sem).

I see your point. But this is an orthogonal problem. It is more about
loosing messages because console_unlock() is slow when sleeping. This
patch is about limiting time spent in console_unlock() in atomic
context.

If you want to revert the above mentioned commit, please send a patch
so that we could discuss this separately.

Best Regards,
Petr


PS: Sergey, you have many good points. The printk-stuff is very
complex and we could spend years discussing the perfect solution.

But I am never sure if you discuss this in this thread because
this patch might cause regression or because it does not address
all the issues.

Could we please make it more simple? If you believe that this
patch might cause regression than please say this clearly.
You actually mentioned the word regression few times.
I am not sure if we managed to persuade you about the opposite.

If you think that this patch is not good enough and not worth
merging upstream, please state this clearly as well.

If you think that this patch does not address all problems,
please send further improvements on top of it so that we
could discuss this. If you want to discuss the problems
in advance, please open another thread. IMHO, this thread
brought many ideas for the perfect solution but it is
already too scattered.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
