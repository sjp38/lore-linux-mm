Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5256B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 18:27:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id di3so222690128pab.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 15:27:38 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id f88si30842823pfj.219.2016.06.06.15.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 15:27:37 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id 62so70853206pfd.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 15:27:37 -0700 (PDT)
Date: Mon, 6 Jun 2016 15:27:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
In-Reply-To: <1464945404-30157-7-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org> <1464945404-30157-7-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, 3 Jun 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Currently oom_kill_process skips both the oom reaper and SIG_KILL if a
> process sharing the same mm is unkillable via OOM_ADJUST_MIN. After "mm,
> oom_adj: make sure processes sharing mm have same view of oom_score_adj"
> all such processes are sharing the same value so we shouldn't see such a
> task at all (oom_badness would rule them out).
> 
> We can still encounter oom disabled vforked task which has to be killed
> as well if we want to have other tasks sharing the mm reapable
> because it can access the memory before doing exec. Killing such a task
> should be acceptable because it is highly unlikely it has done anything
> useful because it cannot modify any memory before it calls exec. An
> alternative would be to keep the task alive and skip the oom reaper and
> risk all the weird corner cases where the OOM killer cannot make forward
> progress because the oom victim hung somewhere on the way to exit.
> 
> There is a potential race where we kill the oom disabled task which is
> highly unlikely but possible. It would happen if __set_oom_adj raced
> with select_bad_process and then it is OK to consider the old value or
> with fork when it should be acceptable as well.
> Let's add a little note to the log so that people would tell us that
> this really happens in the real life and it matters.
> 

We cannot kill oom disabled processes at all, little race or otherwise.  
We'd rather panic the system than oom kill these processes, and that's the 
semantic that the user is basing their decision on.  We cannot suddenly 
start allowing them to be SIGKILL'd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
