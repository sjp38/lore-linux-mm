Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 314FD6B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:19:46 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so49041989lbb.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:19:46 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id f5si29288383wjh.50.2016.06.13.04.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 04:19:44 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id k204so74751584wmk.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:19:44 -0700 (PDT)
Date: Mon, 13 Jun 2016 13:19:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
Message-ID: <20160613111943.GB6518@dhcp22.suse.cz>
References: <201606102323.BCC73478.FtOJHFQMSVFLOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606102323.BCC73478.FtOJHFQMSVFLOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 10-06-16 23:23:36, Tetsuo Handa wrote:
[...]
>   (1) freeze_processes() starts freezing user space threads.
>   (2) Somebody (maybe a kenrel thread) calls out_of_memory().
>   (3) The OOM killer calls mark_oom_victim() on a user space thread
>       P1 which is already in __refrigerator().
>   (4) oom_killer_disable() sets oom_killer_disabled = true.
>   (5) P1 leaves __refrigerator() and enters do_exit().
>   (6) The OOM reaper calls exit_oom_victim(P1) before P1 can call
>       exit_oom_victim(P1).
>   (7) oom_killer_disable() returns while P1 is not yet frozen
>       again (i.e. not yet marked as PF_FROZEN).
>   (8) P1 perform IO/interfere with the freezer.

You are right. I missed that kernel threads are still alive when writing
e26796066fdf929c ("oom: make oom_reaper freezable").

I am trying to remember why we are disabling oom killer before kernel
threads are frozen but not really sure about that right away. I guess it
has something to do with freeze_kernel_threads being called from
different contexts as well so freeze_processes was just more convinient
and was OK for correctness at the time.

> try_to_freeze_tasks(false) from freeze_kernel_threads() will freeze
> P1 again, but it seems to me that freeze_kernel_threads() is not
> always called when freeze_processes() suceeded.
> 
> Therefore, we need to do like
> 
> -	exit_oom_victim(tsk);
> +	mutex_lock(&oom_lock);
> +	if (!oom_killer_disabled)
> +		exit_oom_victim(tsk);
> +	mutex_unlock(&oom_lock);
> 
> in oom_reap_task(), don't we?

I do not like this very much. I would rather make sure that all
freezable kernel threads are frozen when disabling the oom killer.

[...]

> But we might be able to do like below patch rather than above patch.
> If below approach is OK, "[PATCH 10/10] mm, oom: hide mm which is shared
> with kthread or global init" will be able to call exit_oom_victim() when
> can_oom_reap became false.

I believe this is not really needed. I will follow up on the 10/10
later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
