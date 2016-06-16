Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF2EF6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:15:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so103185852pfx.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:15:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id hq10si17002902pac.3.2016.06.16.06.15.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 06:15:08 -0700 (PDT)
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
	<1465473137-22531-11-git-send-email-mhocko@kernel.org>
	<201606100015.HBB65678.LSOFFJOFMQHOVt@I-love.SAKURA.ne.jp>
	<20160609154156.GG24777@dhcp22.suse.cz>
In-Reply-To: <20160609154156.GG24777@dhcp22.suse.cz>
Message-Id: <201606162215.IIE64528.FFFLHOJQtSOOVM@I-love.SAKURA.ne.jp>
Date: Thu, 16 Jun 2016 22:15:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 10-06-16 00:15:18, Tetsuo Handa wrote:
> [...]
> > Nobody will set MMF_OOM_REAPED flag if can_oom_reap == true on
> > CONFIG_MMU=n kernel. If a TIF_MEMDIE thread in CONFIG_MMU=n kernel
> > is blocked before exit_oom_victim() in exit_mm() from do_exit() is
> > called, the system will lock up. This is not handled in the patch
> > nor explained in the changelog.
> 
> I have made it clear several times that !CONFIG_MMU is not a target
> of this patch series nor other OOM changes because I am not convinced
> issues which we are trying to solve are real on those platforms. I
> am not really sure what you are trying to achieve now with these
> !CONFIG_MMU remarks but if you see _real_ regressions for those
> configurations please describe them. This generic statements when
> CONFIG_MMU implications are put into !CONFIG_MMU context are not really
> useful. If there are possible OOM killer deadlocks without this series
> then adding these patches shouldn't make them worse.
> 
> E.g. this particular patch is basically a noop for !CONFIG_MMU because
> use_mm() is MMU specific. It is also highly improbable that a task would
> share mm with init...

But this is not safe for CONFIG_MMU=y kernels as well.
can_oom_reap == false means that oom_reap_task() will not be called.
It is possible that the TIF_MEMDIE thread falls into

   atomic_read(&task->signal->oom_victims) > 0 && find_lock_task_mm(task) == NULL

situation. We are still risking OOM livelock. We must somehow clear (or ignore)
TIF_MEMDIE even if oom_reap_task() is not called.

Can't we apply http://lkml.kernel.org/r/201606102323.BCC73478.FtOJHFQMSVFLOO@I-love.SAKURA.ne.jp now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
