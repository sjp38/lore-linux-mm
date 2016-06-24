Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAB16B025E
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:54:42 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l184so71892015lfl.3
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:54:42 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id dk1si6032281wjd.197.2016.06.24.02.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 02:54:41 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id a66so18163643wme.0
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:54:40 -0700 (PDT)
Date: Fri, 24 Jun 2016 11:54:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
Message-ID: <20160624095439.GA20203@dhcp22.suse.cz>
References: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

On Fri 24-06-16 01:24:46, Tetsuo Handa wrote:
> I missed that victim != p case needs to use get_task_struct(). Patch updated.
> ----------------------------------------
> >From 1819ec63b27df2d544f66482439e754d084cebed Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 24 Jun 2016 01:16:02 +0900
> Subject: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
> 
> Patch "mm, oom: fortify task_will_free_mem" removed p->mm != NULL test for
> shortcut path in oom_kill_process(). But since commit f44666b04605d1c7
> ("mm,oom: speed up select_bad_process() loop") changed to iterate using
> thread group leaders, the possibility of p->mm == NULL has increased
> compared to when commit 83363b917a2982dd ("oom: make sure that TIF_MEMDIE
> is set under task_lock") was proposed. On CONFIG_MMU=n kernels, nothing
> will clear TIF_MEMDIE and the system can OOM livelock if TIF_MEMDIE was
> by error set to a mm-less thread group leader.
> 
> Let's do steps for regular path except printing OOM killer messages and
> sending SIGKILL.

I fully agree with Oleg. It would be much better to encapsulate this
into mark_oom_victim and guard it by ifdef NOMMU as this is nommu
specific with a big fat warning why we need it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
