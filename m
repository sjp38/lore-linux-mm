Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 673E96B0010
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 05:02:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u65so9971863pfd.7
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 02:02:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si6782873pgo.342.2018.02.27.02.02.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 02:02:36 -0800 (PST)
Date: Tue, 27 Feb 2018 11:02:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Message-ID: <20180227100234.GF15357@dhcp22.suse.cz>
References: <20180205220325.197241-1-dancol@google.com>
 <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com>
 <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuev67HPpK5x4zS88x0C2AysvSk5wcFS0DuT3A_04p1HpSQ@mail.gmail.com>
 <20180223081147.GD30773@dhcp22.suse.cz>
 <CAKOZueurwrSZWbKKUTx+LOSKEWFnfMYbarDc++pEKHD3xyQbmA@mail.gmail.com>
 <20180223175051.GX30681@dhcp22.suse.cz>
 <CAKOZueukEggFEL-UkvQeOirPQcamcyDZdcEV5V2z9AZ7QB_p2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZueukEggFEL-UkvQeOirPQcamcyDZdcEV5V2z9AZ7QB_p2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

[CC Kamezawa]

On Fri 23-02-18 10:47:16, Daniel Colascione wrote:
> On Fri, Feb 23, 2018 at 9:50 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 23-02-18 08:34:19, Daniel Colascione wrote:
[...]
> >> Maybe I'm wrong, but I feel like taking page faults will touch per-mm
> >> data structures anyway, so one additional atomic update on the mm
> >> shouldn't hurt all that much.
> >
> > I wouldn't be oppposed to remove it completely if it is not measureable.
> 
> Just deleting SPLIT_RSS_COUNTING is certainly my preferred option. I
> didn't see any benchmarks accompanying the inclusion of the mechanism
> in the first place.

You are right that 34e55232e59f ("mm: avoid false sharing of
mm_counter") was rather poor on the testing and convincing numbers. It
is not really clear where
     [before]
         4.5 cache-miss/faults
     [after]
         4.0 cache-miss/faults
come from.

> How would you suggest verifying that we can safely
> delete it?

Heavy parallel page fault test but you would have to be careful to not
measure the page allocator overhead.

> I *think* it would have the greatest benefit on very large
> systems with lots of tasks sharing and mm, each taking page faults
> often, but I don't have any such large machines.

The more I think about it the more I am convinced that we should simply
disable SPLIT_RSS_COUNTING by default or even remove the code
altogether. 

Kamezawa, did you or anybody else have any specific workload which
benefited from this change or it was merely "this sounds like a good
optimization" thingy?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
