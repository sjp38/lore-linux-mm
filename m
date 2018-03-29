Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5F256B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 17:30:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e13so5444074pfn.16
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 14:30:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b2-v6si1973644pls.379.2018.03.29.14.30.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 14:30:05 -0700 (PDT)
Date: Thu, 29 Mar 2018 14:30:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-Id: <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
In-Reply-To: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>

On Thu, 29 Mar 2018 20:27:50 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Theoretically it is possible that an mm_struct with 60000+ vmas loops
> with potentially allocating memory, with mm->mmap_sem held for write by
> the current thread. Unless I overlooked that fatal_signal_pending() is
> somewhere in the loop, this is bad if current thread was selected as an
> OOM victim, for the current thread will continue allocations using memory
> reserves while the OOM reaper is unable to reclaim memory.

All of which implies to me that this patch fixes a problem which is not
known to exist!  

> But there is no point with continuing the loop from the beginning if
> current thread is killed. If there were __GFP_KILLABLE (or something
> like memalloc_nofs_save()/memalloc_nofs_restore()), we could apply it
> to all allocations inside the loop. But since we don't have such flag,
> this patch uses fatal_signal_pending() check inside the loop.

Dumb question: if a thread has been oom-killed and then tries to
allocate memory, should the page allocator just fail the allocation
attempt?  I suppose there are all sorts of reasons why not :(

In which case, yes, setting a new
PF_MEMALLOC_MAY_FAIL_IF_I_WAS_OOMKILLED around such code might be a
tidy enough solution.  It would be a bit sad to add another test in the
hot path (should_fail_alloc_page()?), but geeze we do a lot of junk
already.

> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -440,6 +440,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  			continue;
>  		}
>  		charge = 0;
> +		if (fatal_signal_pending(current)) {
> +			retval = -EINTR;
> +			goto out;
> +		}
>  		if (mpnt->vm_flags & VM_ACCOUNT) {
>  			unsigned long len = vma_pages(mpnt);

I think a comment explaining why we're doing this would help.

Better would be to add a new function "current_is_oom_killed()" or
such, which becomes self-documenting.  Because there are other reasons
why a task may have a fatal signal pending.
