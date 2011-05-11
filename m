Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ABB306B0024
	for <linux-mm@kvack.org>; Wed, 11 May 2011 17:03:17 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4BKkI7J017016
	for <linux-mm@kvack.org>; Wed, 11 May 2011 14:46:18 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p4BL35Dp143610
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:03:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4BF2b3r004554
	for <linux-mm@kvack.org>; Wed, 11 May 2011 09:02:38 -0600
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <BANLkTikXyqddLbQKyDYFrAwq9DamDj--AQ@mail.gmail.com>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	 <1305073386-4810-3-git-send-email-john.stultz@linaro.org>
	 <BANLkTikXyqddLbQKyDYFrAwq9DamDj--AQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 11 May 2011 14:02:56 -0700
Message-ID: <1305147776.2883.1.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, 2011-05-11 at 17:33 +0800, AmA(C)rico Wang wrote:
> On Wed, May 11, 2011 at 8:23 AM, John Stultz <john.stultz@linaro.org> wrote:
> > Acessing task->comm requires proper locking. However in the past
> > access to current->comm could be done without locking. This
> > is no longer the case, so all comm access needs to be done
> > while holding the comm_lock.
> >
> > In my attempt to clean up unprotected comm access, I've noticed
> > most comm access is done for printk output. To simpify correct
> > locking in these cases, I've introduced a new %ptc format,
> > which will safely print the corresponding task's comm.
> >
> > Example use:
> > printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
> >
> 
> Why do you hide current->comm behide printk?
> How is this better than printk("%s: ....", task_comm(current)) ?

So to properly access current->comm, you need to hold the task-lock (or
with my new patch set, the comm_lock). Rather then adding locking to all
the call sites that printk("%s ...", current->comm), I'm suggesting we
add a new %ptc method which will handle the locking for you.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
