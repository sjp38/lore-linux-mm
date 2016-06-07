Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 334C66B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 17:49:42 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h144so204691023ita.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 14:49:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o20si7487764otd.154.2016.06.07.14.49.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Jun 2016 14:49:41 -0700 (PDT)
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160603122030.GG20676@dhcp22.suse.cz>
	<201606040017.HDI52680.LFFOVMJQOFSOHt@I-love.SAKURA.ne.jp>
	<20160606083651.GE11895@dhcp22.suse.cz>
	<201606072330.AHH81886.OOMVHFOFLtFSQJ@I-love.SAKURA.ne.jp>
	<20160607150534.GO12305@dhcp22.suse.cz>
In-Reply-To: <20160607150534.GO12305@dhcp22.suse.cz>
Message-Id: <201606080649.DGF51523.FLMOSHVtFFOJOQ@I-love.SAKURA.ne.jp>
Date: Wed, 8 Jun 2016 06:49:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> OK, so you are arming the timer for each mark_oom_victim regardless
> of the oom context. This means that you have replaced one potential
> lockup by other potential livelocks. Tasks from different oom domains
> might interfere here...
> 
> Also this code doesn't even seem easier. It is surely less lines of
> code but it is really hard to realize how would the timer behave for
> different oom contexts.

If you worry about interference, we can use per signal_struct timestamp.
I used per task_struct timestamp in my earlier versions (where per
task_struct TIF_MEMDIE check was used instead of per signal_struct
oom_victims).

> > What is wrong with above patch? How much difference is there compared to
> > calling schedule_timeout_killable(HZ) in oom_kill_process() before
> > releasing oom_lock and later checking MMF_OOM_REAPED after re-taking
> > oom_lock when we can't wake up the OOM reaper?
> 
> I fail to see how much this is different, really. Your patch is checking
> timer_pending with a global context in the same path and that is imho
> much harder to argue about than something which is task->mm based.

We can use per signal_struct or per task_struct timestamp if you don't
like global timestamp.

> > I'm OK with "a decision based by a feedback" but you don't like waking up
> > the OOM reaper ("invoking the oom reaper just to find out what we know
> > already and it is unlikely to change after oom_kill_process just doesn't
> > make much sense."). So what feedback mechanisms are possible other than
> > timeout like above patch?
> 
> Is this about the patch 10? Well, yes, there is a case where oom reaper
> cannot be invoked and we have no feedback. Then we have no other way
> than to wait for some time. I believe it is easier to wait in the oom
> context directly than to add a global timer. Both approaches would need
> some code in the oom victim selection code and it is much easier to
> argue about the victim specific context than a global one as mentioned
> above.

But expiring timeout by sleeping inside oom_kill_process() prevents other
threads which are OOM-killed from obtaining TIF_MEMDIE, for anybody needs
to wait for oom_lock in order to obtain TIF_MEMDIE. Unless you set
TIF_MEMDIE to all OOM-killed threads from oom_kill_process() or allow
the caller context to use ALLOC_NO_WATERMARKS by checking whether current
was already OOM-killed rather than TIF_MEMDIE, attempt to expiring timeout
by sleeping inside oom_kill_process() is useless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
