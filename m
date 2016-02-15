Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB626B0009
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 15:40:15 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so164226094wme.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:40:15 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id lh1si43322310wjc.78.2016.02.15.12.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 12:40:14 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id b205so10119389wmb.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:40:14 -0800 (PST)
Date: Mon, 15 Feb 2016 21:40:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3.1/5] oom: make oom_reaper freezable
Message-ID: <20160215204011.GC9223@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-4-git-send-email-mhocko@kernel.org>
 <201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
 <20160204144319.GD14425@dhcp22.suse.cz>
 <20160206064505.GB20537@dhcp22.suse.cz>
 <201602062333.CCI64980.MFJFFVOLtOOQSH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602062333.CCI64980.MFJFFVOLtOOQSH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew,
this can be either folded into 3/5 patch or go as a standalone one. I
would be inclined to have it standalone for the record (the description
should be pretty clear about the intention) and because the issue is
highly unlikely. OOM during the PM freezer doesn't happen in 99% cases.

On Sat 06-02-16 23:33:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > OK, I was thinking about it some more and it seems you are right here.
> > oom_reaper as a kernel thread is not freezable automatically and so it
> > might interfere after all the processes/kernel threads are considered
> > frozen. Then it really might shut down TIF_MEMDIE too early and wake out
> > oom_killer_disable. wait_event_freezable is not sufficient because the
> > oom_reaper might running while the PM freezer is freezing tasks and it
> > will miss it because it doesn't see it.
> 
> I'm not using PM freezer, but your answer is opposite to my guess.
> I thought try_to_freeze_tasks(false) is called by freeze_kernel_threads()
> after oom_killer_disable() succeeded, and try_to_freeze_tasks(false) will
> freeze both userspace tasks (including OOM victims which got TIF_MEMDIE
> cleared by the OOM reaper) and kernel threads (including the OOM reaper).

kernel threads which are not freezable are ignored by the freezer.

> Thus, I was guessing that clearing TIF_MEMDIE without reaching do_exit() is
> safe.

Does the following explains it better?
---
