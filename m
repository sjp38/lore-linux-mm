Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D6B748D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:29:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CC2FF3EE0BC
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 10:29:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AFD4B45DE96
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 10:29:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E19745DE92
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 10:29:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FD5BE08002
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 10:29:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 381311DB8038
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 10:29:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303331695.2796.159.camel@work-vm>
References: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com> <1303331695.2796.159.camel@work-vm>
Message-Id: <20110421103009.731B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 21 Apr 2011 10:29:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john stultz <johnstul@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

> On Wed, 2011-04-20 at 13:24 -0700, David Rientjes wrote:
> > On Wed, 20 Apr 2011, KOSAKI Motohiro wrote:
> > 
> > > > That was true a while ago, but you now need to protect every thread's 
> > > > ->comm with get_task_comm() or ensuring task_lock() is held to protect 
> > > > against /proc/pid/comm which can change other thread's ->comm.  That was 
> > > > different before when prctl(PR_SET_NAME) would only operate on current, so 
> > > > no lock was needed when reading current->comm.
> > > 
> > > Right. /proc/pid/comm is evil. We have to fix it. otherwise we need change
> > > all of current->comm user. It's very lots!
> > > 
> > 
> > Fixing it in this case would be removing it and only allowing it for 
> > current via the usual prctl() :)  The code was introduced in 4614a696bd1c 
> > (procfs: allow threads to rename siblings via /proc/pid/tasks/tid/comm) in 
> > December 2009 and seems to originally be meant for debugging.  We simply 
> > can't continue to let it modify any thread's ->comm unless we change the 
> > over 300 current->comm deferences in the kernel.
> > 
> > I'd prefer that we remove /proc/pid/comm entirely or at least prevent 
> > writing to it unless CONFIG_EXPERT.
> 
> Eeeh. That's probably going to be a tough sell, as I think there is
> wider interest in what it provides. Its useful for debugging
> applications not kernels, so I doubt folks will want to rebuild their
> kernel to try to analyze a java issue.
> 
> So I'm well aware that there is the chance that you catch the race and
> read an incomplete/invalid comm (it was discussed at length when the
> change went in), but somewhere I've missed how that's causing actual
> problems. Other then just being "evil" and having the documented race,
> could you clarify what the issue is that your hitting?

The problem is, there is no documented as well. Okay, I recognized you
introduced new locking rule for task->comm. But there is no documented
it. Thus, We have no way to review current callsites are correct or not.
Can you please do it? And, I have a question. Do you mean now task->comm
reader don't need task_lock() even if it is another thread?

_if_ every task->comm reader have to realize it has a chance to read
incomplete/invalid comm, task_lock() doesn't makes any help.



And one correction.
------------------------------------------------------------------
static ssize_t comm_write(struct file *file, const char __user *buf,
                                size_t count, loff_t *offset)
{
        struct inode *inode = file->f_path.dentry->d_inode;
        struct task_struct *p;
        char buffer[TASK_COMM_LEN];

        memset(buffer, 0, sizeof(buffer));
        if (count > sizeof(buffer) - 1)
                count = sizeof(buffer) - 1;
        if (copy_from_user(buffer, buf, count))
                return -EFAULT;

        p = get_proc_task(inode);
        if (!p)
                return -ESRCH;

        if (same_thread_group(current, p))
                set_task_comm(p, buffer);
        else
                count = -EINVAL;
------------------------------------------------------------------

This code doesn't have proper credential check. IOW, you forgot to
pthread_setuid_np() case.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
