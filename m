Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBFF86B0011
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 13:47:19 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id p142so4671137itp.0
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 10:47:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c1sor1501936iti.107.2018.02.23.10.47.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 10:47:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180223175051.GX30681@dhcp22.suse.cz>
References: <20180205220325.197241-1-dancol@google.com> <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com>
 <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuev67HPpK5x4zS88x0C2AysvSk5wcFS0DuT3A_04p1HpSQ@mail.gmail.com>
 <20180223081147.GD30773@dhcp22.suse.cz> <CAKOZueurwrSZWbKKUTx+LOSKEWFnfMYbarDc++pEKHD3xyQbmA@mail.gmail.com>
 <20180223175051.GX30681@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 23 Feb 2018 10:47:16 -0800
Message-ID: <CAKOZueukEggFEL-UkvQeOirPQcamcyDZdcEV5V2z9AZ7QB_p2Q@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Fri, Feb 23, 2018 at 9:50 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 23-02-18 08:34:19, Daniel Colascione wrote:
>> On Fri, Feb 23, 2018 at 12:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Wed 21-02-18 18:49:35, Daniel Colascione wrote:
>> > [...]
>> >> For more context: on Android, we've historically scanned each
>> >> address space using /proc/pid/smaps (and /proc/pid/smaps_rollup more
>> >> recently) to extract memory management statistics. We're looking at
>> >> replacing this mechanism with the new /proc/pid/status per-memory-type
>> >> (e.g., anonymous, file-backed) counters so that we can be even more
>> >> efficient, but we'd like the counts we collect to be accurate.
>> >
>> > If you need the accuracy then why don't you simply make
>> > SPLIT_RSS_COUNTING configurable and disable it in your setup?
>>
>> I considered that option, but it feels like a last resort. I think
>> agreement between /proc/pid/status and /proc/pid/smaps is a
>> correctness issue, and I'd prefer to fix the correctness issue
>> globally.
>
> But those counters are inherently out-of-sync because the data may be
> outdated as soon as you get the data back to the userspace (except for
> the trivial single threaded /proc/self/ case).

It's one thing to be inconsistent for a moment because two cores and
doing things at the same time. It's another thing to be inconsistent
for a week. :-)

>
>> That said, *deleting* the SPLIT_RSS_COUNTING code would be nice and
>> simple. How sure are we that the per-task accounting is really needed?
>
> I have never measured that. 34e55232e59f ("mm: avoid false sharing of
> mm_counter") has _some_ numbers.
>
>> Maybe I'm wrong, but I feel like taking page faults will touch per-mm
>> data structures anyway, so one additional atomic update on the mm
>> shouldn't hurt all that much.
>
> I wouldn't be oppposed to remove it completely if it is not measureable.

Just deleting SPLIT_RSS_COUNTING is certainly my preferred option. I
didn't see any benchmarks accompanying the inclusion of the mechanism
in the first place. How would you suggest verifying that we can safely
delete it? I *think* it would have the greatest benefit on very large
systems with lots of tasks sharing and mm, each taking page faults
often, but I don't have any such large machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
