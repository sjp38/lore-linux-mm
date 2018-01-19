Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17DC26B026C
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 22:28:00 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 3so525978pfo.1
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 19:28:00 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c16-v6si464096pli.305.2018.01.18.19.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 19:27:58 -0800 (PST)
Date: Thu, 18 Jan 2018 22:27:53 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180118222753.3e3932be@vmware.local.home>
In-Reply-To: <45bc7a00-2f7f-3319-bfed-e7b9cd7a8571@lge.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-2-pmladek@suse.com>
	<f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
	<20180117120446.44ewafav7epaibde@pathway.suse.cz>
	<4a24ce1d-a606-3add-ec30-91ce9a1a1281@lge.com>
	<20180117211953.2403d189@vmware.local.home>
	<171cf5b9-2cb6-8e70-87f5-44ace35c2ce4@lge.com>
	<20180118102139.43c04de5@gandalf.local.home>
	<45bc7a00-2f7f-3319-bfed-e7b9cd7a8571@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Fri, 19 Jan 2018 11:37:13 +0900
Byungchul Park <byungchul.park@lge.com> wrote:

> On 1/19/2018 12:21 AM, Steven Rostedt wrote:
> > On Thu, 18 Jan 2018 13:01:46 +0900
> > Byungchul Park <byungchul.park@lge.com> wrote:
> >  =20
> >>> I disagree. It is like a spinlock. You can say a spinlock() that is
> >>> blocked is also waiting for an event. That event being the owner does=
 a
> >>> spin_unlock(). =20
> >>
> >> That's exactly what I was saying. Excuse me but, I don't understand
> >> what you want to say. Could you explain more? What do you disagree? =20
> >=20
> > I guess I'm confused at what you are asking for then. =20
>=20
> Sorry for not enough explanation. What I asked you for is:
>=20
>     1. Relocate acquire()s/release()s.
>     2. So make it simpler and remove unnecessary one.
>     3. So make it look like the following form,
>        because it's a thing simulating "wait and event".
>=20
>        A context
>        ---------
>        lock_map_acquire(wait); /* Or lock_map_acquire_read(wait) */
>                                /* "Read" one is better though..    */

why? I'm assuming you are talking about adding this to the current
owner off the console_owner? This is a mutually exclusive section, no
parallel access. Why the Read?

>=20
>        /* A section, we suspect a wait for an event might happen. */
>        ...
>=20
>        lock_map_release(wait);
>=20
>        The place actually doing the wait
>        ---------------------------------
>        lock_map_acquire(wait);
>        lock_map_release(wait);
>=20
>        wait_for_event(wait); /* Actually do the wait */
>=20
> Honestly, you used acquire()s/release()s as if they are cross-
> release stuff which mainly handles general waits and events,
> not only things doing "acquire -> critical area -> release".
> But that's not in the mainline at the moment.

Maybe it is more like that. Because, the thing I'm doing is passing off
a semaphore ownership to the waiter.

=46rom a previous email:

> > +			if (spin) {
> > +				/* We spin waiting for the owner to release us */
> > +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > +				/* Owner will clear console_waiter on hand off */
> > +				while (READ_ONCE(console_waiter))
> > +					cpu_relax();
> > +
> > +				spin_release(&console_owner_dep_map, 1, _THIS_IP_); =20
>=20
> Why don't you move this over "while (READ_ONCE(console_waiter))" and
> right after acquire()?
>=20
> As I said last time, only acquisitions between acquire() and release()
> are meaningful. Are you taking care of acquisitions within cpu_relax()?
> If so, leave it.

There is no acquisitions between acquire and release. To get to=20
"if (spin)" the acquire had to already been done. If it was released,
this spinner is now the new "owner". There's no race with anyone else.
But it doesn't technically have it till console_waiter is set to NULL.
Why would we call release() before that? Or maybe I'm missing something.

Or are you just saying that it doesn't matter if it is before or after
the while() loop, to just put it before? Does it really matter?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
