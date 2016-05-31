Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF466B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 11:10:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a136so45632077wme.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 08:10:22 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id s64si8382041wms.50.2016.05.31.08.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 08:10:21 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a136so33743121wme.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 08:10:21 -0700 (PDT)
Date: Tue, 31 May 2016 17:10:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Message-ID: <20160531151019.GN26128@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-7-git-send-email-mhocko@kernel.org>
 <201606010003.CAH18706.LFHOFVOJtQOSFM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606010003.CAH18706.LFHOFVOJtQOSFM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Wed 01-06-16 00:03:53, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > task_will_free_mem is rather weak. It doesn't really tell whether
> > the task has chance to drop its mm. 98748bd72200 ("oom: consider
> > multi-threaded tasks in task_will_free_mem") made a first step
> > into making it more robust for multi-threaded applications so now we
> > know that the whole process is going down and probably drop the mm.
> > 
> > This patch builds on top for more complex scenarios where mm is shared
> > between different processes - CLONE_VM without CLONE_THREAD resp
> > CLONE_SIGHAND, or in kernel use_mm().
> > 
> > Make sure that all processes sharing the mm are killed or exiting. This
> > will allow us to replace try_oom_reaper by wake_oom_reaper. Therefore
> > all paths which bypass the oom killer are now reapable and so they
> > shouldn't lock up the oom killer.
> 
> Really? The can_oom_reap variable was not removed before this patch.
> It means that oom_kill_process() might fail to call wake_oom_reaper()
> while setting TIF_MEMDIE to one of threads using that mm_struct.
> If use_mm() or global init keeps that mm_struct not OOM reapable, other
> threads sharing that mm_struct will get task_will_free_mem() == false,
> won't it?
> 
> How is it guaranteed that task_will_free_mem() == false && oom_victims > 0
> shall not lock up the OOM killer?

But this patch is talking about task_will_free_mem == true. Is the
description confusing? Should I reword the changelog?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
