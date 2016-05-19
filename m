Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64B556B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 10:29:52 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id dh6so139084596obb.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 07:29:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k184si25370455itk.103.2016.05.19.07.29.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 May 2016 07:29:51 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the oom reaper context
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
	<1461679470-8364-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461679470-8364-3-git-send-email-mhocko@kernel.org>
Message-Id: <201605192329.ABB17132.LFHOFJMVtOSFQO@I-love.SAKURA.ne.jp>
Date: Thu, 19 May 2016 23:29:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, mhocko@suse.com

Michal Hocko wrote:
> Tetsuo has properly noted that mmput slow path might get blocked waiting
> for another party (e.g. exit_aio waits for an IO). If that happens the
> oom_reaper would be put out of the way and will not be able to process
> next oom victim. We should strive for making this context as reliable
> and independent on other subsystems as much as possible.
> 
> Introduce mmput_async which will perform the slow path from an async
> (WQ) context. This will delay the operation but that shouldn't be a
> problem because the oom_reaper has reclaimed the victim's address space
> for most cases as much as possible and the remaining context shouldn't
> bind too much memory anymore. The only exception is when mmap_sem
> trylock has failed which shouldn't happen too often.
> 
> The issue is only theoretical but not impossible.

Just a random thought, but after this patch is applied, do we still need to use
a dedicated kernel thread for OOM-reap operation? If I recall correctly, the
reason we decided to use a dedicated kernel thread was that calling
down_read(&mm->mmap_sem) / mmput() from the OOM killer context is unsafe due to
dependency. By replacing mmput() with mmput_async(), since __oom_reap_task() will
no longer do operations that might block, can't we try OOM-reap operation from
current thread which called mark_oom_victim() or oom_scan_process_thread() ?
I want to start waking up the OOM reaper whenever TIF_MEMDIE is set or found.

Using a dedicated kernel thread is still better because memory allocation path
already consumed a lot of kernel stack? But we don't need to give up OOM-reaping
when kthread_run() failed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
