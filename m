Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B05E6B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 16:05:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 11so10813703wrb.18
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 13:05:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c6sor2221732wmd.75.2017.12.11.13.05.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 13:05:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201712091708.GHG60458.MHFOVSFOQtOFLJ@I-love.SAKURA.ne.jp>
References: <20171208082220.GQ20234@dhcp22.suse.cz> <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
 <20171208114806.GU20234@dhcp22.suse.cz> <201712082303.DDG90166.FOLSHOOFVQJMtF@I-love.SAKURA.ne.jp>
 <CAJuCfpHmdcA=t9p8kjJYrgkrreQZt9Sa1=_up+1yV9BE4xJ-8g@mail.gmail.com> <201712091708.GHG60458.MHFOVSFOQtOFLJ@I-love.SAKURA.ne.jp>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 11 Dec 2017 13:05:50 -0800
Message-ID: <CAJuCfpE854v=3k4+cK34M5vfg-S25OqSideMSofLOFe4d177Vw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

On Sat, Dec 9, 2017 at 12:08 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Suren Baghdasaryan wrote:
>> On Fri, Dec 8, 2017 at 6:03 AM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> >> > >> This change checks for pending
>> >> > >> fatal signals inside shrink_slab loop and if one is detected
>> >> > >> terminates this loop early.
>> >> > >
>> >> > > This changelog doesn't really address my previous review feedback, I am
>> >> > > afraid. You should mention more details about problems you are seeing
>> >> > > and what causes them.
>>
>> The problem I'm facing is that a SIGKILL sent from user space to kill
>> the least important process is delayed enough for OOM-killer to get a
>> chance to kill something else, possibly a more important process. Here
>> "important" is from user's point of view. So the delay in SIGKILL
>> delivery effectively causes extra kills. Traces indicate that this
>> delay happens when process being killed is in direct reclaim and
>> shrinkers (before I fixed them) were the biggest cause for the delay.
>
> Sending SIGKILL from userspace is not releasing memory fast enough to prevent
> the OOM killer from invoking? Yes, under memory pressure, even an attempt to
> send SIGKILL from userspace could be delayed due to e.g. page fault.
>

I understand that there will be cases when OOM is unavoidable. I'm
trying to minimize the cases when SIGKILL processing is delayed.

> Unless it is memcg OOM, you could try OOM notifier callback for checking
> whether there are SIGKILL pending processes and wait for timeout if any.
> This situation resembles timeout-based OOM killing discussion, where the OOM
> killer is enabled again (based on an assumption that the OOM victim got stuck
> due to OOM lockup) after some timeout from previous OOM-killing. And since
> we did not merge timeout-based approach, there is no timestamp field for
> remembering when the SIGKILL was delivered. Therefore, an attempt to wait for
> timeout would become messy.
>
> Regardless of whether you try OOM notifier callback, I think that adding
> __GFP_KILLABLE and allow bailing out without calling out_of_memory() and
> warn_alloc() will help terminating killed processes faster. I think that
> majority of memory allocation requests can give up upon SIGKILL. Important
> allocation requests which should not give up upon SIGKILL (e.g. committing
> to filesystem metadata and storage) can be offloaded to kernel threads.
>
>>
>> >> > > If we have a shrinker which takes considerable
>> >> > > amount of time them we should be addressing that. If that is not
>> >> > > possible then it should be documented at least.
>>
>> I already submitted patches for couple shrinkers. Problem became less
>> pronounced and less frequent but the retry loop Tetsuo mentioned still
>> visibly delays the delivery. The worst case I've seen after fixing
>> shrinkers is 43ms.
>
> You meant "delays the termination (of the killed process)" rather than
> "delays the delivery (of SIGKILL)", didn't you?
>

To be more precise, I'm talking about the delay between send_signal()
and get_signal() or in other words the delay between the moment when
we send the SIGKILL and the moment we handle it.

>> > I agree that making waits/loops killable is generally good. But be sure to be
>> > prepared for the worst case. For example, start __GFP_KILLABLE from "best effort"
>> > basis (i.e. no guarantee that the allocating thread will leave the page allocator
>> > slowpath immediately) and check for fatal_signal_pending() only if
>> > __GFP_KILLABLE is set. That is,
>> >
>> > +               /*
>> > +                * We are about to die and free our memory.
>> > +                * Stop shrinking which might delay signal handling.
>> > +                */
>> > +               if (unlikely((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current)))
>> > +                       break;
>> >
>> > at shrink_slab() etc. and
>> >
>> > +               if ((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current))
>> > +                       goto nopage;
>> >
>> > at __alloc_pages_slowpath().
>>
>> I was thinking about something similar and will experiment to see if
>> this solves the problem and if it has any side effects. Anyone sees
>> any obvious problems with this approach?
>>
>
> It is Michal who thinks that "killability for a particular allocation request sounds
> like a hack" ( http://lkml.kernel.org/r/201606112335.HBG09891.OLFJOFtVMOQHSF@I-love.SAKURA.ne.jp ).
> I'm willing to give up memory allocations from functions which are called by
> system calls if SIGKILL is pending. Thus, it should be time to try __GFP_KILLABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
