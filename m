Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6C5E6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 17:55:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c20so52428914pfc.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 14:55:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a190si13702274pfa.80.2016.04.19.14.55.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Apr 2016 14:55:49 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
	<20160419200752.GA10437@dhcp22.suse.cz>
In-Reply-To: <20160419200752.GA10437@dhcp22.suse.cz>
Message-Id: <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
Date: Wed, 20 Apr 2016 06:55:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> > This patch adds a timeout for handling corner cases where a TIF_MEMDIE
> > thread got stuck. Since the timeout is checked at oom_unkillable_task(),
> > oom_scan_process_thread() will not find TIF_MEMDIE thread
> > (for !oom_kill_allocating_task case) and oom_badness() will return 0
> > (for oom_kill_allocating_task case).
> > 
> > By applying this patch, the kernel will automatically press SysRq-f if
> > the OOM reaper cannot reap the victim's memory, and we will never OOM
> > livelock forever as long as the OOM killer is called.
> 
> Which will not guarantee anything as already pointed out several times
> before. So I think this is not really that useful. I have said it
> earlier and will repeat it again. Any timeout based solution which
> doesn't guarantee that the system will be in a consistent state (reboot,
> panic or kill all existing tasks) after the specified timeout is
> pointless.

Triggering the reboot/panic is the worst action. Killing all existing tasks
is the next worst action. Thus, I prefer killing tasks one by one.

I'm OK with shortening the timeout like N (when waiting for the 1st victim)
+ N/2 (the 2nd victim) + N/4 (the 3rd victim) + N/8 (the 4th victim) + ...
but does it worth complicating the least unlikely path?

> 
> I believe that the chances of the lockup are much less likely with the
> oom reaper and that we are not really urged to provide a new knob with a
> random semantic. If we really want to have a timeout based thing better
> make it behave reliably.

The threshold which the administrator can wait for ranges. Some may want to
set few seconds because of 10 seconds /dev/watchdog timeout, others may want
to set one minute because of not using watchdog. Thus, I think we should not
hard code the timeout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
