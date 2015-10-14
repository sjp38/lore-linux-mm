Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5A86B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 15:38:33 -0400 (EDT)
Received: by ykey125 with SMTP id y125so57620131yke.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:38:33 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id v128si4382239ywb.328.2015.10.14.12.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 12:38:32 -0700 (PDT)
Received: by ykfy204 with SMTP id y204so34897497ykf.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:38:32 -0700 (PDT)
Date: Wed, 14 Oct 2015 15:38:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
Message-ID: <20151014193829.GD12799@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
 <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
 <20151014165729.GA12799@mtj.duckdns.org>
 <CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
 <20151014190259.GC12799@mtj.duckdns.org>
 <CA+55aFz27G4gLS9AFs6hHJfULXAqA=tM5KA=YvBH8MaZ+sT-VA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz27G4gLS9AFs6hHJfULXAqA=tM5KA=YvBH8MaZ+sT-VA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

Hello, Linus.

On Wed, Oct 14, 2015 at 12:16:48PM -0700, Linus Torvalds wrote:
> On Wed, Oct 14, 2015 at 12:02 PM, Tejun Heo <tj@kernel.org> wrote:
> >
> > But wasn't add_timer() always CPU-local at the time?  add_timer()
> > allowing cross-cpu migrations came way after that.
> 
> add_timer() has actually never been "local CPU only" either.
> 
> What add_timer() does is to keep the timer on the old CPU timer wheel
> if it was active, and if it wasn't, put it on the current CPU timer
> wheel.

Doesn't seem that way.  This is from 597d0275736d^ - right before
TIMER_NOT_PINNED is introduced.  add_timer() eventually calls into
__mod_timer().

static inline int
__mod_timer(struct timer_list *timer, unsigned long expires, bool pending_only)
{
	...
	base = lock_timer_base(timer, &flags);
	...
	new_base = __get_cpu_var(tvec_bases);

	if (base != new_base) {
		...
		if (likely(base->running_timer != timer)) {
			/* See the comment in lock_timer_base() */
			timer_set_base(timer, NULL);
			spin_unlock(&base->lock);
			base = new_base;
			spin_lock(&base->lock);
			timer_set_base(timer, base);
		}
	}
	...
	internal_add_timer(base, timer);
	...
}

It looks like the timers for work items will be reliably queued on the
local CPU.

> So again, by pure *accident*, if you don't end up ever modifying an
> already-active timer, then yes, it ended up being local. But even
> then, things like suspend/resume can move timers around, afaik, so
> even then it has never been a real guarantee.
> 
> And I see absolutely no sign that the local cpu case has ever been intentional.

Heh, I don't think much in this area is intended.  It's mostly all
historical accidents and failures to get things cleaned up in time.

> Now, obviously, that said there is obviously at least one case that
> seems to have relied on it (ie the mm/vmstat.c case), but I think we
> should just fix that.
> 
> If it turns out that there really are *lots* of cases where
> "schedule_delayed_work()" expects the work to always run on the CPU
> that it is scheduled on, then we should probably take your patch just
> because it's too painful not to.
> 
> But I'd like to avoid that if possible.

So, the following two things bother me about this.

* Given that this is the first reported case of breakage, I don't
  think this is gonna cause lots of criticial issues; however, the
  only thing this indicates is that there simply hasn't been enough
  cases where timers actualy migrate.  If we end up migrating timers
  more actively in the future, it's possible that we'll see more
  breakages which will likely be subtler.

* This makes queue_delayed_work() behave differently from queue_work()
  and when I checked years ago the local queueing guarantee was
  definitely being depended upon by some users.

I do want to get rid of the local queueing guarnatee for all work
items.  That said, I don't think this is the right way to do it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
