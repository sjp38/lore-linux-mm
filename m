Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 950966B0007
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 07:11:15 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p187so61813654wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:11:15 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id y125si1538212wmd.48.2015.12.18.04.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 04:11:14 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id l126so62968692wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:11:14 -0800 (PST)
Date: Fri, 18 Dec 2015 13:11:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151218121112.GF28443@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
 <20151217130223.GE18625@dhcp22.suse.cz>
 <20151217131356.83d920b7c250a785aa132139@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151217131356.83d920b7c250a785aa132139@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 17-12-15 13:13:56, Andrew Morton wrote:
[...]
> Also, re-reading your description:
> 
> : It has been shown (e.g.  by Tetsuo Handa) that it is not that hard to
> : construct workloads which break the core assumption mentioned above and
> : the OOM victim might take unbounded amount of time to exit because it
> : might be blocked in the uninterruptible state waiting for on an event
> : (e.g.  lock) which is blocked by another task looping in the page
> : allocator.
> 
> So the allocating task has done an oom-kill and is waiting for memory
> to become available.  The killed task is stuck on some lock, unable to
> free memory.
> 
> But the problematic lock will sometimes be the killed tasks's mmap_sem,
> so the reaper won't reap anything.  This scenario requires that the
> mmap_sem is held for writing, which sounds like it will be uncommon. 

Yes, I have mentioned that in the changelog:
"
oom_reaper has to take mmap_sem on the target task for reading so the
solution is not 100% because the semaphore might be held or blocked for
write but the probability is reduced considerably wrt. basically any
lock blocking forward progress as described above.
"

Another thing is to do is to change down_write(mmap_sem) to
down_write_killable in most cases where we have a clear ENITR semantic.
This is on my todo list.

> hm.  sigh.  I hate the oom-killer.  Just buy some more memory already!

Tell me something about that...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
