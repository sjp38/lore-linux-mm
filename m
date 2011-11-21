Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 498726B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 17:38:57 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v4] PM / Memory-hotplug: Avoid task freezing failures
Date: Mon, 21 Nov 2011 23:41:39 +0100
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com> <4ECA94A6.90500@linux.vnet.ibm.com> <20111121182319.GG15314@google.com>
In-Reply-To: <20111121182319.GG15314@google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201111212341.39359.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Chen Gong <gong.chen@linux.intel.com>

On Monday, November 21, 2011, Tejun Heo wrote:
> On Mon, Nov 21, 2011 at 11:42:54PM +0530, Srivatsa S. Bhat wrote:
> > The lock_system_sleep() function is used in the memory hotplug code at
> > several places in order to implement mutual exclusion with hibernation.
> > However, this function tries to acquire the 'pm_mutex' lock using
> > mutex_lock() and hence blocks in TASK_UNINTERRUPTIBLE state if it doesn't
> > get the lock. This would lead to task freezing failures and hence
> > hibernation failure as a consequence, even though the hibernation call path
> > successfully acquired the lock.
> > 
> > But it is to be noted that, since this task tries to acquire pm_mutex, if it
> > blocks due to this, we are *100% sure* that this task is not going to run
> > as long as hibernation sequence is in progress, since hibernation releases
> > 'pm_mutex' only at the very end, when everything is done.
> > And this means, this task is going to be anyway blocked for much more longer
> > than what the freezer intends to achieve; which means, freezing and thawing
> > doesn't really make any difference to this task!
> > 
> > So, to fix freezing failures, we just ask the freezer to skip freezing this
> > task, since it is already "frozen enough".
> > 
> > But instead of calling freezer_do_not_count() and freezer_count() as it is,
> > we use only the relevant parts of those functions, because restrictions
> > such as 'the task should be a userspace one' etc., might not be relevant in
> > this scenario.
> > 
> > v4: Redesigned the whole fix, to ask the freezer to skip freezing the task
> >     which is blocked trying to acquire 'pm_mutex' lock.
> > 
> > v3: Tejun suggested avoiding busy-looping by adding an msleep() since
> >     it is not guaranteed that we will get frozen immediately.
> > 
> > v2: Tejun pointed problems with using mutex_lock_interruptible() in a
> >     while loop, when signals not related to freezing are involved.
> >     So, replaced it with mutex_trylock().
> > 
> > Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> 
> Thanks a lot. :)

Applied to linux-pm/linux-next.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
