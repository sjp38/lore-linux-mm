Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C21FD6B01BE
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 07:28:47 -0400 (EDT)
Date: Fri, 4 Jun 2010 13:27:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
Message-ID: <20100604112721.GA12582@redhat.com>
References: <20100602185812.4B5894A549@magilla.sf.frob.com> <20100602203827.GA29244@redhat.com> <20100604194635.72D3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100604194635.72D3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/04, KOSAKI Motohiro wrote:
>
> > ... to set TIF_MEMDIE which should be checked in elf_core_dump().
> >
> > Probably yes.
>
> Yep, probably. but can you please allow me additonal explanation?
>
> In multi threaded OOM case, we have two problematic routine, coredump
> and vmscan. Roland's idea can only solve the former.
>
> But I also interest vmscan quickly exit if OOM received.

Yes, agreed. See another email from me, MMF_ flags looks "obviously
useful" to me.

(I'd suggest you to add a note into the changelog, to explain
 that the new flag makes sense even without coredump problems).

> @@ -410,6 +409,8 @@ static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
>  	 */
>  	p->rt.time_slice = HZ;
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
> +	set_bit(MMF_OOM_KILLED, &p->mm->flags);
> +	task_unlock(p);

IIUC, it has find_lock_task() mm above and thus we can trust p->mm ?
(I am asking just in case, I lost the plot a bit).

Ack or Reviewed, whatever your prefer.

Very minor nit.

> @@ -2038,6 +2038,10 @@ static int elf_core_dump(struct coredump_params *cprm)
>                               page_cache_release(page);
>                       } else
>                               stop = !dump_seek(cprm->file, PAGE_SIZE);
> +
> +                     /* The task need to exit ASAP if received OOM. */
> +                     if (test_bit(MMF_OOM_KILLED, &current->mm->flags))
> +                             stop = 1;

Perhaps this check makes more sense at the start of the loop,
and there is no need to set "stop = 1" (this var is not visible
outside of "for (;;) {}" anyway). Cosmetic, up to you.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
