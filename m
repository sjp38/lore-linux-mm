Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEE19000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:25:23 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3QL4vbJ013413
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:04:57 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3QLPJiq076734
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:25:19 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3QLPI5t014819
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:25:19 -0400
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <20110421103009.731B.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com>
	 <1303331695.2796.159.camel@work-vm>
	 <20110421103009.731B.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Apr 2011 14:25:15 -0700
Message-ID: <1303853115.2816.129.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-04-21 at 10:29 +0900, KOSAKI Motohiro wrote:
> And one correction.
> ------------------------------------------------------------------
> static ssize_t comm_write(struct file *file, const char __user *buf,
>                                 size_t count, loff_t *offset)
> {
>         struct inode *inode = file->f_path.dentry->d_inode;
>         struct task_struct *p;
>         char buffer[TASK_COMM_LEN];
> 
>         memset(buffer, 0, sizeof(buffer));
>         if (count > sizeof(buffer) - 1)
>                 count = sizeof(buffer) - 1;
>         if (copy_from_user(buffer, buf, count))
>                 return -EFAULT;
> 
>         p = get_proc_task(inode);
>         if (!p)
>                 return -ESRCH;
> 
>         if (same_thread_group(current, p))
>                 set_task_comm(p, buffer);
>         else
>                 count = -EINVAL;
> ------------------------------------------------------------------
> 
> This code doesn't have proper credential check. IOW, you forgot to
> pthread_setuid_np() case.

Sorry, could you expand on this a bit? Google isn't coming up with much
for pthread_setuid_np. Can a thread actually end up with different uid
then the process it is a member of?

Or is same_thread_group not really what I think it is? What would be a
better way to check that the two threads are members of the same
process?

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
