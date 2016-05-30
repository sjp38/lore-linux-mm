Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA2E26B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:49:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p194so37766729iod.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:49:23 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0124.outbound.protection.outlook.com. [104.47.2.124])
        by mx.google.com with ESMTPS id t17si11340979otd.30.2016.05.30.06.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 May 2016 06:49:23 -0700 (PDT)
Date: Mon, 30 May 2016 16:49:15 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/6] proc, oom: drop bogus task_lock and mm check
Message-ID: <20160530134915.GD8293@esperanza>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1464613556-16708-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, May 30, 2016 at 03:05:51PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
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
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
