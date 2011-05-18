Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B5E306B0027
	for <linux-mm@kvack.org>; Wed, 18 May 2011 00:11:48 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4I48oRd020622
	for <linux-mm@kvack.org>; Tue, 17 May 2011 22:08:50 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4I4Belv360636
	for <linux-mm@kvack.org>; Tue, 17 May 2011 22:11:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4HMBCNw013205
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:11:13 -0600
Subject: Re: [PATCH 1/4] comm: Introduce comm_lock spinlock to protect
 task->comm access
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <4DD3287A.2030808@jp.fujitsu.com>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
	 <1305682865-27111-2-git-send-email-john.stultz@linaro.org>
	 <4DD3287A.2030808@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 May 2011 21:11:36 -0700
Message-ID: <1305691896.2915.136.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, joe@perches.com, mingo@elte.hu, mina86@mina86.com, apw@canonical.com, jirislaby@gmail.com, rientjes@google.com, dave@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, 2011-05-18 at 11:01 +0900, KOSAKI Motohiro wrote:
> > diff --git a/fs/exec.c b/fs/exec.c
> > index 5e62d26..34fa611 100644
> > --- a/fs/exec.c
> > +++ b/fs/exec.c
> > @@ -998,17 +998,28 @@ static void flush_old_files(struct files_struct * files)
> > 
> >   char *get_task_comm(char *buf, struct task_struct *tsk)
> >   {
> > -	/* buf must be at least sizeof(tsk->comm) in size */
> > -	task_lock(tsk);
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&tsk->comm_lock, flags);
> >   	strncpy(buf, tsk->comm, sizeof(tsk->comm));
> > -	task_unlock(tsk);
> > +	spin_unlock_irqrestore(&tsk->comm_lock, flags);
> >   	return buf;
> >   }
> > 
> >   void set_task_comm(struct task_struct *tsk, char *buf)
> >   {
> > +	unsigned long flags;
> > +
> > +	/*
> > +	 * XXX - Even though comm is protected by comm_lock,
> > +	 * we take the task_lock here to serialize against
> > +	 * current users that directly access comm.
> > +	 * Once those users are removed, we can drop the
> > +	 * task locking&  memsetting.
> > +	 */
> 
> If we provide __get_task_comm(), we can't remove memset() forever.

True enough. I'll fix that comment up then.

> 
> >   	task_lock(tsk);
> > +	spin_lock_irqsave(&tsk->comm_lock, flags);
> 
> This is strange order. task_lock() doesn't disable interrupt.

Strange order? Can you explain why you think that is? Having comm_lock
as an inner-most lock seems quite reasonable, given the limited nature
of what it protects.

> And, can you please document why we need interrupt disabling?

Since we might access current->comm from irq context. Where would you
like this documented? Just there in the code?

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
