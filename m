Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id E4D786B00AE
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 21:04:08 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u56so6058680wes.28
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 18:04:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gt4si24997935wib.64.2014.06.02.18.04.06
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 18:04:07 -0700 (PDT)
Message-ID: <538d1f07.646ab40a.0e42.ffffc429SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] mm/memory-failure.c: support dedicated thread to handle SIGBUS(BUS_MCEERR_AO)
Date: Mon,  2 Jun 2014 21:03:34 -0400
In-Reply-To: <20140602154207.7e55a16c9038016cd080c176@linux-foundation.org>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com> <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401432670-24664-4-git-send-email-n-horiguchi@ah.jp.nec.com> <20140602154207.7e55a16c9038016cd080c176@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 03:42:07PM -0700, Andrew Morton wrote:
> On Fri, 30 May 2014 02:51:10 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Currently memory error handler handles action optional errors in the deferred
> > manner by default. And if a recovery aware application wants to handle it
> > immediately, it can do it by setting PF_MCE_EARLY flag. However, such signal
> > can be sent only to the main thread, so it's problematic if the application
> > wants to have a dedicated thread to handler such signals.
> > 
> > So this patch adds dedicated thread support to memory error handler. We have
> > PF_MCE_EARLY flags for each thread separately, so with this patch AO signal
> > is sent to the thread with PF_MCE_EARLY flag set, not the main thread. If
> > you want to implement a dedicated thread, you call prctl() to set PF_MCE_EARLY
> > on the thread.
> > 
> > Memory error handler collects processes to be killed, so this patch lets it
> > check PF_MCE_EARLY flag on each thread in the collecting routines.
> > 
> > No behavioral change for all non-early kill cases.
> > 
> > ...
> >
> > --- mmotm-2014-05-21-16-57.orig/mm/memory-failure.c
> > +++ mmotm-2014-05-21-16-57/mm/memory-failure.c
> > @@ -380,15 +380,44 @@ static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
> >  	}
> >  }
> >  
> > -static int task_early_kill(struct task_struct *tsk, int force_early)
> > +/*
> > + * Find a dedicated thread which is supposed to handle SIGBUS(BUS_MCEERR_AO)
> > + * on behalf of the thread group. Return task_struct of the (first found)
> > + * dedicated thread if found, and return NULL otherwise.
> > + */
> > +static struct task_struct *find_early_kill_thread(struct task_struct *tsk)
> > +{
> > +	struct task_struct *t;
> > +	rcu_read_lock();
> > +	for_each_thread(tsk, t)
> > +		if ((t->flags & PF_MCE_PROCESS) && (t->flags & PF_MCE_EARLY))
> > +			goto found;
> > +	t = NULL;
> > +found:
> > +	rcu_read_unlock();
> > +	return t;
> > +}
> > +
> > +/*
> > + * Determine whether a given process is "early kill" process which expects
> > + * to be signaled when some page under the process is hwpoisoned.
> > + * Return task_struct of the dedicated thread (main thread unless explicitly
> > + * specified) if the process is "early kill," and otherwise returns NULL.
> > + */
> > +static struct task_struct *task_early_kill(struct task_struct *tsk,
> > +					   int force_early)
> >  {
> > +	struct task_struct *t;
> >  	if (!tsk->mm)
> > -		return 0;
> > +		return NULL;
> >  	if (force_early)
> > -		return 1;
> > -	if (tsk->flags & PF_MCE_PROCESS)
> > -		return !!(tsk->flags & PF_MCE_EARLY);
> > -	return sysctl_memory_failure_early_kill;
> > +		return tsk;
> > +	t = find_early_kill_thread(tsk);
> > +	if (t)
> > +		return t;
> > +	if (sysctl_memory_failure_early_kill)
> > +		return tsk;
> > +	return NULL;
> >  }
> 
> The above two functions are to be called under
> read_lock(tasklist_lock), which is rather important...
> 
> Given this requirement, did find_early_kill_thread() need rcu_read_lock()?

Right, we don't need this rcu_read_lock(). The following hunk should fix it.

Thanks,
Naoya Horiguchi

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index b0f48e34dec5..6fdc9a2eeb2f 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -297,18 +297,17 @@ struct to_kill {
  * Find a dedicated thread which is supposed to handle SIGBUS(BUS_MCEERR_AO)
  * on behalf of the thread group. Return task_struct of the (first found)
  * dedicated thread if found, and return NULL otherwise.
+ *
+ * We already hold read_lock(&tasklist_lock) in the caller, so we don't
+ * have to call rcu_read_lock/unlock() in this function.
  */
 static struct task_struct *find_early_kill_thread(struct task_struct *tsk)
 {
 	struct task_struct *t;
-	rcu_read_lock();
 	for_each_thread(tsk, t)
 		if ((t->flags & PF_MCE_PROCESS) && (t->flags & PF_MCE_EARLY))
-			goto found;
-	t = NULL;
-found:
-	rcu_read_unlock();
-	return t;
+			return t;
+	return NULL;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
