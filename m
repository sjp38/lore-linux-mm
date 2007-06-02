Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l520dFEt008690
	for <linux-mm@kvack.org>; Fri, 1 Jun 2007 20:39:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l520hJtp259536
	for <linux-mm@kvack.org>; Fri, 1 Jun 2007 18:43:24 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l520hImQ020884
	for <linux-mm@kvack.org>; Fri, 1 Jun 2007 18:43:19 -0600
Subject: Re: [RFC][PATCH] Replacing the /proc/<pid|self>/exe symlink code
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20070601223156.GA22754@vino.hallyn.com>
References: <1180486369.11715.69.camel@localhost.localdomain>
	 <20070530180923.GA22345@vino.hallyn.com>
	 <1180634174.4738.48.camel@localhost.localdomain>
	 <20070601223156.GA22754@vino.hallyn.com>
Content-Type: text/plain
Date: Fri, 01 Jun 2007 17:42:49 -0700
Message-Id: <1180744969.6104.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-01 at 17:31 -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc@us.ibm.com):
> > On Wed, 2007-05-30 at 13:09 -0500, Serge E. Hallyn wrote:
> > > Quoting Matt Helsley (matthltc@us.ibm.com):
> > > > This patch avoids holding the mmap semaphore while walking VMAs in response to
> > > > programs which read or follow the /proc/<pid|self>/exe symlink. This also allows us
> > > > to merge mmu and nommu proc_exe_link() functions. The costs are holding a separate
> > > > reference to the executable file stored in the task struct and increased code in
> > > > fork, exec, and exit paths.
> > > > 
> > > > Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
> > > > ---
> > > > 
> > > > Compiled and passed simple tests for regressions when patched against a 2.6.20
> > > > and 2.6.22-rc2-mm1 kernel.
> > > > 
> > > >  fs/exec.c             |    5 +++--
> > > >  fs/proc/base.c        |   20 ++++++++++++++++++++
> > > >  fs/proc/internal.h    |    1 -
> > > >  fs/proc/task_mmu.c    |   34 ----------------------------------
> > > >  fs/proc/task_nommu.c  |   34 ----------------------------------
> > > >  include/linux/sched.h |    1 +
> > > >  kernel/exit.c         |    2 ++
> > > >  kernel/fork.c         |   10 +++++++++-
> > > >  8 files changed, 35 insertions(+), 72 deletions(-)
> > 
> > <snip>
> > 
> > > > Index: linux-2.6.22-rc2-mm1/kernel/exit.c
> > > > ===================================================================
> > > > --- linux-2.6.22-rc2-mm1.orig/kernel/exit.c
> > > > +++ linux-2.6.22-rc2-mm1/kernel/exit.c
> > > > @@ -924,10 +924,12 @@ fastcall void do_exit(long code)
> > > >  	if (unlikely(tsk->audit_context))
> > > >  		audit_free(tsk);
> > > >  
> > > >  	taskstats_exit(tsk, group_dead);
> > > >  
> > > > +	if (tsk->exe_file)
> > > > +		fput(tsk->exe_file);
> > > 
> > > Hi,
> > > 
> > > just taking a cursory look so I may be missing something, but doesn't
> > > this leave the possibility that right here, with tsk->exe_file being
> > > put, another task would try to look at tsk's /proc/tsk->pid/exe?
> > > 
> > > thanks,
> > > -serge
> > >
> > >       exit_mm(tsk);
> > >
> >   
> > <snip>
> > 
> > Good question. To be precise, I think the problem doesn't exist here but
> > after the exit_mm() because there's a VMA that holds a reference to the
> > same file.
> > 
> > The existing code appears to solve the race between
> > reading/following /proc/tsk->pid/exe and exit_mm() in the exit path by
> > returning -ENOENT for the case where there is no executable VMA with a
> > reference to the file backing it.
> > 
> > So I need to put NULL in the exe_file field and adjust the return value
> > to be -ENOENT instead of -ENOSYS.
> > 
> > Thanks for the review!
> 
> Ok, I had to think about this a bit, but so you're saying you set it to
> NULL in do_exit(), and anyone who has just dereferenced tsk->exe_file
> before the fput in do_exit() should be ok because the vma hasn't yet
> been put?

Yes

> Should the 
> 	if (!task->exe_file)
> 		goto out;
> 	*mnt = mntget(task->exe_file->f_path.mnt);
> 	*dentry = dget(task->exe_file->f_path.dentry);
> 
> also go inside an preempt_disable to prevent sleeping and maybe become

It needs some form of protection from concurrent access between write
and read. write happens during exec, fork, and exit. In the fork case
however it's not necessary because the new task isn't visible in /proc
yet and the value of current doesn't change anyway.

> 	exef = task->exe_file;  /* to prevent task->exe_file being set
> 			to NULL before we've grabbed the path */
> 	if (!exef)
> 		goto out;
> 	get_file(exef);  /* to prevent the mm somehow being put before
> 				we've grabbed the path? */
> 	*mnt = mntget(task->exe_file->f_path.mnt);
> 	*dentry = dget(task->exe_file->f_path.dentry);
> 	put_file(exef);  /* ? */
> 
> ?
> 
> Or am I being overly paranoid?

No, you're right. In fact, because readlink() can be initiated by
another task I think disabling preemption really only fixes the problem
on uniprocessor systems. So I was thinking of using task_lock() to
protect exe_file.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
