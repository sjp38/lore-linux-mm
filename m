Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 48A806B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 12:37:07 -0400 (EDT)
Received: by iow1 with SMTP id 1so27310397iow.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:37:07 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id u68si206277ioi.25.2015.10.13.09.37.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 09:37:06 -0700 (PDT)
Received: by ioii196 with SMTP id i196so27048308ioi.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:37:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
References: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
	<201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
	<201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
	<CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
	<201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
Date: Tue, 13 Oct 2015 09:37:06 -0700
Message-ID: <CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
Subject: Re: Silent hang up caused by pages being not scanned?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

On Tue, Oct 13, 2015 at 5:21 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> If I remove
>
>         /* Any of the zones still reclaimable?  Don't OOM. */
>         if (zones_reclaimable)
>                 return 1;
>
> the OOM killer is invoked even when there are so much memory which can be
> reclaimed after written to disk. This is definitely premature invocation of
> the OOM killer.

Right. The rest of the code knows that the return value right now
means "there is no memory at all" rather than "I made progress".

> Yes. But we can't simply do
>
>         if (order <= PAGE_ALLOC_COSTLY_ORDER || ..
>
> because we won't be able to call out_of_memory(), can we?

So I think that whole thing is kind of senseless. Not just that
particular conditional, but what it *does* too.

What can easily happen is that we are a blocking allocation, but
because we're __GFP_FS or something, the code doesn't actually start
writing anything out. Nor is anything congested. So the thing just
loops.

And looping is stupid, because we may be not able to actually free
anything exactly because of limitations like __GFP_FS.

So

 (a) the looping condition is senseless

 (b) what we do when looping is senseless

and we actually do try to wake up kswapd in the loop, but we never
*wait* for it, so that's largely pointless too.

So *of*course* the direct reclaim code has to set "I made progress",
because if it doesn't lie and say so, then the code will randomly not
loop, and will oom, and things go to hell.

But I hate the "let's tweak the zone_reclaimable" idea, because it
doesn't actually fix anything. It just perpetuates this "the code
doesn't make sense, so let's add *more* senseless heusristics to this
whole loop".

So instead of that senseless thing, how about trying something
*sensible*. Make the code do something that we can actually explain as
making sense.

I'd suggest something like:

 - add a "retry count"

 - if direct reclaim made no progress, or made less progress than the target:

      if (order > PAGE_ALLOC_COSTLY_ORDER) goto noretry;

 - regardless of whether we made progress or not:

      if (retry count < X) goto retry;

      if (retry count < 2*X) yield/sleep 10ms/wait-for-kswapd and then
goto retry

   where 'X" is something sane that limits our CPU use, but also
guarantees that we don't end up waiting *too* long (if a single
allocation takes more than a big fraction of a second, we should
probably stop trying).

The whole time-based thing might even be explicit. There's nothing
wrong with doing something like

    unsigned long timeout = jiffies + HZ/4;

at the top of the function, and making the whole retry logic actually
say something like

    if (time_after(timeout, jiffies)) goto noretry;

(or make *that* trigger the oom logic, or whatever).

Now, I realize the above suggestions are big changes, and they'll
likely break things and we'll still need to tweak things, but dammit,
wouldn't that be better than just randomly tweaking the insane
zone_reclaimable logic?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
