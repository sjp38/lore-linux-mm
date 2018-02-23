Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA81A6B0006
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 12:50:54 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id i129so8238518ioi.1
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 09:50:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v23si2241515wmv.0.2018.02.23.09.50.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Feb 2018 09:50:53 -0800 (PST)
Date: Fri, 23 Feb 2018 18:50:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Message-ID: <20180223175051.GX30681@dhcp22.suse.cz>
References: <20180205220325.197241-1-dancol@google.com>
 <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com>
 <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuev67HPpK5x4zS88x0C2AysvSk5wcFS0DuT3A_04p1HpSQ@mail.gmail.com>
 <20180223081147.GD30773@dhcp22.suse.cz>
 <CAKOZueurwrSZWbKKUTx+LOSKEWFnfMYbarDc++pEKHD3xyQbmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZueurwrSZWbKKUTx+LOSKEWFnfMYbarDc++pEKHD3xyQbmA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Fri 23-02-18 08:34:19, Daniel Colascione wrote:
> On Fri, Feb 23, 2018 at 12:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 21-02-18 18:49:35, Daniel Colascione wrote:
> > [...]
> >> For more context: on Android, we've historically scanned each processes's
> >> address space using /proc/pid/smaps (and /proc/pid/smaps_rollup more
> >> recently) to extract memory management statistics. We're looking at
> >> replacing this mechanism with the new /proc/pid/status per-memory-type
> >> (e.g., anonymous, file-backed) counters so that we can be even more
> >> efficient, but we'd like the counts we collect to be accurate.
> >
> > If you need the accuracy then why don't you simply make
> > SPLIT_RSS_COUNTING configurable and disable it in your setup?
> 
> I considered that option, but it feels like a last resort. I think
> agreement between /proc/pid/status and /proc/pid/smaps is a
> correctness issue, and I'd prefer to fix the correctness issue
> globally.

But those counters are inherently out-of-sync because the data may be
outdated as soon as you get the data back to the userspace (except for
the trivial single threaded /proc/self/ case).

> That said, *deleting* the SPLIT_RSS_COUNTING code would be nice and
> simple. How sure are we that the per-task accounting is really needed?

I have never measured that. 34e55232e59f ("mm: avoid false sharing of
mm_counter") has _some_ numbers.

> Maybe I'm wrong, but I feel like taking page faults will touch per-mm
> data structures anyway, so one additional atomic update on the mm
> shouldn't hurt all that much.

I wouldn't be oppposed to remove it completely if it is not measureable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
