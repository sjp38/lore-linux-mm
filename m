Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id B42B7828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 11:28:53 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id bc4so209959458lbc.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 08:28:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id sq3si14069121lbb.118.2016.01.07.08.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 08:28:52 -0800 (PST)
Date: Thu, 7 Jan 2016 11:28:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160107162815.GA31729@cmpxchg.org>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 29, 2015 at 10:58:22PM +0900, Tetsuo Handa wrote:
> >From 8bb9e36891a803e82c589ef78077838026ce0f7d Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 29 Dec 2015 22:20:58 +0900
> Subject: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
> 
> The OOM reaper kernel thread can reclaim OOM victim's memory before the victim
> terminates. But since oom_kill_process() tries to kill children of the memory
> hog process first, the OOM reaper can not reclaim enough memory for terminating
> the victim if the victim is consuming little memory. The result is OOM livelock
> as usual, for timeout based next OOM victim selection is not implemented.

What we should be doing is have the OOM reaper clear TIF_MEMDIE after
it's done. There is no reason to wait for and prioritize the exit of a
task that doesn't even have memory anymore. Once a task's memory has
been reaped, subsequent OOM invocations should evaluate anew the most
desirable OOM victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
