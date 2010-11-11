Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C40126B0085
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 07:36:26 -0500 (EST)
Date: Thu, 11 Nov 2010 13:30:15 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: INFO: suspicious rcu_dereference_check() usage -
	kernel/pid.c:419 invoked rcu_dereference_check() without protection!
Message-ID: <20101111123015.GA25991@redhat.com>
References: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com> <20101107182028.GZ15561@linux.vnet.ibm.com> <20101108151509.GA3702@redhat.com> <20101109202900.GV4032@linux.vnet.ibm.com> <20101110155530.GA1905@redhat.com> <20101110160211.GA2562@redhat.com> <4CDBD12C.4010807@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CDBD12C.4010807@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <axboe@kernel.dk>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/11, Jens Axboe wrote:
>
> On 2010-11-10 17:02, Oleg Nesterov wrote:
> >
> > But wait. Whatever we do, isn't this code racy? I do not see why, say,
> > sys_ioprio_set(IOPRIO_WHO_PROCESS) can't install ->io_context after
> > this task has already passed exit_io_context().
> >
> > Jens, am I missed something?
>
> Not sure, I think the original intent was for the tasklist_lock to
> protect from a concurrent exit, but that looks like nonsense and it was
> just there to protect the task lookup.

Probably. After that (perhaps) there was another reason, see

	5b160f5e "copy_process: cosmetic ->ioprio tweak"
	cf342e52 "Don't need to disable interrupts for tasklist_lock"

But this was dismissed by

	fd0928df "ioprio: move io priority from task_struct to io_context"

> How about moving the ->io_context check and exit_io_context() in
> do_exit() under the task lock? Coupled with a check for PF_EXITING in
> set_task_ioprio().

Yes, I thought about this too. The only drawback is that we should
take task_lock() unconditionally in exit_io_context().

Btw, in theory get_task_ioprio() is racy too. "ret = p->io_context->ioprio"
can lead to use-after-free. Probably needs task_lock() as well.

Hmm. And copy_io_context() has no callers ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
