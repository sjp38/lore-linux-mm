Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id A5ACC828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 06:26:44 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id py5so112676962obc.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 03:26:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id xs11si6737592oec.89.2016.01.14.03.26.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 03:26:43 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
	<201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp>
	<20160113162610.GD17512@dhcp22.suse.cz>
	<20160113165609.GA21950@cmpxchg.org>
	<20160113180147.GL17512@dhcp22.suse.cz>
In-Reply-To: <20160113180147.GL17512@dhcp22.suse.cz>
Message-Id: <201601142026.BHI87005.FSOFJVFQMtHOOL@I-love.SAKURA.ne.jp>
Date: Thu, 14 Jan 2016 20:26:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I think you are missing an important point. There is _no reliable_ way
> to resolve the OOM condition in general except to panic the system. Even
> killing all user space tasks might not be sufficient in general because
> they might be blocked by an unkillable context (e.g. kernel thread).

I know. What I'm proposing is try to recover by killing more OOM-killable
tasks because I think impact of crashing the kernel is larger than impact
of killing all OOM-killable tasks. We should at least try OOM-kill all
OOM-killable processes before crashing the kernel. Some servers take many
minutes to reboot whereas restarting OOM-killed services takes only a few
seconds. Also, SysRq-i is inconvenient because it kills OOM-unkillable ssh
daemon process.

An example is:

  (1) Kill a victim and start timeout counter.

  (2) Kill all oom_score_adj > 0 tasks when OOM condition was not
      solved after 5 seconds since (1).

  (3) Kill all oom_score_adj = 0 tasks when OOM condition was not
      solved after 5 seconds since (2).

  (4) Kill all oom_score_adj >= -500 tasks when OOM condition was not
      solved after 5 seconds since (3).

  (5) Kill all oom_score_adj >= -999 tasks when OOM condition was not
      solved after 5 seconds since (4).

  (6) Trigger kernel panic because only OOM-unkillable tasks are left
      when OOM condition was not solved after 5 seconds since (5).

> All we can do is a best effort approach which tries to be optimized to
> reduce the impact of an unexpected SIGKILL sent to a "random" task. And
> this is a reasonable objective IMHO.

A best effort approach which tries to be optimized to reduce
the possibility of kernel panic should exist.



Michal Hocko wrote:
> Timeout-to-panic patches were just trying to be as simple as possible
> to guarantee the predictability requirement. No other timeout based
> solutions, which were proposed so far, did guarantee the same AFAIR.

What did "[PATCH] mm: Introduce timeout based OOM killing" miss
( http://lkml.kernel.org/r/201505232339.DAB00557.VFFLHMSOJFOOtQ@I-love.SAKURA.ne.jp )?
It provided

  (1) warn OOM victim not dying using memdie_task_warn_secs timeout
  (2) select next OOM victim using memdie_task_skip_secs timeout
  (3) trigger kernel panic using memdie_task_panic_secs timeout
  (4) warn trashing condition using memalloc_task_warn_secs timeout
  (5) trigger OOM killer using memalloc_task_retry_secs timeout

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
