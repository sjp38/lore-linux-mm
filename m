Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 51A0B6B0012
	for <linux-mm@kvack.org>; Fri, 13 May 2011 14:28:05 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4DIKu2K021129
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:20:56 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4DIRxvZ159986
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:27:59 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4DCRWWP024914
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:27:32 -0600
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect
 task->comm access
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <4DCD1256.4070808@jp.fujitsu.com>
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
	 <1305241371-25276-2-git-send-email-john.stultz@linaro.org>
	 <4DCD1256.4070808@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 May 2011 11:27:56 -0700
Message-ID: <1305311276.2680.34.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 2011-05-13 at 20:13 +0900, KOSAKI Motohiro wrote:
> Hi
> 
> Sorry for the long delay.
> 
> >   char *get_task_comm(char *buf, struct task_struct *tsk)
> >   {
> > -	/* buf must be at least sizeof(tsk->comm) in size */
> > -	task_lock(tsk);
> > -	strncpy(buf, tsk->comm, sizeof(tsk->comm));
> > -	task_unlock(tsk);
> > +	unsigned long seq;
> > +
> > +	do {
> > +		seq = read_seqbegin(&tsk->comm_lock);
> > +
> > +		strncpy(buf, tsk->comm, sizeof(tsk->comm));
> > +
> > +	} while (read_seqretry(&tsk->comm_lock, seq));
> > +
> >   	return buf;
> >   }
> 
> Can you please explain why we should use seqlock? That said,
> we didn't use seqlock for /proc items. because, plenty seqlock
> write may makes readers busy wait. Then, if we don't have another
> protection, we give the local DoS attack way to attackers.

So you're saying that heavy write contention can cause reader
starvation? 

> task->comm is used for very fundamentally. then, I doubt we can
> assume write is enough rare. Why can't we use normal spinlock?

I think writes are likely to be fairly rare. Tasks can only name
themselves or sibling threads, so I'm not sure I see the risk here.

Mind going into more detail?

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
