Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 330136B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 09:22:09 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id h4so110627464oib.5
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 06:22:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t47si3970587ote.328.2017.06.03.06.22.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 03 Jun 2017 06:22:07 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
	<20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
	<20170603073221.GB21524@dhcp22.suse.cz>
In-Reply-To: <20170603073221.GB21524@dhcp22.suse.cz>
Message-Id: <201706032221.ADE30791.JHOOFQVFMLFOtS@I-love.SAKURA.ne.jp>
Date: Sat, 3 Jun 2017 22:21:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky@gmail.com, pmladek@suse.com

Michal Hocko wrote:
> I really do not see why that would be much better, really. warn_alloc is
> more or less one line + dump_stack + warn_alloc_show_mem. Single line
> shouldn't be a big deal even though this is a continuation line
> actually. dump_stack already contains its own synchronization and the
> meminfo stuff is ratelimited to one per second. So why do we exactly
> wantt to put yet another lock on top? Just to stick them together? Well
> is this worth a new lock dependency between memory allocation and the
> whole printk stack or dump_stack? Maybe yes but this needs a much deeper
> consideration.

If you don't want to add a new lock dependency between memory allocation
and the whole printk stack or dump_stack, I'm glad to reuse existing lock
dependency between memory allocation and the whole printk stack or dump_stack
named oom_lock mutex.

Although oom_lock is used for serializing invocation of the OOM killer so that
we don't send SIGKILL more than needed, things done by the OOM killer inside
dump_header() with oom_lock held includes what warn_alloc() does (i.e. call
printk(), dump_stack() and show_mem()).

If we reuse oom_lock for serializing warn_alloc() calls, we can also solve a
problem that the OOM killer cannot send SIGKILL due to preempted by other
threads spinning inside __alloc_pages_slowpath() waiting for the OOM killer
to make progress. Although you said we should not abuse an unrelated lock at
http://lkml.kernel.org/r/20161212125535.GA3185@dhcp22.suse.cz , out_of_memory()
and warn_alloc() are closely related because they are called when the system
cannot allocate memory.

We need to allow users to reliably save printk() output, and serialization for
yielding enough CPU time (by reusing oom_lock mutex or adding warn_alloc_lock
mutex) is one of prerequisites for saving printk() output.

"The fact that it doesn't throttle properly means that we should tune its
parameters." does not work here. We need to avoid wasting CPU time via
effectively "while(1) cond_resched();" situation in __alloc_pages_slowpath().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
