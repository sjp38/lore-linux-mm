Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7556B0253
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:03:23 -0500 (EST)
Received: by mail-qk0-f179.google.com with SMTP id o6so11959931qkc.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:03:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t37si7654484qgt.88.2016.01.18.06.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 06:03:22 -0800 (PST)
Subject: Re: [PATCH] sched/numa: Fix use-after-free bug in the
 task_numa_compare
References: <1453125548-2762-1-git-send-email-gavin.guo@canonical.com>
From: Rik van Riel <riel@redhat.com>
Message-ID: <569CF0A7.4000306@redhat.com>
Date: Mon, 18 Jan 2016 09:03:19 -0500
MIME-Version: 1.0
In-Reply-To: <1453125548-2762-1-git-send-email-gavin.guo@canonical.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gavin.guo@canonical.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, jay.vosburgh@canonical.com, liang.chen@canonical.com, mgorman@suse.de, mingo@redhat.com, peterz@infradead.org

On 01/18/2016 08:59 AM, gavin.guo@canonical.com wrote:
> From: Gavin Guo <gavin.guo@canonical.com>

> As commit 1effd9f19324 ("sched/numa: Fix unsafe get_task_struct() in
> task_numa_assign()") points out, the rcu_read_lock() cannot protect the
> task_struct from being freed in the finish_task_switch(). And the bug
> happens in the process of calculation of imp which requires the access of
> p->numa_faults being freed in the following path:
> 
> do_exit()
>         current->flags |= PF_EXITING;
>     release_task()
>         ~~delayed_put_task_struct()~~
>     schedule()
>     ...
>     ...
> rq->curr = next;
>     context_switch()
>         finish_task_switch()
>             put_task_struct()
>                 __put_task_struct()
> 		    task_numa_free()
> 
> The fix here to get_task_struct() early before end of dst_rq->lock to
> protect the calculation process and also put_task_struct() in the
> corresponding point if finally the dst_rq->curr somehow cannot be
> assigned.
> 
> BugLink: https://bugs.launchpad.net/bugs/1527643
> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
