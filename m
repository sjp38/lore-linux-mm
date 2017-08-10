Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 496E96B0311
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 14:06:01 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i143so6811806qke.14
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 11:06:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f7si5908933qkc.264.2017.08.10.11.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 11:06:00 -0700 (PDT)
Date: Thu, 10 Aug 2017 20:05:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170810180554.GT25347@redhat.com>
References: <20170810081632.31265-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810081632.31265-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Aug 10, 2017 at 10:16:32AM +0200, Michal Hocko wrote:
> Andrea has proposed and alternative solution [4] which should be
> equivalent functionally similar to {ksm,khugepaged}_exit. I have to
> confess I really don't like that approach but I can live with it if
> that is a preferred way (to be honest I would like to drop the empty

Well you added two branches, when only one is necessary. It's more or
less like preferring a rwsem when a mutex is enough, because you're
more used to use rwsems.

> down_write();up_write() from the other two callers as well). In fact I
> have asked Andrea to post his patch [5] but that hasn't happened. I do
> not think we should wait much longer and finally merge some fix. 

It's posted in [4] already below I didn't think it was necessary to
resend it. The only other improvement I can think of is an unlikely
around tsk_is_oom_victim() in exit_mmap, but your patch below would
need it too, and two of them.

> [1] http://lkml.kernel.org/r/20170724072332.31903-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20170725142626.GJ26723@dhcp22.suse.cz
> [3] http://lkml.kernel.org/r/20170725160359.GO26723@dhcp22.suse.cz
> [4] http://lkml.kernel.org/r/20170726162912.GA29716@redhat.com
> [5] http://lkml.kernel.org/r/20170728062345.GA2274@dhcp22.suse.cz
> 
> +	if (tsk_is_oom_victim(current)) {
> +		down_write(&mm->mmap_sem);
> +		locked = true;
> +	}
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> @@ -3005,7 +3018,10 @@ void exit_mmap(struct mm_struct *mm)
>  			nr_accounted += vma_pages(vma);
>  		vma = remove_vma(vma);
>  	}
> +	mm->mmap = NULL;
>  	vm_unacct_memory(nr_accounted);
> +	if (locked)
> +		up_write(&mm->mmap_sem);

I wouldn't normally repost to add an unlikely when I'm not sure if it
gets merged, but if it gets merged I would immediately tell to Andrew
about the microoptimization being missing there so he can fold it
later.

Before reposting about the unlikely I thought we should agree which
version to merge: [4] or the above double branch (for no good as far
as I tangibly can tell).

I think down_write;up_write is the correct thing to do here because
holding the lock for any additional instruction has zero benefits, and
if it has zero benefits it only adds up confusion and makes the code
partly senseless, and that ultimately hurts the reader when it tries
to understand why you're holding the lock for so long when it's not
needed.

I just read other code yesterday for another bug about the rss going
off by one in some older kernel, that calls add_mm_rss_vec(mm, rss);
where rss is on the stack and mm->rss_stat is mm global, under the PT
lock, and again I had to ask myself why is it done there, and if the
PT lock could possibly help. My evaluation was no, it's just done in
the wrong place, but then I'm not 100% sure because there's a chance I
misread something very subtle.

	add_mm_rss_vec(mm, rss);
	arch_leave_lazy_mmu_mode();

	/* Do the actual TLB flush before dropping ptl */
	if (force_flush)
		tlb_flush_mmu_tlbonly(tlb);
	pte_unmap_unlock(start_pte, ptl);

The tlb flushing doesn't seem to check the stats either, so why is
add_mm_rss_vec isn't called after pte_unmap_unlock?

And yes it looks offtopic (and there's no bug in the rss accounting, I
was just reading around it just in case) but it's not, it's precisely
the kind of issue I have with your patch because it'll introduce
another case like above that I can't explain why it's done under a
lock when it doesn't need it, and it's hard to guess it was just your
dislike for down_read;up_write that made you choose to hold the lock
for no good reason arbitrarily a bit longer.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
