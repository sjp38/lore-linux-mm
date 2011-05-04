Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2BDF6B0024
	for <linux-mm@kvack.org>; Wed,  4 May 2011 19:55:21 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p44GM6WZ029902
	for <linux-mm@kvack.org>; Wed, 4 May 2011 10:22:06 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p44NtGFM150342
	for <linux-mm@kvack.org>; Wed, 4 May 2011 17:55:16 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p44HslOb009571
	for <linux-mm@kvack.org>; Wed, 4 May 2011 11:54:48 -0600
Subject: Re: [PATCH 3/3] comm: ext4: Protect task->comm access by using
 get_task_comm()
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <20110504163657.52dca3fc.akpm@linux-foundation.org>
References: <1303963411-2064-1-git-send-email-john.stultz@linaro.org>
	 <1303963411-2064-4-git-send-email-john.stultz@linaro.org>
	 <alpine.DEB.2.00.1104281426210.21665@chino.kir.corp.google.com>
	 <20110504163657.52dca3fc.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 May 2011 16:55:10 -0700
Message-ID: <1304553310.2943.18.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 2011-05-04 at 16:36 -0700, Andrew Morton wrote:
> On Thu, 28 Apr 2011 14:35:32 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Wed, 27 Apr 2011, John Stultz wrote:
> > 
> > > diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> > > index 7b80d54..d37414e 100644
> > > --- a/fs/ext4/file.c
> > > +++ b/fs/ext4/file.c
> > > @@ -124,11 +124,15 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
> > >  		static unsigned long unaligned_warn_time;
> > >  
> > >  		/* Warn about this once per day */
> > > -		if (printk_timed_ratelimit(&unaligned_warn_time, 60*60*24*HZ))
> > > +		if (printk_timed_ratelimit(&unaligned_warn_time, 60*60*24*HZ)) {
> > > +			char comm[TASK_COMM_LEN];
> > > +
> > > +			get_task_comm(comm, current);
> > >  			ext4_msg(inode->i_sb, KERN_WARNING,
> > >  				 "Unaligned AIO/DIO on inode %ld by %s; "
> > >  				 "performance will be poor.",
> > > -				 inode->i_ino, current->comm);
> > > +				 inode->i_ino, comm);
> > > +		}
> > >  		mutex_lock(ext4_aio_mutex(inode));
> > >  		ext4_aiodio_wait(inode);
> > >  	}
> > 
> > Thanks very much for looking into concurrent readers of current->comm, 
> > John!
> > 
> > This patch in the series demonstrates one of the problems with using 
> > get_task_comm(), however: we must allocate a 16-byte buffer on the stack 
> > and that could become risky if we don't know its current depth.  We may be 
> > particularly deep in the stack and then cause an overflow because of the 
> > 16 bytes.
> > 
> > I'm wondering if it would be better for ->comm to be protected by a 
> > spinlock (or rwlock) other than ->alloc_lock and then just require readers 
> > to take the lock prior to dereferencing it?  That's what is done in the 
> > oom killer with task_lock().  Perhaps you could introduce new 
> > task_comm_lock() and task_comm_unlock() to prevent the extra stack usage 
> > in over 300 locations within the kernel?
> 
> 16 bytes isn't all that much.  It's just two longs worth.
> 
> I'm suspecting that approximately 100% of the get_task_comm() callsites
> are using it for a printk, so how about we add a %p thingy for it then
> zap lots of code?

DaveH suggested the same, actually. And that would work with the
seqlocking pretty easily to avoid DavidR's issue.

> I read the changelogs and can't work out why a seqlock was added.  What
> was wrong with the task_lock()?

Sorry that wasn't clear, apparently its not always safe to grab the task
lock, as it might be held for other reasons. DavidR pointed out one such
case in Dave Hansen's "break out page allocation warning code" patch
(GFP_ATOMIC allocation).

Further, task_lock doesn't disable irqs, and there may be cases where we
access current->comm from irq context. Introducing a new seqlock
(disabling irqs on the comm write path) allows us to be sure we won't
hit such an issue when mass converting current->comm accessors.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
