Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C5F136B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:29:03 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p63so75837398wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 08:29:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sa8si23060764wjb.178.2016.01.29.08.29.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 08:29:02 -0800 (PST)
Date: Fri, 29 Jan 2016 17:29:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: why do we do ALLOC_WMARK_HIGH before going out_of_memory
Message-ID: <20160129162901.GJ32174@dhcp22.suse.cz>
References: <20160128163802.GA15953@dhcp22.suse.cz>
 <20160128190204.GJ12228@redhat.com>
 <20160128201123.GB621@dhcp22.suse.cz>
 <20160128211240.GA4163@cmpxchg.org>
 <20160128215514.GF621@dhcp22.suse.cz>
 <20160128234018.GA5530@cmpxchg.org>
 <20160129143806.GC32174@dhcp22.suse.cz>
 <20160129155644.GK12228@redhat.com>
 <20160129161257.GI32174@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160129161257.GI32174@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 29-01-16 17:12:57, Michal Hocko wrote:
> On Fri 29-01-16 16:56:45, Andrea Arcangeli wrote:
> > On Fri, Jan 29, 2016 at 03:38:06PM +0100, Michal Hocko wrote:
> > > That would require the oom victim to release the memory and drop
> > > TIF_MEMDIE before we go out_of_memory again. And that might happen
> > > anytime whether we are holding oom_trylock or not because it doesn't
> > > synchronize the exit path. So we are basically talking about:
> > > 
> > > should_alloc_retry
> > > [1]
> > > get_page_from_freelist(ALLOC_WMARK_HIGH)
> > > [2]
> > > out_of_memory
> > > 
> > > and the race window for 1 is much smaller than 2 because [2] is quite
> > 
> > [1] is before should_alloc_retry is set. It covers the entire reclaim.
> > 
> > > costly operation. I wonder if this last moment request ever succeeds. I
> > > have run my usual oom flood tests and it hasn't shown up a single time.
> > 
> > For this check to make a difference, you need a lot of small programs
> > all hitting OOM at the same time.
> 
> That is essentially my oom flood testing program doing. Spawning
> hundreds of paralell anon mem eaters.
> 
> > Perhaps the trylock on the oom_lock
> > tends to hide the race like you suggested earlier but it doesn't sound
> > accurate if we proceed to oom kill without checking the high wmark at all
> > before killing another task after a random reclaim failure.
> 
> The thing is that the reclaim would have to reclaim consistently after
> the rework.

Ble. It should read: would have to fail to reclaim consistently or
have only very small chance to reclaim enough to fulfill to allocation
request (even if we reclaimed all the reclaimable memory combined with
the free memory). So the chances to succeed after should_alloc_retry are
quite small. The race is there of course and something might have just
freed a bulk of memory but my primary point is that [1] is way too small
to make a difference. It would if we slept on the lock of course but
that is not happening.

Anyway I have refrained from pursuing the patch to remove this last
minute check. It is definitely not harmful.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
