Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2E786B0253
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:54:53 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 65so295742245uay.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:54:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g63si2016979qkc.286.2016.08.23.05.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 05:54:53 -0700 (PDT)
Date: Tue, 23 Aug 2016 15:54:50 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160823155330-mutt-send-email-mst@kernel.org>
References: <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160822130311.GL13596@dhcp22.suse.cz>
 <20160822210123.5k6zwdrkhrwjw5vv@redhat.com>
 <20160823075555.GE23577@dhcp22.suse.cz>
 <20160823090655.GA23583@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823090655.GA23583@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Tue, Aug 23, 2016 at 11:06:55AM +0200, Michal Hocko wrote:
> On Tue 23-08-16 09:55:55, Michal Hocko wrote:
> > On Tue 23-08-16 00:01:23, Michael S. Tsirkin wrote:
> > [...]
> > > Actually, vhost net calls out to tun which does regular copy_from_iter.
> > > Returning 0 there will cause corrupted packets in the network: not a
> > > huge deal, but ugly.  And I don't think we want to annotate run and
> > > macvtap as well.
> > 
> > Hmm, OK, I wasn't aware of that path and being consistent here matters.
> > If the vhost driver can interact with other subsystems then there is
> > really no other option than hooking into the page fault path. Ohh well.
> 
> Here is a completely untested patch just for sanity check.
> ---
> >From f32711ea518f8151d6efb1c71f359211117dd5a2 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 14 Jun 2016 09:33:06 +0200
> Subject: [PATCH] vhost, mm: make sure that oom_reaper doesn't reap memory read
>  by vhost
> 
> vhost driver relies on copy_from_user/get_user from a kernel thread.
> This makes it impossible to reap the memory of an oom victim which
> shares the mm with the vhost kernel thread because it could see a zero
> page unexpectedly and theoretically make an incorrect decision visible
> outside of the killed task context. To quote Michael S. Tsirkin:
> : Getting an error from __get_user and friends is handled gracefully.
> : Getting zero instead of a real value will cause userspace
> : memory corruption.
> 
> The vhost kernel thread is bound to an open fd of the vhost device which
> is not tight to the mm owner life cycle in theory. The fd can be
> inherited or passed over to another process which means that we really
> have to be careful about unexpected memory corruption because unlike for
> normal oom victims the result will be visible outside of the oom victim
> context.
> 
> Make sure that no kthread context (users of use_mm) can ever see
> corrupted data because of the oom reaper and hook into the page fault
> path by checking MMF_UNSTABLE mm flag. __oom_reap_task_mm will set the
> flag before it starts unmapping the address space while the flag is
> checked after the page fault has been handled. If the flag is set
> then SIGBUS is triggered so any g-u-p user will get a error code.
> 
> This patch shouldn't have any visible effect at this moment because the
> OOM killer doesn't invoke oom reaper for tasks with mm shared with
> kthreads yet.
> 
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/sched.h |  1 +
>  mm/memory.c           | 13 +++++++++++++
>  mm/oom_kill.c         |  8 ++++++++
>  3 files changed, 22 insertions(+)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index eda579f3283a..63acaf9cc51c 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -522,6 +522,7 @@ static inline int get_dumpable(struct mm_struct *mm)
>  #define MMF_HAS_UPROBES		19	/* has uprobes */
>  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
>  #define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
> +#define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
>  
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 83be99d9d8a1..5c1df34fef64 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3656,6 +3656,19 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>                          mem_cgroup_oom_synchronize(false);
>  	}
>  
> +	/*
> +	 * This mm has been already reaped by the oom reaper and so the
> +	 * refault cannot be trusted in general. Anonymous refaults would
> +	 * lose data and give a zero page instead e.g. This is especially
> +	 * problem for use_mm() because regular tasks will just die and
> +	 * the corrupted data will not be visible anywhere while kthread
> +	 * will outlive the oom victim and potentially propagate the date
> +	 * further.
> +	 */
> +	if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
> +				&& test_bit(MMF_UNSTABLE, &mm->flags)))
> +		ret = VM_FAULT_SIGBUS;
> +
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(handle_mm_fault);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3b990544db6d..5a3ba96c8338 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -495,6 +495,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  		goto unlock_oom;
>  	}
>  
> +	/*
> +	 * Tell all users of get_user/copy_from_user etc... that the content
> +	 * is no longer stable. No barriers really needed because unmapping
> +	 * should imply barriers already and the reader would hit a page fault
> +	 * if it stumbled over a reaped memory.
> +	 */
> +	set_bit(MMF_UNSTABLE, &mm->flags);
> +
>  	tlb_gather_mmu(&tlb, mm, 0, -1);
>  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>  		if (is_vm_hugetlb_page(vma))
> -- 
> 2.8.1

That's much better IMHO, and it's also much clearer why there's
no need for barriers here.

Acked-by: Michael S. Tsirkin <mst@redhat.com>



> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
