Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id B5AEB6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 16:21:45 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l68so3725007wml.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 13:21:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v80si652968wmv.40.2016.03.09.13.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 13:21:44 -0800 (PST)
Date: Wed, 9 Mar 2016 13:21:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2]
 oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
Message-Id: <20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
In-Reply-To: <1457442737-8915-3-git-send-email-mhocko@kernel.org>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
	<1457442737-8915-3-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue,  8 Mar 2016 14:12:17 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> fix a left over
> 
> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/oom_kill.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 70fff7e3b1a7..b6228643367b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -569,7 +569,7 @@ static int __init oom_init(void)
>  }
>  subsys_initcall(oom_init)
>  #else
> -static void wake_oom_reaper(struct task_struct *mm)
> +static void wake_oom_reaper(struct task_struct *tsk)
>  {
>  }
>  #endif

Thanks.

I found the below patch lying around but I didn't queue it properly. 
Is it legit?


From: Johannes Weiner <hannes@cmpxchg.org>
Subject: oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix

When the OOM killer scans tasks and encounters a PF_EXITING one, it
force-selects that one regardless of the score. Is there a possibility
that the task might hang after it has set PF_EXITING? In that case the
OOM killer should be able to move on to the next task.

Frankly, I don't even know why we check for exiting tasks in the OOM
killer. We've tried direct reclaim at least 15 times by the time we
decide the system is OOM, there was plenty of time to exit and free
memory; and a task might exit voluntarily right after we issue a kill.
This is testing pure noise.

Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Argangeli <andrea@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/oom_kill.c |    3 ---
 1 file changed, 3 deletions(-)

diff -puN mm/oom_kill.c~oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix mm/oom_kill.c
--- a/mm/oom_kill.c~oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
+++ a/mm/oom_kill.c
@@ -292,9 +292,6 @@ enum oom_scan_t oom_scan_process_thread(
 	if (oom_task_origin(task))
 		return OOM_SCAN_SELECT;
 
-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
-		return OOM_SCAN_ABORT;
-
 	return OOM_SCAN_OK;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
