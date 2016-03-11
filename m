Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 33B106B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:12:15 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so13818994wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:12:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm2si10404561wjb.153.2016.03.11.03.12.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 03:12:14 -0800 (PST)
Subject: Re: [PATCH] mm, fork: make dup_mmap wait for mmap_sem for write
 killable
References: <1456752417-9626-9-git-send-email-mhocko@kernel.org>
 <1456769232-27592-1-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E2A80C.6040401@suse.cz>
Date: Fri, 11 Mar 2016 12:12:12 +0100
MIME-Version: 1.0
In-Reply-To: <1456769232-27592-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 02/29/2016 07:07 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> dup_mmap needs to lock current's mm mmap_sem for write. If the waiting
> task gets killed by the oom killer it would block oom_reaper from
> asynchronous address space reclaim and reduce the chances of timely OOM
> resolving. Wait for the lock in the killable mode and return with EINTR
> if the task got killed while waiting.
>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   kernel/fork.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d277e83ed3e0..139968026b76 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -413,7 +413,10 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>   	unsigned long charge;
>
>   	uprobe_start_dup_mmap();
> -	down_write(&oldmm->mmap_sem);
> +	if (down_write_killable(&oldmm->mmap_sem)) {
> +		retval = -EINTR;
> +		goto fail_uprobe_end;
> +	}
>   	flush_cache_dup_mm(oldmm);
>   	uprobe_dup_mmap(oldmm, mm);
>   	/*
> @@ -525,6 +528,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>   	up_write(&mm->mmap_sem);
>   	flush_tlb_mm(oldmm);
>   	up_write(&oldmm->mmap_sem);
> +fail_uprobe_end:
>   	uprobe_end_dup_mmap();
>   	return retval;
>   fail_nomem_anon_vma_fork:
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
