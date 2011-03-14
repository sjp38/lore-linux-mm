Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62EE78D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 20:09:40 -0400 (EDT)
Date: Sun, 13 Mar 2011 17:08:59 -0700
From: Kees Cook <kees.cook@canonical.com>
Subject: Re: [PATCH 11/12] proc: make check_mem_permission() return an
 mm_struct on success
Message-ID: <20110314000859.GF21770@outflux.net>
References: <1300045764-24168-1-git-send-email-wilsons@start.ca>
 <1300045764-24168-12-git-send-email-wilsons@start.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1300045764-24168-12-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Stephen,

On Sun, Mar 13, 2011 at 03:49:23PM -0400, Stephen Wilson wrote:
> This change allows us to take advantage of access_remote_vm(), which in turn
> eliminates a security issue with the mem_write() implementation.
> 
> The previous implementation of mem_write() was insecure since the target task
> could exec a setuid-root binary between the permission check and the actual
> write.  Holding a reference to the target mm_struct eliminates this
> vulnerability.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>
> ---
>  fs/proc/base.c |   58 ++++++++++++++++++++++++++++++++-----------------------
>  1 files changed, 34 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index f6b644f..2af83bd 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -858,22 +863,25 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
>  	char *page;
>  	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
>  	unsigned long dst = *ppos;
> +	struct mm_struct *mm;
>  
>  	copied = -ESRCH;
>  	if (!task)
>  		goto out_no_task;
>  
> -	if (check_mem_permission(task))
> -		goto out;
> +	mm = check_mem_permission(task);
> +	copied = PTR_ERR(mm);
> +	if (IS_ERR(mm))
> +		goto out_task;
>  
>  	copied = -EIO;
>  	if (file->private_data != (void *)((long)current->self_exec_id))
> -		goto out;
> +		goto out_mm;

The file->private_data test seems wrong to me. Is there a case were the mm
returned from check_mem_permission(task) can refer to something that is no
longer attached to task?

For example:
- pid 100 ptraces pid 200
- pid 100 opens /proc/200/mem
- pid 200 execs into something else

A read of that mem fd could, IIUC, read from the new pid 200 mm, but
only after passing check_mem_permission(task) again. This is stopped
by the private_data test. But should it, since check_mem_permission()
passed?

Even if it does mean to block it, it's insufficient since pid 200
could just exec u32 many times and align with the original private_data
value. What is that test trying to do? And I'm curious for both mem_write
as well as the existing mem_read use of the test, since I'd like to see
a general solution to the "invalidate /proc fds across exec" so we can
close CVE-2011-1020 for everything[1].

Associated with this, the drop of check_mem_permission(task) during the
mem_read loop implies that the mm is locked during that loop and seems to
reflect what you're saying ("Holding a reference to the target mm_struct
eliminates this vulnerability."), meaning there's no reason to recheck
permissions. Is that accurate?

Thanks,

-Kees

[1] https://lkml.org/lkml/2011/2/7/368

-- 
Kees Cook
Ubuntu Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
