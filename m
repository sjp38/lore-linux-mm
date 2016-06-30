Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62FC06B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 07:21:38 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a4so57995858lfa.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 04:21:38 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id b139si769448wme.44.2016.06.30.04.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 04:21:37 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a66so21924561wme.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 04:21:36 -0700 (PDT)
Date: Thu, 30 Jun 2016 13:21:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160630112129.GI18783@dhcp22.suse.cz>
References: <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
 <20160629200108.GA19253@redhat.com>
 <20160630075904.GC18783@dhcp22.suse.cz>
 <201606301951.AAB26052.OtOOQMLHVFJSFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606301951.AAB26052.OtOOQMLHVFJSFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: oleg@redhat.com, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Thu 30-06-16 19:51:53, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > I have changed that to cmpxchg because lowmemory killer is called
> > outside of oom_lock.
> 
> Android's lowmemory killer is no longer using mark_oom_victim().

You are right! The mmotm tree doesn't have the patch because it was
routed via Greg. I will probably keep the cmpxchg, though, because it
it less error prone and doesn't add much...
 
[...]

> By the way, are you going to fix use_mm() race? Currently, we don't wake up
> OOM reaper if some kernel thread is holding a reference to that mm via
> use_mm(). But currently we can hit
> 
>   (1) OOM killer fails to find use_mm() users using for_each_process() in
>       oom_kill_process() and wakes up OOM reaper.
> 
>   (2) Some kernel thread calls use_mm().
> 
>   (3) OOM reaper ignores use_mm() users and reaps that mm.
> 
> race. I think we need to make use_mm() fail after mark_oom_victim() is called.

Considering it would matter only for the vhost which I would like to be
oom reaper safe I would prefer to do the later and not treat kthreads
special.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
