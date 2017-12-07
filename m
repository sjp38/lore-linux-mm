Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEFFF6B0260
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:46:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y15so4274928wrc.6
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:46:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor2927722wrs.78.2017.12.07.07.46.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 07:46:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171207095835.GE20234@dhcp22.suse.cz>
References: <20171206192026.25133-1-surenb@google.com> <20171207095223.GB574@jagdpanzerIV>
 <20171207095835.GE20234@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 7 Dec 2017 07:46:07 -0800
Message-ID: <CAJuCfpEqReQBLXWX9mG9fm9wgMr_4WMHfxHe8GgG-1+sYuPkXA@mail.gmail.com>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

I'm, terribly sorry. My original code was checking for additional
condition which I realized is not useful here because it would mean
the signal was already processed. Should have missed the error while
removing it. Will address Michal's comments and fix the problem.

On Thu, Dec 7, 2017 at 1:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 07-12-17 18:52:23, Sergey Senozhatsky wrote:
>> On (12/06/17 11:20), Suren Baghdasaryan wrote:
>> > Slab shrinkers can be quite time consuming and when signal
>> > is pending they can delay handling of the signal. If fatal
>> > signal is pending there is no point in shrinking that process
>> > since it will be killed anyway. This change checks for pending
>> > fatal signals inside shrink_slab loop and if one is detected
>> > terminates this loop early.
>> >
>> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
>> > ---
>> >  mm/vmscan.c | 7 +++++++
>> >  1 file changed, 7 insertions(+)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index c02c850ea349..69296528ff33 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -486,6 +486,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>> >                     .memcg = memcg,
>> >             };
>> >
>> > +           /*
>> > +            * We are about to die and free our memory.
>> > +            * Stop shrinking which might delay signal handling.
>> > +            */
>> > +           if (unlikely(fatal_signal_pending(current))
>>
>> -               if (unlikely(fatal_signal_pending(current))
>> +               if (unlikely(fatal_signal_pending(current)))
>
> Heh, well, spotted. This begs a question how this has been tested, if at
> all?
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
