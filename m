Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 806EC280286
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:29:27 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 64so4817311pgc.17
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:29:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b8sor930143pfl.11.2018.01.16.22.29.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 22:29:26 -0800 (PST)
Date: Wed, 17 Jan 2018 15:29:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117062920.GD423@jagdpanzerIV>
References: <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
 <20180116101355.iy7q3pqxzzlpdiht@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116101355.iy7q3pqxzzlpdiht@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/16/18 11:13), Petr Mladek wrote:
[..]
> IMHO, it would make sense if flushing the printk buffer behaves
> the same when called either from printk() or from any other path.
> I mean that it should be aggressive and allow an effective
> hand off.
> 
> It should be safe as long as foo_specific_work() does not take
> too much time.
> 
> From other side. The cond_resched() in console_unlock() should
> be obsoleted by the hand-shake code.

hm, let's not have too optimistic expectations. hand off works in very
specific conditions. console is not exclusively owned by printk, and
console_sem is not printk's own lock. even things like

	systemd -> n_tty_write -> do_output_char -> con_write

involves console_lock() and console_unlock(). IOW user space
logging/debugging can cause printk stalls, and vice versa.

by the way, do_con_write() explicitly calls console_conditional_schedule()
under console_sem, before it goes to console_unlock(). so the scope of
"situation normal, console_sem locked, the owner scheduled out" is much
bigger than just vprintk_emit() -> console_unlock(). IMHO.

and there are even more things there. personally, I don't think
that hand off is enough to obsolete anything in that area.

[...]
> They both were obvious solutions that helped to reduce the risk
> of soft-lockups. The first one handled evidently safe scenarios.
> The second one was even more aggressive. I would say that
> they both were more or less add-hoc solutions that did not
> take into account the other side effects (delaying output,
> even loosing messages).

agreed.

> I would not say that one is a diametric difference between them.
> Therefore if we remove one for a reason, we should think about
> reverting the other as well. But again. I am fine if we remove
> only one now.
> 
> Does this make any sense?

I see cond_resched() as a mirroring of console_lock()->console_unlock()
behaviour on PREEMPT systems, and as such it looks valid to me, so we
probably better keep it there. IMHO.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
