Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 552046B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 16:11:09 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so6618845pbc.1
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 13:11:08 -0700 (PDT)
Date: Mon, 9 Sep 2013 13:11:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] OOM killer: wait for tasks with pending SIGKILL to
 exit
In-Reply-To: <20130909163109.GA9334@redhat.com>
Message-ID: <alpine.DEB.2.02.1309091307170.12523@chino.kir.corp.google.com>
References: <1378740624-2456-1-git-send-email-dserrg@gmail.com> <20130909163109.GA9334@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Sergey Dyasly <dserrg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rusty Russell <rusty@rustcorp.com.au>, Sha Zhengju <handai.szj@taobao.com>

On Mon, 9 Sep 2013, Oleg Nesterov wrote:

> > @@ -275,13 +275,16 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
> >  	if (oom_task_origin(task))
> >  		return OOM_SCAN_SELECT;
> >  
> > -	if (task->flags & PF_EXITING && !force_kill) {
> > +	if ((task->flags & PF_EXITING || fatal_signal_pending(task)) &&
> > +	    !force_kill) {
> >  		/*
> >  		 * If this task is not being ptraced on exit, then wait for it
> >  		 * to finish before killing some other task unnecessarily.
> >  		 */
> > -		if (!(task->group_leader->ptrace & PT_TRACE_EXIT))
> > +		if (!(task->group_leader->ptrace & PT_TRACE_EXIT)) {
> 
> can't we finally kill (or fix?) this PT_TRACE_EXIT check?
> 

Patches are always welcome.

> It was added to fix the exploit I sent. But the patch was wrong,
> that exploit could be easily modified to trigger the same problem.
> 

If the patch prevented your exploit when coredumping was done differently 
then it was not wrong.  It may not have been as inclusive as you would 
have liked, but then again you never proposed any kernel changes to fix it 
yourself either.

> However, now that the coredumping is killable that exploit won't
> work, so the original reason has gone away.
> 
> So why do we need this check today?
> 

If you feel it can be removed, please propose a patch to do so with a 
changelog that describes why it is no longer necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
