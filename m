Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7368C6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 19:41:32 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so5946208pac.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:41:32 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id w13si35406133pas.205.2015.08.25.16.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 16:41:31 -0700 (PDT)
Received: by pabzx8 with SMTP id zx8so48486947pab.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:41:31 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:41:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
In-Reply-To: <20150825142503.GE6285@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1508251635560.10653@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com> <20150821081745.GG23723@dhcp22.suse.cz> <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com> <20150825142503.GE6285@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue, 25 Aug 2015, Michal Hocko wrote:

> > I don't believe a solution that requires admin intervention is 
> > maintainable.
> 
> Why?
> 

Because the company I work for has far too many machines for that to be 
possible.

> > It would be better to reboot when memory reserves are fully depleted.
> 
> The question is when are the reserves depleted without any way to
> replenish them. While playing with GFP_NOFS patch set which gives
> __GFP_NOFAIL allocations access to memory reserves
> (http://marc.info/?l=linux-mm&m=143876830916540&w=2) I could see the
> warning hit while the system still resurrected from the memory pressure.
> 

If there is a holder of a mutex that then allocates gigabytes of memory, 
no amount of memory reserves is going to assist in resolving an oom killer 
livelock, whether that's partial access to memory reserves or full access 
to memory reserves.

You're referring to two different conditions:

 (1) oom livelock as a result of an oom kill victim waiting on a lock that
     is held by an allocator, and

 (2) depletion of memory reserves, which can also happen today without 
     this patchset and we have fixed in the past.

This patch addresses (1) by giving it a higher probability, absent the 
ability to determine which thread is holding the lock that the victim 
depends on, to make forward progress.  It would be fine to do (2) as a 
separate patch, since it is a separate problem, that I agree has a higher 
likelihood of happening now to panic when memory reserves have been 
depleted.

> I think an OOM reserve/watermark makes more sense. It will not solve the
> livelock but neithere granting the full access to reserves will. But the
> partial access has a potential to leave some others means to intervene.
> 

Unless the oom watermark was higher than the lowest access to memory 
reserves other than ALLOC_NO_WATERMARKS, then no forward progress would be 
made in this scenario.  I think it would be better to give access to that 
crucial last page that may solve the livelock to make forward progress, or 
panic as a result of complete depletion of memory reserves.  That panic() 
is a very trivial patch that can be checked in the allocator slowpath and 
addresses a problem that already exists today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
