Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD4A6B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 11:34:22 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id p11so2720685itc.5
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 08:34:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v8sor759046itv.115.2018.02.23.08.34.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 08:34:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180223081147.GD30773@dhcp22.suse.cz>
References: <20180205220325.197241-1-dancol@google.com> <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com>
 <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuev67HPpK5x4zS88x0C2AysvSk5wcFS0DuT3A_04p1HpSQ@mail.gmail.com> <20180223081147.GD30773@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 23 Feb 2018 08:34:19 -0800
Message-ID: <CAKOZueurwrSZWbKKUTx+LOSKEWFnfMYbarDc++pEKHD3xyQbmA@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Fri, Feb 23, 2018 at 12:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 21-02-18 18:49:35, Daniel Colascione wrote:
> [...]
>> For more context: on Android, we've historically scanned each processes's
>> address space using /proc/pid/smaps (and /proc/pid/smaps_rollup more
>> recently) to extract memory management statistics. We're looking at
>> replacing this mechanism with the new /proc/pid/status per-memory-type
>> (e.g., anonymous, file-backed) counters so that we can be even more
>> efficient, but we'd like the counts we collect to be accurate.
>
> If you need the accuracy then why don't you simply make
> SPLIT_RSS_COUNTING configurable and disable it in your setup?

I considered that option, but it feels like a last resort. I think
agreement between /proc/pid/status and /proc/pid/smaps is a
correctness issue, and I'd prefer to fix the correctness issue
globally.

That said, *deleting* the SPLIT_RSS_COUNTING code would be nice and
simple. How sure are we that the per-task accounting is really needed?
Maybe I'm wrong, but I feel like taking page faults will touch per-mm
data structures anyway, so one additional atomic update on the mm
shouldn't hurt all that much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
