Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 094AF280911
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:40:50 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y51so27749131wry.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 02:40:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13si2351852wmd.11.2017.03.10.02.40.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 02:40:48 -0800 (PST)
Date: Fri, 10 Mar 2017 11:40:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170310104047.GF3753@dhcp22.suse.cz>
References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
 <20170309143751.05bddcbad82672384947de5f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309143751.05bddcbad82672384947de5f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

On Thu 09-03-17 14:37:51, Andrew Morton wrote:
> On Thu, 9 Mar 2017 19:46:14 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > Tetsuo Handa wrote:
> > > This patch adds a watchdog which periodically reports number of memory
> > > allocating tasks, dying tasks and OOM victim tasks when some task is
> > > spending too long time inside __alloc_pages_slowpath(). This patch also
> > > serves as a hook for obtaining additional information using SystemTap
> > > (e.g. examine other variables using printk(), capture a crash dump by
> > > calling panic()) by triggering a callback only when a stall is detected.
> > > Ability to take administrator-controlled actions based on some threshold
> > > is a big advantage gained by introducing a state tracking.
> > > 
> > > Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
> > > too long") was a great step for reducing possibility of silent hang up
> > > problem caused by memory allocation stalls [1]. However, there are
> > > reports of long stalls (e.g. [2] is over 30 minutes!) and lockups (e.g.
> > > [3] is an "unable to invoke the OOM killer due to !__GFP_FS allocation"
> > > lockup problem) where this patch is more useful than that commit, for
> > > this patch can report possibly related tasks even if allocating tasks
> > > are unexpectedly blocked for so long. Regarding premature OOM killer
> > > invocation, tracepoints which can accumulate samples in short interval
> > > would be useful. But regarding too late to report allocation stalls,
> > > this patch which can capture all tasks (for reporting overall situation)
> > > in longer interval and act as a trigger (for accumulating short interval
> > > samples) would be useful.
> )
> > Andrew, do you have any questions on this patch?
> > I really need this patch for finding bugs which MM people overlook.
> 
> (top-posting repaired - please don't do that)
> 
> Undecided.  I can see the need but it is indeed quite a large lump of
> code.  Perhaps some additional examples of how this new code was used
> to understand and improve real-world kernel problems would be persuasive.

Well, it is true that the watchdog can provide much more information
than we can gather with other debugging options we currently have when
allocations run away.  So I am not questioning this is useful when doing
memory stress testing and trying to trigger corner cases but I am not
really sure how much this will be useful in production systems, though.
Tracking is not for free both in runtime and longterm in maintenance.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
