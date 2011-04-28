Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8655B6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 23:05:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 491D43EE0C2
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:05:44 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2919B45DE67
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:05:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1126245DE4E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:05:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 054D31DB803C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:05:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF8EE1DB802C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:05:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303853115.2816.129.camel@work-vm>
References: <20110421103009.731B.A69D9226@jp.fujitsu.com> <1303853115.2816.129.camel@work-vm>
Message-Id: <20110428120736.D193.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 28 Apr 2011 12:05:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john stultz <johnstul@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

> On Thu, 2011-04-21 at 10:29 +0900, KOSAKI Motohiro wrote:
> > And one correction.
> > ------------------------------------------------------------------
> > static ssize_t comm_write(struct file *file, const char __user *buf,
> >                                 size_t count, loff_t *offset)
> > {
> >         struct inode *inode = file->f_path.dentry->d_inode;
> >         struct task_struct *p;
> >         char buffer[TASK_COMM_LEN];
> > 
> >         memset(buffer, 0, sizeof(buffer));
> >         if (count > sizeof(buffer) - 1)
> >                 count = sizeof(buffer) - 1;
> >         if (copy_from_user(buffer, buf, count))
> >                 return -EFAULT;
> > 
> >         p = get_proc_task(inode);
> >         if (!p)
> >                 return -ESRCH;
> > 
> >         if (same_thread_group(current, p))
> >                 set_task_comm(p, buffer);
> >         else
> >                 count = -EINVAL;
> > ------------------------------------------------------------------
> > 
> > This code doesn't have proper credential check. IOW, you forgot to
> > pthread_setuid_np() case.
> 
> Sorry, could you expand on this a bit? Google isn't coming up with much
> for pthread_setuid_np. Can a thread actually end up with different uid
> then the process it is a member of?

Yes. Linux kernel _always_ only care per-thread uid.
glibc 2.3.3 or earlier, it use kernel syscall straight forward. and then
userland application also don't have a way to change per-process uid.

glbc 2.3.4 or later, glibc implement per-process setuid by using signal
for inter thread communication. (ie, every thread call setuid() syscall
internally). Hm, currently pthread_setuid_np don't have proper exported
header file. so, parpaps, we need to only worry about syscall(NR_uid) and
old libc?

Anyway, If you see task_struct definition, you can easily find it has
cred.

Thanks.

> 
> Or is same_thread_group not really what I think it is? What would be a
> better way to check that the two threads are members of the same
> process?
> 
> thanks
> -john
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
