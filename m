Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61F7D6B0007
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 06:22:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z8-v6so1268451pgc.22
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 03:22:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y67sor249348pff.127.2018.04.27.03.22.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Apr 2018 03:22:50 -0700 (PDT)
Date: Fri, 27 Apr 2018 19:22:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180427102245.GA591@jagdpanzerIV>
References: <20180420080428.622a8e7f@gandalf.local.home>
 <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
 <20180420101751.6c1c70e8@gandalf.local.home>
 <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
 <20180420111307.44008fc7@gandalf.local.home>
 <20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
 <20180423073603.6b3294ba@gandalf.local.home>
 <20180423124502.423fb57thvbf3zet@pathway.suse.cz>
 <20180425053146.GA25288@jagdpanzerIV>
 <20180426094211.okftwdzgfn72rik3@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180426094211.okftwdzgfn72rik3@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/26/18 11:42), Petr Mladek wrote:
[..]
> 
> Believe me, I could perfectly understand the desire to create perfect
> defensive solutions that would never break anything. It is not easy
> to decide when the best-effort solutions are worth the risk.

Yes, but my point is - I don't think we clearly understand the root
cause of the problem. See below [you can jump over the next section].

[..]
> Honestly, I do not believe that console drivers are like Scheherazade.
> They are not able to make up long interesting stories. Let's say that
> lockdep splat has more than 100 lines but it can happen only once.
> Let's say that WARNs have about 40 lines. I somehow doubt that we
> could ever see 10 different WARN calls from one con->write() call.

The problem here is that it takes a human being with IQ to tell what's
repetitive, what's useless and what's not.

	vprintk(...)
	{
		if (!__ratelimit())
			return;
	}

has zero IQ to make such decisions. Sorry, the numbers don't work for me.
"Console drivers added 100 lines in 1 hour" does not tell me that we had
"an infinite console_unlock() loop".
Dunno. Quite likely I'm wrong. Wouldn't be the first time ever. But it's
unclear to me why we are out of options, without even looking at
logs, but... May be.


> > But we first need a real reason. Right now it looks to me like
> > we have "a solution" to a problem which we have never witnessed.
> 
> I am trying to find a "simple" and generic solution for the problem
> reported by Tejun:
[..]
> 1. Console is IPMI emulated serial console.  Super slow.  Also
>    netconsole is in use.
> 2. System runs out of memory, OOM triggers.
> 3. OOM handler is printing out OOM debug info.
> 4. While trying to emit the messages for netconsole, the network stack
>    / driver tries to allocate memory and then fail, which in turn
>    triggers allocation failure or other warning messages.  printk was
>    already flushing, so the messages are queued on the ring.
> 5. OOM handler keeps flushing but 4 repeats and the queue is never
>    shrinking.  Because OOM handler is trapped in printk flushing, it
>    never manages to free memory and no one else can enter OOM path
>    either, so the system is trapped in this state.
> </paste>

Yes, and that's why I want to take a look at the logs/backtraces.

I had a very-very quick look at netconsole code, and some parts of net
code [skb allocation, etc]. And I didn't manage to find that "every
console driver call adds new messages to the logbuf".

OK, suppose that at some point netcon or net stack does kmalloc(GFP_ATOMIC)
or alloc_pages(GFP_ATOMIC). So if it was kmalloc() and we need to
cache_grow_begin()->kmem_getpages() or ___slab_alloc()->new_slab(),
then:

- kmem_getpages() can slab_out_of_memory().
  But slab_out_of_memory():

 a) ratelimited to DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST
 b) enabled only `#if DEBUG' [probably out of consideration]

- So we end up in __alloc_pages_slowpath():

  alloc_pages() -> __alloc_pages_slowpath()
or
  kmem_getpages()->__alloc_pages_slowpath()
or
  ___slab_alloc()->new_slab()->__alloc_pages_slowpath()

__alloc_pages_slowpath() can call warn_alloc(), yes.

But warn_alloc() is also ratelimted to DEFAULT_RATELIMIT_INTERVAL and
DEFAULT_RATELIMIT_BURST.


That "triggers allocation failure or other warning messages" part is
questionable.


1) Does the bug report actually say that - DEFAULT_RATELIMIT_INTERVAL
and DEFAULT_RATELIMIT_BURST in MM are not good enough? If so, then why do
we "fix" printk()? Can we just tweak the rate limiting in MM code?

2) If the bug report is saying that MM code has non-ratelimited
warnings/printouts in allocation path - then we need to rate limit
those; the same way it's done in slab_out_of_memory() / warn_alloc().


OK...

So DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST allows
up to 10 warn_alloc()-s in 5 seconds. Let's assume that allocation
failure backtrace is around 50 lines [including registers print out].
Along with backtrace we have Mem-info print out. Let's assume that it's
around 30 lines. So a single warn_alloc() can be around 80 lines.
Mem-info lines are very long, so it would be reasonable to count the
number of characters here, but let's just use lines. So we can have around
800 lines in just 10 seconds.

Now, I think "Console is IPMI emulated serial console.  Super slow."
is a critically important bit of information. [And that's why we better
count the number of characters in OOM report, not the lines].

We print to the consoles sequentially, hence netconsole becomes as "fast"
as that super slow IPMI console. MM ratelimit, meanwhile, does not care.
The slower IPMI is, the "sooner" netconsole gets its chance to add 10 more
kmalloc()->warn_alloc() to the logbuf - another ~800 lines, or may be
significantly more than that. Because of slow IPMI we don't call
netconsole frequent enough to get advantage of the rate limiting in
warn_alloc().

[And notice how "100/1000 lines per hour" is a bad news in this regard].


If this is the case, and if my assumptions are valid, then we really
should not rate limit console_drivers()->printk(). Mem-info print outs
don't seem to be "a repetitive garbage" that we can easily discard.
Those are important bits of information, which show the OOM/reclaimer
progress, and so on.


So, Petr, let's slow down for a second. There are things that are
not completely clear.

Opinions?

[..]
> For me it is hard to believe that all these possible errors will be
> cured just by offloading. Not to say that offloading is not trivial
> and there is some resistance against it.

Well, I didn't say this. All I said was that I really like that "the patch
does not pretend to be smart and does not drop random printk() messages"
part.

	-ss
