Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 45F906B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 04:17:49 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so9528645wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 01:17:48 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id kf4si2967990wic.48.2015.08.21.01.17.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 01:17:47 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so9528088wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 01:17:47 -0700 (PDT)
Date: Fri, 21 Aug 2015 10:17:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
Message-ID: <20150821081745.GG23723@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

[CCing Tetsuo - he was really concerned about the oom deadlocks and he
 was proposing a timeout based solution as well]

On Thu 20-08-15 14:00:36, David Rientjes wrote:
> On system oom, a process may fail to exit if its thread depends on a lock
> held by another allocating process.
> 
> In this case, we can detect an oom kill livelock that requires memory
> allocation to be successful to resolve.
> 
> This patch introduces an oom expiration, set to 5s, that defines how long
> a thread has to exit after being oom killed.
> 
> When this period elapses, it is assumed that the thread cannot make
> forward progress without help.  The only help the VM may provide is to
> allow pending allocations to succeed, so it grants all allocators access
> to memory reserves after reclaim and compaction have failed.

There might be many threads waiting for the allocation and this can lead
to quick oom reserves depletion without releasing resources which are
holding back the oom victim. As Tetsuo has shown, such a load can be
generated from the userspace without root privileges so it is much
easier to make the system _completely_ unusable with this patch. Not that
having an OOM deadlock would be great but you still have emergency tools
like sysrq triggered OOM killer to attempt to sort the situation out.
Once your are out of reserves nothing will help you, though. So I think it
is a bad idea to give access to reserves without any throttling.

Johannes' idea to give a partial access to memory reserves to the task
which has invoked the OOM killer was much better IMO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
