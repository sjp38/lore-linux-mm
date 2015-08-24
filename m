Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 35F0D6B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 17:04:31 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so32178674pac.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:04:31 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id h8si29401479pdr.96.2015.08.24.14.04.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 14:04:30 -0700 (PDT)
Received: by pdrh1 with SMTP id h1so58639898pdr.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:04:30 -0700 (PDT)
Date: Mon, 24 Aug 2015 14:04:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
In-Reply-To: <20150821081745.GG23723@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com> <20150821081745.GG23723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Fri, 21 Aug 2015, Michal Hocko wrote:

> There might be many threads waiting for the allocation and this can lead
> to quick oom reserves depletion without releasing resources which are
> holding back the oom victim. As Tetsuo has shown, such a load can be
> generated from the userspace without root privileges so it is much
> easier to make the system _completely_ unusable with this patch. Not that
> having an OOM deadlock would be great but you still have emergency tools
> like sysrq triggered OOM killer to attempt to sort the situation out.
> Once your are out of reserves nothing will help you, though. So I think it
> is a bad idea to give access to reserves without any throttling.
> 

I don't believe a solution that requires admin intervention is 
maintainable.  It would be better to reboot when memory reserves are fully 
depleted.

> Johannes' idea to give a partial access to memory reserves to the task
> which has invoked the OOM killer was much better IMO.

That's what this patch does, just without the "partial."  Processes are 
required to reclaim and then invoke the oom killler every time an 
allocation is made using memory reserves with this approach after the 
expiration has lapsed.

We can discuss only allowing partial access to memory reserves equal to 
ALLOC_HARD | ALLOC_HARDER, or defining a new watermark, but I'm concerned 
about what happens when that threshold is reached and the oom killer is 
still livelocked.  It would seem better to attempt recovery at whatever 
cost and then panic if fully depleted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
