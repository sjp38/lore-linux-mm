Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9506B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:26:54 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so29788418pab.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:26:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 130si19463929pfb.3.2016.01.28.14.26.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 14:26:53 -0800 (PST)
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452516120-5535-1-git-send-email-mhocko@kernel.org>
	<201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
	<20160126163823.GG27563@dhcp22.suse.cz>
	<201601282024.JBG90615.JLFQOSFFVOMHtO@I-love.SAKURA.ne.jp>
	<20160128215121.GE621@dhcp22.suse.cz>
In-Reply-To: <20160128215121.GE621@dhcp22.suse.cz>
Message-Id: <201601290726.GGC12497.OSQJVtMFFOHOLF@I-love.SAKURA.ne.jp>
Date: Fri, 29 Jan 2016 07:26:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 28-01-16 20:24:36, Tetsuo Handa wrote:
> [...]
> > I like the OOM reaper approach but I can't agree on merging the OOM reaper
> > without providing a guaranteed last resort at the same time. If you do want
> > to start the OOM reaper as simple as possible (without being bothered by
> > a lot of possible corner cases), please pursue a guaranteed last resort
> > at the same time.
> 
> I am getting tired of this level of argumentation. oom_reaper in its
> current form is a step forward. I have acknowledged there are possible
> improvements doable on top but I do not see them necessary for the core
> part being merged. I am not trying to rush this in because I am very
> well aware of how subtle and complex all the interactions might be.
> So please stop your "we must have it all at once" attitude. This is
> nothing we have to rush in. We are not talking about a regression which
> has to be absolutely fixed in few days.

I'm not asking you to merge a perfect version of oom_reaper from the
beginning. I know it is too difficult. Instead, I'm asking you to allow
using timeout based approaches (shown below) as temporarily workaround
because there are environments which cannot wait for oom_reaper to become
enough reliable. Would you please reply to the thread which proposed a
guaranteed last resort (shown below)?

Tetsuo Handa wrote:
> I consider phases for managing system-wide OOM events as follows.
> 
>   (1) Design and use a system with appropriate memory capacity in mind.
> 
>   (2) When (1) failed, the OOM killer is invoked. The OOM killer selects
>       an OOM victim and allow that victim access to memory reserves by
>       setting TIF_MEMDIE to it.
> 
>   (3) When (2) did not solve the OOM condition, start allowing all tasks
>       access to memory reserves by your approach.
> 
>   (4) When (3) did not solve the OOM condition, start selecting more OOM
>       victims by my approach.
> 
>   (5) When (4) did not solve the OOM condition, trigger the kernel panic.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
