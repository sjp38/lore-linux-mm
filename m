Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2702F6B0260
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:12:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p192so40166774wme.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:12:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p198si23352318wmb.10.2017.01.25.10.11.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:11:59 -0800 (PST)
Date: Wed, 25 Jan 2017 13:11:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170125181150.GA16398@cmpxchg.org>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Nov 06, 2016 at 04:15:01PM +0900, Tetsuo Handa wrote:
> +- Why need to use it?
> +
> +Currently, when something went wrong inside memory allocation request,
> +the system might stall without any kernel messages.
> +
> +Although there is khungtaskd kernel thread as an asynchronous monitoring
> +approach, khungtaskd kernel thread is not always helpful because memory
> +allocating tasks unlikely sleep in uninterruptible state for
> +/proc/sys/kernel/hung_task_timeout_secs seconds.
> +
> +Although there is warn_alloc() as a synchronous monitoring approach
> +which emits
> +
> +  "%s: page allocation stalls for %ums, order:%u, mode:%#x(%pGg)\n"
> +
> +line, warn_alloc() is not bullet proof because allocating tasks can get
> +stuck before calling warn_alloc() and/or allocating tasks are using
> +__GFP_NOWARN flag and/or such lines are suppressed by ratelimiting and/or
> +such lines are corrupted due to collisions.

I'm not fully convinced by this explanation. Do you have a real life
example where the warn_alloc() stall info is not enough? If yes, this
should be included here and in the changelog. If not, the extra code,
the task_struct overhead etc. don't seem justified.

__GFP_NOWARN shouldn't suppress stall warnings, IMO. It's for whether
the caller expects allocation failure and is prepared to handle it; an
allocation stalling out for 10s is an issue regardless of the callsite.

---
