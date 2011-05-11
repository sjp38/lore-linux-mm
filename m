Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 70FE06B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 21:16:07 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4B0rA9i014985
	for <linux-mm@kvack.org>; Tue, 10 May 2011 20:53:10 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4B1G5cW098498
	for <linux-mm@kvack.org>; Tue, 10 May 2011 21:16:05 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4ALFrmG015833
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:15:54 -0300
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <1305076246.2939.67.camel@work-vm>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	 <1305073386-4810-3-git-send-email-john.stultz@linaro.org>
	 <1305075090.19586.189.camel@Joe-Laptop>  <1305076246.2939.67.camel@work-vm>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 18:16:01 -0700
Message-ID: <1305076561.2939.72.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-10 at 18:10 -0700, John Stultz wrote:
> On Tue, 2011-05-10 at 17:51 -0700, Joe Perches wrote:
> > Could misuse of %ptc (not using current) cause system lockup?
> 
> It very well could. Although I don't see other %p options tring to
> handle invalid pointers. Any suggestions on how to best handle this?

And just to clarify on this point, I'm responding to if a invalid
pointer was provided, causing the dereference to go awry.

If a valid non-current task was provided, the locking should be ok as we
disable irqs while the write_seqlock is held in set_task_comm().

The only places this could cause a problem was if you tried to printk
with a %ptc while holding the task->comm_lock. However, the lock is only
shortly held in task_comm_string, and get_task_comm and set_task_comm.
So it is fairly easy to audit for correctness.

If there is some other situation you had in mind, please let me know.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
