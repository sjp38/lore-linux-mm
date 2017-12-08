Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAA06B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 19:44:28 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so4995513wre.10
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 16:44:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l3sor3300997wrg.88.2017.12.07.16.44.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 16:44:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171207083436.GC20234@dhcp22.suse.cz>
References: <20171206192026.25133-1-surenb@google.com> <20171207083436.GC20234@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 7 Dec 2017 16:44:24 -0800
Message-ID: <CAJuCfpHV=O4Kq4jppeMu7A==N37VhmXvHYRYvERmxQVeEZ=jUQ@mail.gmail.com>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

On Thu, Dec 7, 2017 at 12:34 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 06-12-17 11:20:26, Suren Baghdasaryan wrote:
>> Slab shrinkers can be quite time consuming and when signal
>> is pending they can delay handling of the signal. If fatal
>> signal is pending there is no point in shrinking that process
>> since it will be killed anyway. This change checks for pending
>> fatal signals inside shrink_slab loop and if one is detected
>> terminates this loop early.
>
> This is not enough. You would have to make sure the direct reclaim will
> bail out immeditally which is not at all that simple. We do check fatal
> signals in throttle_direct_reclaim and conditionally in shrink_inactive_list
> so even if you bail out from shrinkers we could still finish the full
> reclaim cycle.
>
> Besides that shrinkers shouldn't really take very long so this looks
> like it papers over a real bug somewhere else. I am not saying the patch
> is wrong but it would deserve much more details to judge wether this is
> the right way to go for your particular problem.
>

I agree that this check alone is not going to terminate direct
reclaim, rather it's designed to prevent a long-running shrinkers from
delaying SIGKILL handling. I tried to reflect that in the description
of the patch but maybe I should rephrase that. Why I want to prevent
specifically shrinkers from running with pending SIGKILL is because
drivers can register their own shrinkers and one poorly-written driver
can affect signal delivery of the whole system. I realize this can be
viewed as an attempt to hide bugs in shrinkers but my intend was to
place some safeguard for the system, not a replacement for a proper
fix.

fatal_signal_pending checks in throttle_direct_reclaim are
interesting. I might be missing something and relevant description of
the code here https://lkml.org/lkml/2012/11/21/566 did not help me
much but I think the logic inside throttle_direct_reclaim would not
prevent direct reclaim if signal is already pending. Looks like it
prevents direct reclaim only if fatal signal is received between the
two fatal_signal_pending checks inside throttle_direct_reclaim. I'm
not saying the code is wrong and looks like it was designed with a
specific use case in mind, just saying that it's not going to prevent
direct reclaim from running if signal was pending before
throttle_direct_reclaim is called. And indeed I can see in my traces
several invocations of do_try_to_free_pages from try_to_free_pages
while SIGKILL is pending (the worst case so far was 5 invocations).

I also agree that shrinkers in general should not take long time to
run. After fixing couple of them that I mentioned in my reply to
Andrew here: https://lkml.org/lkml/2017/12/6/1095 I collected more
traces using patched shrinkers. The problem is less pronounced and
harder to reproduce. The worst case delay for SIGKILL handling I've
got so far is 43ms and this patch would shave about 7% of it.
According to my traces this 43ms could drop to the average of 11ms and
worst case 25ms if throttle_direct_reclaim would return true when
fatal signal is pending but I would like to hear your opinion about
throttle_direct_reclaim logic.

And thank you all for the comments and corrections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
