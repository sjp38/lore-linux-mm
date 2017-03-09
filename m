From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
Date: Thu, 9 Mar 2017 19:46:14 +0900
Message-ID: <201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru
List-Id: linux-mm.kvack.org

Andrew, do you have any questions on this patch?
I really need this patch for finding bugs which MM people overlook.

Tetsuo Handa wrote:
> This patch adds a watchdog which periodically reports number of memory
> allocating tasks, dying tasks and OOM victim tasks when some task is
> spending too long time inside __alloc_pages_slowpath(). This patch also
> serves as a hook for obtaining additional information using SystemTap
> (e.g. examine other variables using printk(), capture a crash dump by
> calling panic()) by triggering a callback only when a stall is detected.
> Ability to take administrator-controlled actions based on some threshold
> is a big advantage gained by introducing a state tracking.
> 
> Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
> too long") was a great step for reducing possibility of silent hang up
> problem caused by memory allocation stalls [1]. However, there are
> reports of long stalls (e.g. [2] is over 30 minutes!) and lockups (e.g.
> [3] is an "unable to invoke the OOM killer due to !__GFP_FS allocation"
> lockup problem) where this patch is more useful than that commit, for
> this patch can report possibly related tasks even if allocating tasks
> are unexpectedly blocked for so long. Regarding premature OOM killer
> invocation, tracepoints which can accumulate samples in short interval
> would be useful. But regarding too late to report allocation stalls,
> this patch which can capture all tasks (for reporting overall situation)
> in longer interval and act as a trigger (for accumulating short interval
> samples) would be useful.
