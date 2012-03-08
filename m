Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 4B6276B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:02:41 -0500 (EST)
Date: Thu, 8 Mar 2012 12:02:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, hugetlb: add thread name and pid to SHM_HUGETLB
 mlock rlimit warning
Message-Id: <20120308120238.c4486547.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203061825070.9015@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061825070.9015@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 6 Mar 2012 18:26:11 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> Add the thread name and pid of the application that is allocating shm
> segments with MAP_HUGETLB without being a part of
> /proc/sys/vm/hugetlb_shm_group or having CAP_IPC_LOCK.
> 
> This identifies the application so it may be fixed by avoiding using the
> deprecated exception (see Documentation/feature-removal-schedule.txt).
> 
> ...
>
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -946,7 +946,11 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
>  	if (creat_flags == HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
>  		*user = current_user();
>  		if (user_shm_lock(size, *user)) {
> -			printk_once(KERN_WARNING "Using mlock ulimits for SHM_HUGETLB is deprecated\n");
> +			task_lock(current);
> +			printk_once(KERN_WARNING
> +				"%s (%d): Using mlock ulimits for SHM_HUGETLB is deprecated\n",
> +				current->comm, current->pid);
> +			task_unlock(current);

I assume the task_lock() is there to protect current->comm.  If so, it
is unneeded - we're protecting against prctl(PR_SET_NAME), and
PR_SET_NAME only operates on current, and we know this task isn't
currently running PR_SET_NAME.

If there's a way for another task to alter this task's ->comm then we
_do_ need locking.  But there isn't a way, I hope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
