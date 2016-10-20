Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C4AF36B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 08:07:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so22402407pfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 05:07:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i10si11294475pgd.225.2016.10.20.05.07.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 05:07:50 -0700 (PDT)
Subject: Re: How to make warn_alloc() reliable?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp>
	<20161018122749.GE12092@dhcp22.suse.cz>
	<201610192027.GFB17670.VOtOLQFFOSMJHF@I-love.SAKURA.ne.jp>
	<20161019115525.GH7517@dhcp22.suse.cz>
In-Reply-To: <20161019115525.GH7517@dhcp22.suse.cz>
Message-Id: <201610202107.FBC86440.SVFHFtOFOOLQJM@I-love.SAKURA.ne.jp>
Date: Thu, 20 Oct 2016 21:07:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 19-10-16 20:27:53, Tetsuo Handa wrote:
> [...]
> > What I'm talking about is "why don't you stop playing whack-a-mole games
> > with missing warn_alloc() calls". I don't blame you for not having a good
> > idea, but I blame you for not having a reliable warn_alloc() mechanism.
> 
> Look, it seems pretty clear that our priorities and viewes are quite
> different. While I believe that we should solve real issues in a
> reliable and robust way you seem to love to be have as much reporting as
> possible. I do agree that reporting is important part of debugging of
> problems but as your previous attempts for the allocation watchdog show
> a proper and bullet proof reporting requires state tracking and is in
> general too complex for something that doesn't happen in most properly
> configured systems. Maybe there are other ways but my time is better
> spent on something more useful - like making the direct reclaim path
> more deterministic without any unbound loops.

Properly configured systems should not be bothered by low memory situations.
There are systems which are bothered by low memory situations. It is pointless
to refer to "properly configured systems" as a reason not to add a watchdog.
It is administrators who decide whether to use a watchdog.

> 
> So let's agree to disagree about importance of the reliability
> warn_alloc. I see it as an improvement which doesn't really have to be
> perfect.

I don't expect kmallocwd alone to be perfect. I expect kmallocwd to serve
as a hook. For example, it will be possible to turn on collecting perf data
when kmallocwd found a stalling thread and turn off when kmallocwd found
none. Since necessary information are stored in the task struct, it will
be easy to include them into perf data. Likewise, it will be easy to
extract them using a script for /usr/bin/crash when an administrator
captured a vmcore image of a stalling KVM guest. Sending vmcore images
to support centers is difficult due to file size and security reasons.
It is nice if we can get a clue by reading the task list.

But warn_alloc() can't serve as a hook. I see kmallocwd as an improvement
which doesn't really have to be perfect.



By the way, regarding "making the direct reclaim path more deterministic"
part, I wish that we can

  (1) introduce phased watermarks which varies based on stage of reclaim
      operation (e.g. watermark_lower()/watermark_higher() which resembles
      preempt_disable()/preempt_enable() but is propagated to other threads
      when delegating operations needed for reclaim to other threads).

  (2) introduce dedicated kernel threads which perform only specific
      reclaim operation, using watermark propagated from other threads
      which performs different reclaim operation.

  (3) remove direct reclaim which bothers callers with managing correct
      GFP_NOIO / GFP_NOFS / GFP_KERNEL distinction. Then, normal
      ___GFP_DIRECT_RECLAIM callers can simply wait for
      wait_event(get_pages_from_freelist() succeeds) rather than polling
      with complicated short sleep. This will significantly save CPU
      resource (especially when oom_lock is held) which is wasted by
      activities by multiple concurrent direct reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
