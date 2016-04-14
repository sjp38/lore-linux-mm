Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7705E6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:34:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g185so160074517ioa.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:34:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mc7si6506883igb.48.2016.04.14.04.34.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 04:34:29 -0700 (PDT)
Subject: Re: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160414112146.GD2850@dhcp22.suse.cz>
In-Reply-To: <20160414112146.GD2850@dhcp22.suse.cz>
Message-Id: <201604142034.BIF60426.FLFMVOHOJQStOF@I-love.SAKURA.ne.jp>
Date: Thu, 14 Apr 2016 20:34:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 14-04-16 19:56:30, Tetsuo Handa wrote:
> > Assuming that try_oom_reaper() is correctly implemented, we should use
> > try_oom_reaper() for testing "whether the OOM reaper is allowed to reap
> > the OOM victim's memory" rather than "whether the OOM killer is allowed
> > to send SIGKILL to thread groups sharing the OOM victim's memory",
> > for the OOM reaper is allowed to reap the OOM victim's memory even if
> > that memory is shared by OOM_SCORE_ADJ_MIN but already-killed-or-exiting
> > thread groups.
> 
> So you prefer to crawl over the whole task list again just to catch a
> really unlikely case where the OOM_SCORE_ADJ_MIN mm sharing task was
> already exiting? Under which workload does this matter?
> 
> The patch seems correct I just do not see any point in it because I do
> not think it handles any real life situation. I basically consider any
> workload where only _certain_ thread(s) or process(es) sharing the mm have
> OOM_SCORE_ADJ_MIN set as invalid. Why should we care about those? This
> requires root to cripple the system. Or am I missing a valid
> configuration where this would make any sense?

Because __oom_reap_task() as of current linux.git marks only one of
thread groups as OOM_SCORE_ADJ_MIN and happily disables further reaping
(which I'm utilizing such behavior for catching bugs which occur under
almost OOM situation).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
