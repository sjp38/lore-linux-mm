Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id F21CE6B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 08:15:12 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l126so65164359wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 05:15:12 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id c64si12083589wmi.55.2015.12.18.05.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 05:15:11 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id p187so63128171wmp.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 05:15:11 -0800 (PST)
Date: Fri, 18 Dec 2015 14:15:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20151218131509.GH28443@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20151216155844.d1c3a5f35bc98072a80f939e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151216155844.d1c3a5f35bc98072a80f939e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 16-12-15 15:58:44, Andrew Morton wrote:
> On Tue, 15 Dec 2015 19:19:43 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > 
> > ...
> >
> > * base kernel
> > $ grep "Killed process" base-oom-run1.log | tail -n1
> > [  211.824379] Killed process 3086 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:332kB, shmem-rss:0kB
> > $ grep "Killed process" base-oom-run2.log | tail -n1
> > [  157.188326] Killed process 3094 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:368kB, shmem-rss:0kB
> > 
> > $ grep "invoked oom-killer" base-oom-run1.log | wc -l
> > 78
> > $ grep "invoked oom-killer" base-oom-run2.log | wc -l
> > 76
> > 
> > The number of OOM invocations is consistent with my last measurements
> > but the runtime is way too different (it took 800+s).
> 
> I'm seeing 211 seconds vs 157 seconds?  If so, that's not toooo bad.  I
> assume the 800+s is sum-across-multiple-CPUs?

This is the time until the oom situation settled down. And I really
suspect that the new SSD made a difference here.

> Given that all the CPUs
> are pounding away at the same data and the same disk, that doesn't
> sound like very interesting info - the overall elapsed time is the
> thing to look at in this case.

Which is what I was looking at when checking the timestamp in the log.

[...]
> > * patched kernel
> > $ grep "Killed process" patched-oom-run1.log | tail -n1
> > [  341.164930] Killed process 3099 (mem_eater) total-vm:85852kB, anon-rss:82000kB, file-rss:336kB, shmem-rss:0kB
> > $ grep "Killed process" patched-oom-run2.log | tail -n1
> > [  349.111539] Killed process 3082 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:4kB, shmem-rss:0kB
> 
> Even better.
> 
> > $ grep "invoked oom-killer" patched-oom-run1.log | wc -l
> > 78
> > $ grep "invoked oom-killer" patched-oom-run2.log | wc -l
> > 77
> > 
> > $ grep "DMA32.*all_unreclaimable? no" patched-oom-run1.log | wc -l
> > 1
> > $ grep "DMA32.*all_unreclaimable? no" patched-oom-run2.log | wc -l
> > 0
> > 
> > So the number of OOM killer invocation is the same but the overall
> > runtime of the test was much longer with the patched kernel. This can be
> > attributed to more retries in general. The results from the base kernel
> > are quite inconsitent and I think that consistency is better here.
> 
> It's hard to say how long declaration of oom should take.  Correctness
> comes first.  But what is "correct"?  oom isn't a binary condition -
> there's a chance that if we keep churning away for another 5 minutes
> we'll be able to satisfy this allocation (but probably not the next
> one).  There are tradeoffs between promptness-of-declaring-oom and
> exhaustiveness-in-avoiding-it.

Yes, this is really hard to tell. What I wanted to achieve here is a
determinism - the same load should give comparable results. It seems
that there is an improvement in this regards. The time to settle is 
much more consistent than with the original implementation.
 
> > 2) 2 writers again with 10s of run and then 10 mem_eaters to consume as much
> >    memory as possible without triggering the OOM killer. This required a lot
> >    of tuning but I've considered 3 consecutive runs without OOM as a success.
> 
> "a lot of tuning" sounds bad.  It means that the tuning settings you
> have now for a particular workload on a particular machine will be
> wrong for other workloads and machines.  uh-oh.

Well, I had to tune the test to see how close to the edge I can get. I
haven't done any decisions based on this test.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
