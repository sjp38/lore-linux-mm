Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id D66D26B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:43:37 -0400 (EDT)
Received: by iget9 with SMTP id t9so97383911ige.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:43:37 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id hz3si19919476icc.74.2015.04.28.15.43.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:43:37 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so33670702igb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:43:37 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:43:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/9] mm: oom_kill: simplify OOM killer locking
In-Reply-To: <1430161555-6058-7-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1504281540280.10203@chino.kir.corp.google.com>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org> <1430161555-6058-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 27 Apr 2015, Johannes Weiner wrote:

> The zonelist locking and the oom_sem are two overlapping locks that
> are used to serialize global OOM killing against different things.
> 
> The historical zonelist locking serializes OOM kills from allocations
> with overlapping zonelists against each other to prevent killing more
> tasks than necessary in the same memory domain.  Only when neither
> tasklists nor zonelists from two concurrent OOM kills overlap (tasks
> in separate memcgs bound to separate nodes) are OOM kills allowed to
> execute in parallel.
> 
> The younger oom_sem is a read-write lock to serialize OOM killing
> against the PM code trying to disable the OOM killer altogether.
> 
> However, the OOM killer is a fairly cold error path, there is really
> no reason to optimize for highly performant and concurrent OOM kills.
> And the oom_sem is just flat-out redundant.
> 
> Replace both locking schemes with a single global mutex serializing
> OOM kills regardless of context.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for doing this, it cleans up the code quite a bit and I think 
there's the added benefit of not interleaving oom killer messages in the 
kernel log, and that's important since it's the only way we can currently 
discover that the kernel has killed something.

It's not vital and somewhat unrelated to your patch, but if we can't grab 
the mutex with the trylock in __alloc_pages_may_oom() then I think it 
would be more correct to do schedule_timeout_killable() rather than 
uninterruptible.  I just mention it if you happen to go through another 
revision of the series and want to switch it at the same time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
