Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C76C6B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 17:07:53 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a26-v6so3273712pgw.7
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 14:07:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20-v6sor3449501pga.284.2018.07.24.14.07.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 14:07:51 -0700 (PDT)
Date: Tue, 24 Jul 2018 14:07:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
In-Reply-To: <20180724141747.GP28386@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1807241405450.191477@chino.kir.corp.google.com>
References: <20180716115058.5559-1-mhocko@kernel.org> <20180720170902.d1137060c23802d55426aa03@linux-foundation.org> <20180724141747.GP28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, Leon Romanovsky <leonro@mellanox.com>

On Tue, 24 Jul 2018, Michal Hocko wrote:

> oom_reap_task_mm should return false when __oom_reap_task_mm return
> false. This is what my patch did but it seems this changed by
> http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-oom-remove-oom_lock-from-oom_reaper.patch
> so that one should be fixed.
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 104ef4a01a55..88657e018714 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -565,7 +565,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	/* failed to reap part of the address space. Try again later */
>  	if (!__oom_reap_task_mm(mm)) {
>  		up_read(&mm->mmap_sem);
> -		return true;
> +		return false;
>  	}
>  
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> 
> 
> On top of that the proposed cleanup looks as follows:
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 88657e018714..4e185a282b3d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -541,8 +541,16 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  	return ret;
>  }
>  
> +/*
> + * Reaps the address space of the give task.
> + *
> + * Returns true on success and false if none or part of the address space
> + * has been reclaimed and the caller should retry later.
> + */
>  static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  {
> +	bool ret = true;
> +
>  	if (!down_read_trylock(&mm->mmap_sem)) {
>  		trace_skip_task_reaping(tsk->pid);
>  		return false;
> @@ -555,28 +563,28 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 * down_write();up_write() cycle in exit_mmap().
>  	 */
>  	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
> -		up_read(&mm->mmap_sem);
>  		trace_skip_task_reaping(tsk->pid);
> -		return true;
> +		goto out_unlock;
>  	}
>  
>  	trace_start_task_reaping(tsk->pid);
>  
>  	/* failed to reap part of the address space. Try again later */
> -	if (!__oom_reap_task_mm(mm)) {
> -		up_read(&mm->mmap_sem);
> -		return false;
> -	}
> +	ret = __oom_reap_task_mm(mm);
> +	if (!ret)
> +		goto out_finish;
>  
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>  			task_pid_nr(tsk), tsk->comm,
>  			K(get_mm_counter(mm, MM_ANONPAGES)),
>  			K(get_mm_counter(mm, MM_FILEPAGES)),
>  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
> +out_finish:
> +	trace_finish_task_reaping(tsk->pid);
> +out_unlock:
>  	up_read(&mm->mmap_sem);
>  
> -	trace_finish_task_reaping(tsk->pid);
> -	return true;
> +	return ret;
>  }
>  
>  #define MAX_OOM_REAP_RETRIES 10

I think we still want to trace when reaping was skipped to know that the 
oom reaper will retry again later.



mm/oom_kill.c: clean up oom_reap_task_mm() fix

indicate reaping has been partially skipped so we can expect future skips 
or another start before finish.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -569,10 +569,12 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	trace_start_task_reaping(tsk->pid);
 
-	/* failed to reap part of the address space. Try again later */
 	ret = __oom_reap_task_mm(mm);
-	if (!ret)
+	if (!ret) {
+		/* Failed to reap part of the address space. Try again later */
+		trace_skip_task_reaping(tsk->pid);
 		goto out_finish;
+	}
 
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
