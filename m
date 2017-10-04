Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40B0D6B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 10:00:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y192so30705618pgd.0
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 07:00:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k69si6345977pgd.749.2017.10.04.07.00.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 07:00:36 -0700 (PDT)
Date: Wed, 4 Oct 2017 16:00:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Unify migrate_pages and move_pages access checks
Message-ID: <20171004140033.xmvszzezodjj6rly@dhcp22.suse.cz>
References: <alpine.DEB.2.11.1710011830320.6333@lakka.kapsi.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1710011830320.6333@lakka.kapsi.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Otto Ebeling <otto.ebeling@iki.fi>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>

On Sun 01-10-17 18:33:39, Otto Ebeling wrote:
> Commit 197e7e521384a23b9e585178f3f11c9fa08274b9 ("Sanitize 'move_pages()'
> permission checks") fixed a security issue I reported in the move_pages
> syscall, and made it so that you can't act on set-uid processes unless
> you have the CAP_SYS_PTRACE capability.
> 
> Unify the access check logic of migrate_pages to match the new
> behavior of move_pages. We discussed this a bit in the security@ list
> and thought it'd be good for consistency even though there's no evident
> security impact. The NUMA node access checks are left intact and require
> CAP_SYS_NICE as before.
> 
> Signed-off-by: Otto Ebeling <otto.ebeling@iki.fi>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mempolicy.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 006ba62..abfe469 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -98,6 +98,7 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/printk.h>
>  #include <linux/swapops.h>
> +#include <linux/ptrace.h>
> 
>  #include <asm/tlbflush.h>
>  #include <linux/uaccess.h>
> @@ -1365,7 +1366,6 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned
> long, maxnode,
>  		const unsigned long __user *, old_nodes,
>  		const unsigned long __user *, new_nodes)
>  {
> -	const struct cred *cred = current_cred(), *tcred;
>  	struct mm_struct *mm = NULL;
>  	struct task_struct *task;
>  	nodemask_t task_nodes;
> @@ -1402,14 +1402,9 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned
> long, maxnode,
> 
>  	/*
>  	 * Check if this process has the right to modify the specified
> -	 * process. The right exists if the process has administrative
> -	 * capabilities, superuser privileges or the same
> -	 * userid as the target process.
> +	 * process. Use the regular "ptrace_may_access()" checks.
>  	 */
> -	tcred = __task_cred(task);
> -	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, tcred->uid) &&
> -	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid, tcred->uid) &&
> -	    !capable(CAP_SYS_NICE)) {
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ_REALCREDS)) {
>  		rcu_read_unlock();
>  		err = -EPERM;
>  		goto out_put;
> -- 
> 2.1.4
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
