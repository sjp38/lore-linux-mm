Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 191FD6B0263
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:41:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 190so38731246pfv.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:41:22 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id c14si8687441pfc.93.2016.10.12.03.41.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 03:41:21 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id s8so2479768pfj.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:41:21 -0700 (PDT)
Date: Wed, 12 Oct 2016 12:41:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: kmemleak: Ensure that the task stack is not freed
 during scanning
Message-ID: <20161012104118.GC9523@dhcp22.suse.cz>
References: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, CAI Qian <caiqian@redhat.com>

On Wed 12-10-16 10:57:03, Catalin Marinas wrote:
> Commit 68f24b08ee89 ("sched/core: Free the stack early if
> CONFIG_THREAD_INFO_IN_TASK") may cause the task->stack to be freed
> during kmemleak_scan() execution, leading to either a NULL pointer
> fault (if task->stack is NULL) or kmemleak accessing already freed
> memory. This patch uses the new try_get_task_stack() API to ensure that
> the task stack is not freed during kmemleak stack scanning.

Looks good to me
 
> Fixes: 68f24b08ee89 ("sched/core: Free the stack early if CONFIG_THREAD_INFO_IN_TASK")
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: CAI Qian <caiqian@redhat.com>
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
> This was reported in a subsequent comment here:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=173901
> 
> However, the original bugzilla entry doesn't look related to task stack
> freeing as it was first reported on 4.8-rc8. Andy, sorry for cc'ing you
> to bugzilla, please feel free to remove your email from the bug above (I
> can't seem to be able to do it).
> 
>  mm/kmemleak.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index a5e453cf05c4..e5355a5b423f 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1453,8 +1453,11 @@ static void kmemleak_scan(void)
>  
>  		read_lock(&tasklist_lock);
>  		do_each_thread(g, p) {
> -			scan_block(task_stack_page(p), task_stack_page(p) +
> -				   THREAD_SIZE, NULL);
> +			void *stack = try_get_task_stack(p);
> +			if (stack) {
> +				scan_block(stack, stack + THREAD_SIZE, NULL);
> +				put_task_stack(p);
> +			}
>  		} while_each_thread(g, p);
>  		read_unlock(&tasklist_lock);
>  	}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
