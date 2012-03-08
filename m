Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id F12CD6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:37:59 -0500 (EST)
Received: by iajr24 with SMTP id r24so1691222iaj.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 13:37:59 -0800 (PST)
Date: Thu, 8 Mar 2012 13:37:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, hugetlb: add thread name and pid to SHM_HUGETLB
 mlock rlimit warning
In-Reply-To: <20120308120238.c4486547.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1203081333300.23632@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061825070.9015@chino.kir.corp.google.com> <20120308120238.c4486547.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 8 Mar 2012, Andrew Morton wrote:

> > --- a/fs/hugetlbfs/inode.c
> > +++ b/fs/hugetlbfs/inode.c
> > @@ -946,7 +946,11 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
> >  	if (creat_flags == HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
> >  		*user = current_user();
> >  		if (user_shm_lock(size, *user)) {
> > -			printk_once(KERN_WARNING "Using mlock ulimits for SHM_HUGETLB is deprecated\n");
> > +			task_lock(current);
> > +			printk_once(KERN_WARNING
> > +				"%s (%d): Using mlock ulimits for SHM_HUGETLB is deprecated\n",
> > +				current->comm, current->pid);
> > +			task_unlock(current);
> 
> I assume the task_lock() is there to protect current->comm.

Yup.

> If so, it
> is unneeded - we're protecting against prctl(PR_SET_NAME), and
> PR_SET_NAME only operates on current, and we know this task isn't
> currently running PR_SET_NAME.
> 
> If there's a way for another task to alter this task's ->comm then we
> _do_ need locking.  But there isn't a way, I hope.
> 

I wish there wasn't as well, it would prevent a lot of the currently buggy 
reads to current->comm and allow us to avoid so many otherwise pointless 
task_lock()s.

This protects against /proc/pid/comm, which is writable by threads in the 
same thread group.  We have a get_task_comm() that does the task_lock() 
internally but requires a TASK_COMM_LEN buffer in the calling code.  It's 
just easier for the calling code to the task_lock() itself for a tiny 
little printk().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
