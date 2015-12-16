Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCBE6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 18:58:46 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ur14so31520362pab.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 15:58:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l85si8175494pfi.176.2015.12.16.15.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 15:58:45 -0800 (PST)
Date: Wed, 16 Dec 2015 15:58:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-Id: <20151216155844.d1c3a5f35bc98072a80f939e@linux-foundation.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 15 Dec 2015 19:19:43 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> 
> ...
>
> * base kernel
> $ grep "Killed process" base-oom-run1.log | tail -n1
> [  211.824379] Killed process 3086 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:332kB, shmem-rss:0kB
> $ grep "Killed process" base-oom-run2.log | tail -n1
> [  157.188326] Killed process 3094 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:368kB, shmem-rss:0kB
> 
> $ grep "invoked oom-killer" base-oom-run1.log | wc -l
> 78
> $ grep "invoked oom-killer" base-oom-run2.log | wc -l
> 76
> 
> The number of OOM invocations is consistent with my last measurements
> but the runtime is way too different (it took 800+s).

I'm seeing 211 seconds vs 157 seconds?  If so, that's not toooo bad.  I
assume the 800+s is sum-across-multiple-CPUs?  Given that all the CPUs
are pounding away at the same data and the same disk, that doesn't
sound like very interesting info - the overall elapsed time is the
thing to look at in this case.

> One thing that
> could have skewed results was that I was tail -f the serial log on the
> host system to see the progress. I have stopped doing that. The results
> are more consistent now but still too different from the last time.
> This is really weird so I've retested with the last 4.2 mmotm again and
> I am getting consistent ~220s which is really close to the above. If I
> apply the WQ vmstat patch on top I am getting close to 160s so the stale
> vmstat counters made a difference which is to be expected. I have a new
> SSD in my laptop which migh have made a difference but I wouldn't expect
> it to be that large.
> 
> $ grep "DMA32.*all_unreclaimable? no" base-oom-run1.log | wc -l
> 4
> $ grep "DMA32.*all_unreclaimable? no" base-oom-run2.log | wc -l
> 1
> 
> * patched kernel
> $ grep "Killed process" patched-oom-run1.log | tail -n1
> [  341.164930] Killed process 3099 (mem_eater) total-vm:85852kB, anon-rss:82000kB, file-rss:336kB, shmem-rss:0kB
> $ grep "Killed process" patched-oom-run2.log | tail -n1
> [  349.111539] Killed process 3082 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:4kB, shmem-rss:0kB

Even better.

> $ grep "invoked oom-killer" patched-oom-run1.log | wc -l
> 78
> $ grep "invoked oom-killer" patched-oom-run2.log | wc -l
> 77
> 
> $ grep "DMA32.*all_unreclaimable? no" patched-oom-run1.log | wc -l
> 1
> $ grep "DMA32.*all_unreclaimable? no" patched-oom-run2.log | wc -l
> 0
> 
> So the number of OOM killer invocation is the same but the overall
> runtime of the test was much longer with the patched kernel. This can be
> attributed to more retries in general. The results from the base kernel
> are quite inconsitent and I think that consistency is better here.

It's hard to say how long declaration of oom should take.  Correctness
comes first.  But what is "correct"?  oom isn't a binary condition -
there's a chance that if we keep churning away for another 5 minutes
we'll be able to satisfy this allocation (but probably not the next
one).  There are tradeoffs between promptness-of-declaring-oom and
exhaustiveness-in-avoiding-it.

> 
> 2) 2 writers again with 10s of run and then 10 mem_eaters to consume as much
>    memory as possible without triggering the OOM killer. This required a lot
>    of tuning but I've considered 3 consecutive runs without OOM as a success.

"a lot of tuning" sounds bad.  It means that the tuning settings you
have now for a particular workload on a particular machine will be
wrong for other workloads and machines.  uh-oh.

> ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
