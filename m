Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E6E436B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:25:08 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so16725288wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:25:08 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id xy9si39147863wjc.44.2015.08.25.07.25.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 07:25:07 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so16745151wid.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:25:06 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:25:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
Message-ID: <20150825142503.GE6285@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
 <20150821081745.GG23723@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Mon 24-08-15 14:04:28, David Rientjes wrote:
> On Fri, 21 Aug 2015, Michal Hocko wrote:
> 
> > There might be many threads waiting for the allocation and this can lead
> > to quick oom reserves depletion without releasing resources which are
> > holding back the oom victim. As Tetsuo has shown, such a load can be
> > generated from the userspace without root privileges so it is much
> > easier to make the system _completely_ unusable with this patch. Not that
> > having an OOM deadlock would be great but you still have emergency tools
> > like sysrq triggered OOM killer to attempt to sort the situation out.
> > Once your are out of reserves nothing will help you, though. So I think it
> > is a bad idea to give access to reserves without any throttling.
> > 
> 
> I don't believe a solution that requires admin intervention is 
> maintainable.

Why?

> It would be better to reboot when memory reserves are fully depleted.

The question is when are the reserves depleted without any way to
replenish them. While playing with GFP_NOFS patch set which gives
__GFP_NOFAIL allocations access to memory reserves
(http://marc.info/?l=linux-mm&m=143876830916540&w=2) I could see the
warning hit while the system still resurrected from the memory pressure.

> > Johannes' idea to give a partial access to memory reserves to the task
> > which has invoked the OOM killer was much better IMO.
> 
> That's what this patch does, just without the "partial."  Processes are 
> required to reclaim and then invoke the oom killler every time an 
> allocation is made using memory reserves with this approach after the 
> expiration has lapsed.
> 
> We can discuss only allowing partial access to memory reserves equal to 
> ALLOC_HARD | ALLOC_HARDER, or defining a new watermark, but I'm concerned 
> about what happens when that threshold is reached and the oom killer is 
> still livelocked.  It would seem better to attempt recovery at whatever 
> cost and then panic if fully depleted.

I think an OOM reserve/watermark makes more sense. It will not solve the
livelock but neithere granting the full access to reserves will. But the
partial access has a potential to leave some others means to intervene.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
