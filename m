Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id B1EFF6B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 16:10:34 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so25889462igb.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:10:34 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id d79si3421880ioj.47.2015.10.14.13.10.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 13:10:34 -0700 (PDT)
Received: by iow1 with SMTP id 1so68342421iow.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:10:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151014193829.GD12799@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
	<CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	<20151014165729.GA12799@mtj.duckdns.org>
	<CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
	<20151014190259.GC12799@mtj.duckdns.org>
	<CA+55aFz27G4gLS9AFs6hHJfULXAqA=tM5KA=YvBH8MaZ+sT-VA@mail.gmail.com>
	<20151014193829.GD12799@mtj.duckdns.org>
Date: Wed, 14 Oct 2015 13:10:33 -0700
Message-ID: <CA+55aFyzsMYcRX3V5CEWB4Zb-9BuRGCjib3DMXuX5y9nBWiZ1w@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 14, 2015 at 12:38 PM, Tejun Heo <tj@kernel.org> wrote:
>
> Doesn't seem that way.  This is from 597d0275736d^ - right before
> TIMER_NOT_PINNED is introduced.  add_timer() eventually calls into
> __mod_timer().
>
>                 if (likely(base->running_timer != timer)) {
>                         /* See the comment in lock_timer_base() */
>                         timer_set_base(timer, NULL);
>                         spin_unlock(&base->lock);
>                         base = new_base;
>                         spin_lock(&base->lock);
>                         timer_set_base(timer, base);
>
> It looks like the timers for work items will be reliably queued on the
> local CPU.

.. unless they are running on another cpu at the time, yes.

Also, the new base is not necessarily the current cpu base, although I
think the exceptions to that are pretty rare (ie you have to enable
timer migration etc)

Which I guess might not actually happen with workqueue timers due to
the extra workqueue locking thing, but I'm not sure. It's going to be
very unlikely, regardless, I agree.

> Heh, I don't think much in this area is intended.  It's mostly all
> historical accidents and failures to get things cleaned up in time.

No argument there.

> So, the following two things bother me about this.
>
> * Given that this is the first reported case of breakage, I don't
>   think this is gonna cause lots of criticial issues; however, the
>   only thing this indicates is that there simply hasn't been enough
>   cases where timers actualy migrate.  If we end up migrating timers
>   more actively in the future, it's possible that we'll see more
>   breakages which will likely be subtler.

I agree that that's a real concern.

At the same time, some of the same issues that are pushing people to
move timers around (put idle cores to deeper sleeps etc) would also
argue for moving delayed work around to other cpus if possible.

So I agree that there is a push to make timer cpu targets more dynamic
in a way we historically didn't really have. At the same time, I think
the same forces that want to move timers around would actually likely
want to move delayed work around too...

> * This makes queue_delayed_work() behave differently from queue_work()
>   and when I checked years ago the local queueing guarantee was
>   definitely being depended upon by some users.

Yes. But the delayed work really is different. By definition, we know
that the current cpu is busy and active _right_now_, and so keeping
work on that cpu isn't obviously wrong.

But it's *not* obviously right to schedule something on that
particular cpu a few seconds from now, when it might be happily asleep
and there might be better cpus to bother..

> I do want to get rid of the local queueing guarnatee for all work
> items.  That said, I don't think this is the right way to do it.

Hmm. I guess that for being past rc5, taking your patch is the safe
thing. I really don't like it very much, though.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
