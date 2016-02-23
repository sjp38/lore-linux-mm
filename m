Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A505E82F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 20:36:10 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id x65so102311038pfb.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:36:10 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id yi4si19561907pac.177.2016.02.22.17.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 17:36:09 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id e127so102514700pfe.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:36:09 -0800 (PST)
Date: Mon, 22 Feb 2016 17:36:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] oom reaper: handle mlocked pages
In-Reply-To: <1454505240-23446-3-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1602221734140.4688@chino.kir.corp.google.com>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org> <1454505240-23446-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 3 Feb 2016, Michal Hocko wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9a0e4e5f50b4..840e03986497 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -443,13 +443,6 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
>  			continue;
>  
>  		/*
> -		 * mlocked VMAs require explicit munlocking before unmap.
> -		 * Let's keep it simple here and skip such VMAs.
> -		 */
> -		if (vma->vm_flags & VM_LOCKED)
> -			continue;
> -
> -		/*
>  		 * Only anonymous pages have a good chance to be dropped
>  		 * without additional steps which we cannot afford as we
>  		 * are OOM already.
> @@ -459,9 +452,12 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
>  		 * we do not want to block exit_mmap by keeping mm ref
>  		 * count elevated without a good reason.
>  		 */
> -		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
> +			if (vma->vm_flags & VM_LOCKED)
> +				munlock_vma_pages_all(vma);
>  			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
>  					 &details);
> +		}
>  	}
>  	tlb_finish_mmu(&tlb, 0, -1);
>  	up_read(&mm->mmap_sem);

Are we concerned about munlock_vma_pages_all() taking lock_page() and 
perhaps stalling forever, the same way it would stall in exit_mmap() for 
VM_LOCKED vmas, if another thread has locked the same page and is doing an 
allocation?  I'm wondering if in that case it would be better to do a 
best-effort munlock_vma_pages_all() with trylock_page() and just give up 
on releasing memory from that particular vma.  In that case, there may be 
other memory that can be freed with unmap_page_range() that would handle 
this livelock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
