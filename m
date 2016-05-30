Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 847286B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 13:43:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a143so279480636oii.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 10:43:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 186si26879758ith.8.2016.05.30.10.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 10:43:28 -0700 (PDT)
Date: Mon, 30 May 2016 19:43:24 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/6] proc, oom: drop bogus task_lock and mm check
Message-ID: <20160530174324.GA25382@redhat.com>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464613556-16708-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/30, Michal Hocko wrote:
>
> both oom_adj_write and oom_score_adj_write are using task_lock,
> check for task->mm and fail if it is NULL. This is not needed because
> the oom_score_adj is per signal struct so we do not need mm at all.
> The code has been introduced by 3d5992d2ac7d ("oom: add per-mm oom
> disable count") but we do not do per-mm oom disable since c9f01245b6a7
> ("oom: remove oom_disable_count").
>
> The task->mm check is even not correct because the current thread might
> have exited but the thread group might be still alive - e.g. thread
> group leader would lead that echo $VAL > /proc/pid/oom_score_adj would
> always fail with EINVAL while /proc/pid/task/$other_tid/oom_score_adj
> would succeed. This is unexpected at best.
>
> Remove the lock along with the check to fix the unexpected behavior
> and also because there is not real need for the lock in the first place.

ACK

and we should also remove lock_task_sighand(). as for oom_adj_read() and
oom_score_adj_read() we can just remove it right now; it was previously
needed to ensure the task->signal != NULL, today this is always true.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
