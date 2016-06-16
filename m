Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA11B6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:37:27 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d71so88578805ith.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:37:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l67si12997456oib.95.2016.06.16.06.37.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 06:37:27 -0700 (PDT)
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
	<1465473137-22531-11-git-send-email-mhocko@kernel.org>
	<201606100015.HBB65678.LSOFFJOFMQHOVt@I-love.SAKURA.ne.jp>
	<20160609154156.GG24777@dhcp22.suse.cz>
	<201606162215.IIE64528.FFFLHOJQtSOOVM@I-love.SAKURA.ne.jp>
In-Reply-To: <201606162215.IIE64528.FFFLHOJQtSOOVM@I-love.SAKURA.ne.jp>
Message-Id: <201606162236.DDG82865.OFOtSLMJFVQHOF@I-love.SAKURA.ne.jp>
Date: Thu, 16 Jun 2016 22:36:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp

Tetsuo Handa wrote:
> But this is not safe for CONFIG_MMU=y kernels as well.
> can_oom_reap == false means that oom_reap_task() will not be called.
> It is possible that the TIF_MEMDIE thread falls into
> 
>    atomic_read(&task->signal->oom_victims) > 0 && find_lock_task_mm(task) == NULL
> 
> situation. We are still risking OOM livelock. We must somehow clear (or ignore)
> TIF_MEMDIE even if oom_reap_task() is not called.

Oops. mmput() from exit_mm() does not block in that case. So, we won't livelock here.

> 
> Can't we apply http://lkml.kernel.org/r/201606102323.BCC73478.FtOJHFQMSVFLOO@I-love.SAKURA.ne.jp now?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
