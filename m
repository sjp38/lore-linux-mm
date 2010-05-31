Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C3416B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 12:55:36 -0400 (EDT)
Date: Mon, 31 May 2010 18:43:54 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/5] oom: select_bad_process: PF_EXITING check should
	take ->mm into account
Message-ID: <20100531164354.GA9991@redhat.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com> <20100531183335.1846.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100531183335.1846.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Thanks a lot Kosaki for doing this!

I still can't find the time to play with this code :/

On 05/31, KOSAKI Motohiro wrote:
>
> select_bad_process() checks PF_EXITING to detect the task which is going
> to release its memory, but the logic is very wrong.
>
> 	- a single process P with the dead group leader disables
> 	  select_bad_process() completely, it will always return
> 	  ERR_PTR() while P can live forever
>
> 	- if the PF_EXITING task has already released its ->mm
> 	  it doesn't make sense to expect it is goiing to free
> 	  more memory (except task_struct/etc)
>
> Change the code to ignore the PF_EXITING tasks without ->mm.
>
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -287,7 +287,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  		 * the process of exiting and releasing its resources.
>  		 * Otherwise we could get an easy OOM deadlock.
>  		 */
> -		if (p->flags & PF_EXITING) {
> +		if ((p->flags & PF_EXITING) && p->mm) {

(strictly speaking, this change is needed after 3/5 which removes the
 top-level "if (!p->mm)" check in select_bad_process).


I'd like to add a note... with or without this, we have problems
with the coredump. A thread participating in the coredumping
(group-leader in this case) can have PF_EXITING && mm, but this doesn't
mean it is going to exit soon, and the dumper can use a lot more memory.

Otoh, if select_bad_process() chooses the thread which dumps the core,
SIGKILL can't stop it. This should be fixed in do_coredump() paths, this
is the long-standing problem.

And, as it was already discussed, we only check the group-leader here.
But I can't suggest something better.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
