Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id E914A6B0085
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:59:14 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so110127464wic.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:59:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si18434060wix.18.2015.04.28.07.59.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:59:13 -0700 (PDT)
Date: Tue, 28 Apr 2015 16:59:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 9/9] mm: page_alloc: memory reserve access for
 OOM-killing allocations
Message-ID: <20150428145911.GG2659@dhcp22.suse.cz>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
 <1430161555-6058-10-git-send-email-hannes@cmpxchg.org>
 <20150428133009.GD2659@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150428133009.GD2659@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 28-04-15 15:30:09, Michal Hocko wrote:
> On Mon 27-04-15 15:05:55, Johannes Weiner wrote:
> > The OOM killer connects random tasks in the system with unknown
> > dependencies between them, and the OOM victim might well get blocked
> > behind locks held by the allocating task.  That means that while
> > allocations can issue OOM kills to improve the low memory situation,
> > which generally frees more than they are going to take out, they can
> > not rely on their *own* OOM kills to make forward progress.
> > 
> > However, OOM-killing allocations currently retry forever.  Without any
> > extra measures the above situation will result in a deadlock; between
> > the allocating task and the OOM victim at first, but it can spread
> > once other tasks in the system start contending for the same locks.
> > 
> > Allow OOM-killing allocations to dip into the system's memory reserves
> > to avoid this deadlock scenario.  Those reserves are specifically for
> > operations in the memory reclaim paths which need a small amount of
> > memory to release a much larger amount.  Arguably, the same notion
> > applies to the OOM killer.
> 
> This will not work without some throttling.

Hmm, thinking about it some more it seems that the throttling on
out_of_memory and its wait_event_timeout might be sufficient to not
allow too many tasks consume reserves. If this doesn't help to make any
progress then we are screwed anyway. Maybe we should simply panic if
the last get_page_from_freelist with ALLOC_NO_WATERMARKS fails...

I will think about this some more but it is certainly easier than
a new wmark and that one can be added later should there be a need.

> You will basically give a
> free ticket to all memory reserves to basically all allocating tasks
> (which are allowed to trigger OOM and there might be hundreds of them)
> and that itself might prevent the OOM victim from exiting.
> 
> Your previous OOM wmark was nicer because it naturally throttled
> allocations and still left some room for the exiting task.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
