Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DA33F6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:11:32 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so42967714pab.12
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 12:11:32 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ko10si11031836pbd.171.2015.01.29.12.11.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 12:11:32 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so42965041pab.3
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 12:11:31 -0800 (PST)
Date: Thu, 29 Jan 2015 12:11:47 -0800
From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH] mm: don't account shared file pages in user_reserve_pages
Message-ID: <20150129201147.GB9331@scruffy>
References: <1422532287-23601-1-git-send-email-klamm@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422532287-23601-1-git-send-email-klamm@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Thu, Jan 29, 2015 at 02:51:27PM +0300, Roman Gushchin wrote:
> Shared file pages are never accounted in memory overcommit code,
> so it isn't reasonable to count them in a code that limits the
> maximal size of a process in OVERCOMMIT_NONE mode.
> 
> If a process has few large file mappings, the consequent attempts
> to allocate anonymous memory may unexpectedly fail with -ENOMEM,
> while there is free memory and overcommit limit if significantly
> larger than the committed amount (as displayed in /proc/meminfo).
> 
> The problem is significantly smoothed by commit c9b1d0981fcc
> ("mm: limit growth of 3% hardcoded other user reserve"),
> which limits the impact of this check with 128Mb (tunable via sysctl),
> but it can still be a problem on small machines.
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrew Shewmaker <agshew@gmail.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7f684d5..151fadf 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -220,7 +220,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  	 */
>  	if (mm) {
>  		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
> -		allowed -= min(mm->total_vm / 32, reserve);
> +		allowed -= min((mm->total_vm - mm->shared_vm) / 32, reserve);
>  	}
>  
>  	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
> -- 
> 2.1.0

You're two patches conflict, don't they? Maybe you should resend
them as a patch series such that they can both be applied?

Does mm->shared_vm include memory that's mapped MAP_ANONYMOUS in
conjunction with MAP_SHARED? If so, then subtracting it could
overcommit the system OVERCOMMIT_NEVER mode.

-Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
