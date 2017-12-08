Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D86C6B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 13:06:30 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v69so6415333wrb.3
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 10:06:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v7sor604255wma.23.2017.12.08.10.06.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 10:06:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201712082303.DDG90166.FOLSHOOFVQJMtF@I-love.SAKURA.ne.jp>
References: <20171208012305.83134-1-surenb@google.com> <20171208082220.GQ20234@dhcp22.suse.cz>
 <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
 <20171208114806.GU20234@dhcp22.suse.cz> <201712082303.DDG90166.FOLSHOOFVQJMtF@I-love.SAKURA.ne.jp>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 8 Dec 2017 10:06:26 -0800
Message-ID: <CAJuCfpHmdcA=t9p8kjJYrgkrreQZt9Sa1=_up+1yV9BE4xJ-8g@mail.gmail.com>
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

On Fri, Dec 8, 2017 at 6:03 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Michal Hocko wrote:
>> On Fri 08-12-17 20:36:16, Tetsuo Handa wrote:
>> > On 2017/12/08 17:22, Michal Hocko wrote:
>> > > On Thu 07-12-17 17:23:05, Suren Baghdasaryan wrote:
>> > >> Slab shrinkers can be quite time consuming and when signal
>> > >> is pending they can delay handling of the signal. If fatal
>> > >> signal is pending there is no point in shrinking that process
>> > >> since it will be killed anyway.
>> > >
>> > > The thing is that we are _not_ shrinking _that_ process. We are
>> > > shrinking globally shared objects and the fact that the memory pressure
>> > > is so large that the kswapd doesn't keep pace with it means that we have
>> > > to throttle all allocation sites by doing this direct reclaim. I agree
>> > > that expediting killed task is a good thing in general because such a
>> > > process should free at least some memory.

Agree, wording here is inaccurate. My original intent was to have a
safeguard against slow shrinkers but I understand your concern that
this can mask a real problem in a shrinker. In essence expediting the
killing is the ultimate goal here but as you mentioned it's not as
simple as this change.

>> >
>> > But doesn't doing direct reclaim mean that allocation request of already
>> > fatal_signal_pending() threads will not succeed unless some memory is
>> > reclaimed (or selected as an OOM victim)? Won't it just spin the "too
>> > small to fail" retry loop at full speed in the worst case?

That seems to be the case in my test. If we could bail out safely from
the retry loop in __alloc_pages_slowpath that would be a big win in
expediting the signal.

>>
>> Well, normally kswapd would do the work on the background. But this
>> would have to be carefully evaluated. That is why I've said "expedite"
>> rather than skip.
>
> Relying on kswapd is a bad assumption, for kswapd can be blocked on e.g. fs
> locks waiting for somebody else to reclaim memory.
>
>>
>> > >> This change checks for pending
>> > >> fatal signals inside shrink_slab loop and if one is detected
>> > >> terminates this loop early.
>> > >
>> > > This changelog doesn't really address my previous review feedback, I am
>> > > afraid. You should mention more details about problems you are seeing
>> > > and what causes them.

The problem I'm facing is that a SIGKILL sent from user space to kill
the least important process is delayed enough for OOM-killer to get a
chance to kill something else, possibly a more important process. Here
"important" is from user's point of view. So the delay in SIGKILL
delivery effectively causes extra kills. Traces indicate that this
delay happens when process being killed is in direct reclaim and
shrinkers (before I fixed them) were the biggest cause for the delay.

>> > > If we have a shrinker which takes considerable
>> > > amount of time them we should be addressing that. If that is not
>> > > possible then it should be documented at least.

I already submitted patches for couple shrinkers. Problem became less
pronounced and less frequent but the retry loop Tetsuo mentioned still
visibly delays the delivery. The worst case I've seen after fixing
shrinkers is 43ms.

>> >
>> > Unfortunately, it is possible to be get blocked inside shrink_slab() for so long
>> > like an example from http://lkml.kernel.org/r/1512705038.7843.6.camel@gmail.com .
>>
>> As I've said any excessive shrinker should definitely be evaluated.
>
> The cause of stall inside shrink_slab() can be memory pressure itself.
> There would be no problem if kswapd is sufficient (i.e. direct reclaim is
> not needed). But there are many problems if direct reclaim is needed.
>
>
>
> I agree that making waits/loops killable is generally good. But be sure to be
> prepared for the worst case. For example, start __GFP_KILLABLE from "best effort"
> basis (i.e. no guarantee that the allocating thread will leave the page allocator
> slowpath immediately) and check for fatal_signal_pending() only if
> __GFP_KILLABLE is set. That is,
>
> +               /*
> +                * We are about to die and free our memory.
> +                * Stop shrinking which might delay signal handling.
> +                */
> +               if (unlikely((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current)))
> +                       break;
>
> at shrink_slab() etc. and
>
> +               if ((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current))
> +                       goto nopage;
>
> at __alloc_pages_slowpath().

I was thinking about something similar and will experiment to see if
this solves the problem and if it has any side effects. Anyone sees
any obvious problems with this approach?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
