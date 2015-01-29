Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 52C926B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 14:57:20 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id rl12so38444375iec.0
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 11:57:19 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id m9si2038709igx.18.2015.01.29.11.57.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 11:57:19 -0800 (PST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so14064058igb.5
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 11:57:19 -0800 (PST)
Date: Thu, 29 Jan 2015 11:57:35 -0800
From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH] mm: fix arithmetic overflow in __vm_enough_memory()
Message-ID: <20150129195735.GA9331@scruffy>
References: <1422536763-31325-1-git-send-email-klamm@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422536763-31325-1-git-send-email-klamm@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, stable@vger.kernel.org

On Thu, Jan 29, 2015 at 04:06:03PM +0300, Roman Gushchin wrote:
> I noticed, that "allowed" can easily overflow by falling below 0,
> because (total_vm / 32) can be larger than "allowed". The problem
> occurs in OVERCOMMIT_NONE mode.
> 
> In this case, a huge allocation can success and overcommit the system
> (despite OVERCOMMIT_NONE mode). All subsequent allocations will fall
> (system-wide), so system become unusable.
> 
> The problem was masked out by commit c9b1d0981fcc
> ("mm: limit growth of 3% hardcoded other user reserve"),
> but it's easy to reproduce it on older kernels:
> 1) set overcommit_memory sysctl to 2
> 2) mmap() large file multiple times (with VM_SHARED flag)
> 3) try to malloc() large amount of memory
> 
> It also can be reproduced on newer kernels, but miss-configured
> sysctl_user_reserve_kbytes is required.
> 
> Fix this issue by switching to signed arithmetic here.
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrew Shewmaker <agshew@gmail.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Cc: stable@vger.kernel.org
> ---
>  mm/mmap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7f684d5..5aa8dfe 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -152,7 +152,7 @@ EXPORT_SYMBOL_GPL(vm_memory_committed);
>   */
>  int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  {
> -	unsigned long free, allowed, reserve;
> +	long free, allowed, reserve;
>  
>  	VM_WARN_ONCE(percpu_counter_read(&vm_committed_as) <
>  			-(s64)vm_committed_as_batch * num_online_cpus(),
> @@ -220,7 +220,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  	 */
>  	if (mm) {
>  		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
> -		allowed -= min(mm->total_vm / 32, reserve);
> +		allowed -= min((long)mm->total_vm / 32, reserve);
>  	}
>  
>  	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
> -- 
> 2.1.0
> 
Makes sense to me. Please fix mm/nommu.c also.

If a caller passes in a big negative value for pages,
then vm_acct_memory() would decrement vm_committed_as, possibly 
causing percpu_counter_read_positive(&vm_committed_as) and
__vm_enough_memory to return 0. Maybe that's okay? Callers
won't be passing in a negative pages anyway. Is there a reason
to let them, though?

-Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
