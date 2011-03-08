Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A043A8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 08:51:13 -0500 (EST)
Date: Tue, 8 Mar 2011 14:42:33 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
Message-ID: <20110308134233.GA26884@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110303100030.B936.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On 03/03, KOSAKI Motohiro wrote:
>
> > By iterating over threads instead, it is possible to detect threads that
> > are exiting and nominate them for oom kill so they get access to memory
> > reserves.
>
> In fact, PF_EXITING is a sing of *THREAD* exiting, not process. Therefore
> PF_EXITING is not a sign of memory freeing in nearly future. If other
> CPUs don't try to free memory, prevent oom and waiting makes deadlock.

I agree. I don't understand this patch.

And. Instead of moving to for_each_mm() this patch moves the logic back,
to for_each_thread().

> Thus, I suggest to remove PF_EXITING check completely.

Again, this seems better to me but I do not really understand oom
killer's heuristic. Perhaps this check helps with some workloads.

I tried to avoid this discussion because I have nothing new to add,
and the previous discussion was painful. But since this patch was
merged into -mm,

> > @@ -324,7 +324,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> >  		 * the process of exiting and releasing its resources.
> >  		 * Otherwise we could get an easy OOM deadlock.
> >  		 */
> > -		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
> > +		if ((p->flags & PF_EXITING) && p->mm) {

The previous check was not perfect, we know this.

But with this patch applied, the simple program below disables oom-killer
completely. select_bad_process() can never succeed.

I think this patch should dropped. And another one,

	oom-skip-zombies-when-iterating-tasklist.patch

should be dropped as well. Add Andrey.

Oleg.

#include <unistd.h>
#include <signal.h>
#include <pthread.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
#include <assert.h>
#include <stdio.h>

void *tfunc(void* arg)
{
	pause();
}

int main(void)
{
	int pid = fork();

	if (!pid) {
		pthread_t thread;
		pthread_create(&thread, NULL, tfunc, NULL);
		pthread_create(&thread, NULL, tfunc, NULL);
		ptrace(PTRACE_TRACEME, 0,0,0);
		kill(getpid(), SIGSTOP);
		pthread_kill(thread, SIGQUIT);
		pause();
		return 0;
	}

	assert(wait(NULL) == pid);
	assert(ptrace(PTRACE_SETOPTIONS, pid, 0, PTRACE_O_TRACEEXIT) == 0);
	assert(ptrace(PTRACE_CONT, pid, 0, 0) == 0);
	wait(NULL);

	pause();

	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
