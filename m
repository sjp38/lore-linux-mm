Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDFD56B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:50:35 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so12271826lff.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:50:35 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id r200si18449lff.313.2016.10.18.06.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 06:50:34 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id l131so3029465lfl.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:50:33 -0700 (PDT)
Date: Tue, 18 Oct 2016 15:50:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
 ptrace_may_access
Message-ID: <20161018135031.GB13117@dhcp22.suse.cz>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87twcbq696.fsf@x220.int.ebiederm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-kernel@vger.kernel.org

On Mon 17-10-16 11:39:49, Eric W. Biederman wrote:
> 
> During exec dumpable is cleared if the file that is being executed is
> not readable by the user executing the file.  A bug in
> ptrace_may_access allows reading the file if the executable happens to
> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
> 
> This problem is fixed with only necessary userspace breakage by adding
> a user namespace owner to mm_struct, captured at the time of exec,
> so it is clear in which user namespace CAP_SYS_PTRACE must be present
> in to be able to safely give read permission to the executable.
> 
> The function ptrace_may_access is modified to verify that the ptracer
> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
> This ensures that if the task changes it's cred into a subordinate
> user namespace it does not become ptraceable.

I haven't studied your patch too deeply but one thing that immediately 
raised a red flag was that mm might be shared between processes (aka
thread groups). What prevents those two to sit in different user
namespaces?

I am primarily asking because this generated a lot of headache for the
memcg handling as those processes might sit in different cgroups while
there is only one correct memcg for them which can disagree with the
cgroup associated with one of the processes.

> Cc: stable@vger.kernel.org
> Fixes: 8409cca70561 ("userns: allow ptrace from non-init user namespaces")
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
> 
> It turns out that dumpable needs to be fixed to be user namespace
> aware to fix this issue.  When this patch is ready I plan to place it in
> my userns tree and send it to Linus, hopefully for -rc2.
> 
>  include/linux/mm_types.h |  1 +
>  kernel/fork.c            |  9 ++++++---
>  kernel/ptrace.c          | 17 ++++++-----------
>  mm/init-mm.c             |  2 ++
>  4 files changed, 15 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 4a8acedf4b7d..08d947fc4c59 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -473,6 +473,7 @@ struct mm_struct {
>  	 */
>  	struct task_struct __rcu *owner;
>  #endif
> +	struct user_namespace *user_ns;
>  
>  	/* store ref to file /proc/<pid>/exe symlink points to */
>  	struct file __rcu *exe_file;
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 623259fc794d..fd85c68c2791 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -742,7 +742,8 @@ static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
>  #endif
>  }
>  
> -static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
> +static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
> +	struct user_namespace *user_ns)
>  {
>  	mm->mmap = NULL;
>  	mm->mm_rb = RB_ROOT;
> @@ -782,6 +783,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
>  	if (init_new_context(p, mm))
>  		goto fail_nocontext;
>  
> +	mm->user_ns = get_user_ns(user_ns);
>  	return mm;
>  
>  fail_nocontext:
> @@ -827,7 +829,7 @@ struct mm_struct *mm_alloc(void)
>  		return NULL;
>  
>  	memset(mm, 0, sizeof(*mm));
> -	return mm_init(mm, current);
> +	return mm_init(mm, current, current_user_ns());
>  }
>  
>  /*
> @@ -842,6 +844,7 @@ void __mmdrop(struct mm_struct *mm)
>  	destroy_context(mm);
>  	mmu_notifier_mm_destroy(mm);
>  	check_mm(mm);
> +	put_user_ns(mm->user_ns);
>  	free_mm(mm);
>  }
>  EXPORT_SYMBOL_GPL(__mmdrop);
> @@ -1123,7 +1126,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
>  
>  	memcpy(mm, oldmm, sizeof(*mm));
>  
> -	if (!mm_init(mm, tsk))
> +	if (!mm_init(mm, tsk, mm->user_ns))
>  		goto fail_nomem;
>  
>  	err = dup_mmap(mm, oldmm);
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 2a99027312a6..f2d1b9afb3f8 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -220,7 +220,7 @@ static int ptrace_has_cap(struct user_namespace *ns, unsigned int mode)
>  static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
>  {
>  	const struct cred *cred = current_cred(), *tcred;
> -	int dumpable = 0;
> +	struct mm_struct *mm;
>  	kuid_t caller_uid;
>  	kgid_t caller_gid;
>  
> @@ -271,16 +271,11 @@ static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
>  	return -EPERM;
>  ok:
>  	rcu_read_unlock();
> -	smp_rmb();
> -	if (task->mm)
> -		dumpable = get_dumpable(task->mm);
> -	rcu_read_lock();
> -	if (dumpable != SUID_DUMP_USER &&
> -	    !ptrace_has_cap(__task_cred(task)->user_ns, mode)) {
> -		rcu_read_unlock();
> -		return -EPERM;
> -	}
> -	rcu_read_unlock();
> +	mm = task->mm;
> +	if (!mm ||
> +	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
> +	     !ptrace_has_cap(mm->user_ns, mode)))
> +	    return -EPERM;
>  
>  	return security_ptrace_access_check(task, mode);
>  }
> diff --git a/mm/init-mm.c b/mm/init-mm.c
> index a56a851908d2..975e49f00f34 100644
> --- a/mm/init-mm.c
> +++ b/mm/init-mm.c
> @@ -6,6 +6,7 @@
>  #include <linux/cpumask.h>
>  
>  #include <linux/atomic.h>
> +#include <linux/user_namespace.h>
>  #include <asm/pgtable.h>
>  #include <asm/mmu.h>
>  
> @@ -21,5 +22,6 @@ struct mm_struct init_mm = {
>  	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
>  	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
>  	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
> +	.user_ns	= &init_user_ns,
>  	INIT_MM_CONTEXT(init_mm)
>  };
> -- 
> 2.8.3
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
