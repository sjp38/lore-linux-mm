Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2B782F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 14:34:50 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so20083540igb.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 11:34:50 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id i36si5415297ioo.118.2015.10.16.11.34.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 11:34:49 -0700 (PDT)
Received: by iow1 with SMTP id 1so133922609iow.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 11:34:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151016155716.GF19597@dhcp22.suse.cz>
References: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
	<201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
	<201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
	<CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
	<201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
	<CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
	<20151015131409.GD2978@dhcp22.suse.cz>
	<20151016155716.GF19597@dhcp22.suse.cz>
Date: Fri, 16 Oct 2015 11:34:48 -0700
Message-ID: <CA+55aFynmzy=3f5ae6iAYC7o_27C1UkNzn9x4OFjrW6j6bV9rw@mail.gmail.com>
Subject: Re: Silent hang up caused by pages being not scanned?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Fri, Oct 16, 2015 at 8:57 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> OK so here is what I am playing with currently. It is not complete
> yet.

So this looks like it's going in a reasonable direction. However:

> +               if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> +                               ac->high_zoneidx, alloc_flags, target)) {
> +                       /* Wait for some write requests to complete then retry */
> +                       wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> +                       goto retry;
> +               }

I still think we should at least spend some time re-thinking that
"wait_iff_congested()" thing. We may not actually be congested, but
might be unable to write anything out because of our allocation flags
(ie not allowed to recurse into the filesystems), so we might be in
the situation that we have a lot of dirty pages that we can't directly
do anything about.

Now, we will have woken kswapd, so something *will* hopefully be done
about them eventually, but at no time do we actually really wait for
it. We'll just busy-loop.

So at a minimum, I think we should yield to kswapd. We do do that
"cond_resched()" in wait_iff_congested(), but I'm not entirely
convinced that is at all enough to wait for kswapd to *do* something.

So before we really decide to see if we should oom, I think we should
have at least one  forced io_schedule_timeout(), whether we're
congested or not.

And yes, as Tetsuo Handa said, any kind of short wait might be too
short for IO to really complete, but *something* will have completed.
Unless we're so far up the creek that we really should just oom.

But I suspect we'll have to just try things out and tweak it. This
patch looks like a reasonable starting point to me.

Tetsuo, mind trying it out and maybe tweaking it a bit for the load
you have? Does it seem to improve on your situation?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
