Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 44A4E8D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:49:05 -0400 (EDT)
Date: Mon, 14 Mar 2011 18:40:19 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch -mm] oom: avoid deferring oom killer if exiting task is
	being traced
Message-ID: <20110314174019.GA14328@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <alpine.DEB.2.00.1103121709230.10317@chino.kir.corp.google.com> <alpine.DEB.2.00.1103121715030.10317@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103121715030.10317@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On 03/12, David Rientjes wrote:
>
> The oom killer naturally defers killing anything if it finds an eligible
> task that is already exiting and has yet to detach its ->mm.  This avoids
> unnecessarily killing tasks when one is already in the exit path and may
> free enough memory that the oom killer is no longer needed.  This is
> detected by PF_EXITING since threads that have already detached its ->mm
> are no longer considered at all.

So, this is on top of oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch

I still can't understand which problems that patch tries to solve. Could
you explain why this patch helps in details?

Speaking of "already exiting and has yet to detach its ->mm", did you look
at "[PATCH 2/3] oom: select_bad_process: improve the PF_EXITING check" ?

> The problem with always deferring when a thread is PF_EXITING, however,
> is that it may never actually exit when being traced, specifically if
> another task is tracing it with PTRACE_O_TRACEEXIT.  The oom killer does
> not want to defer in this case since there is no guarantee that thread
> will ever exit without intervention.

IOW, you are trying to fight with the test-case I sent,

> +			} else {
> +				/*
> +				 * If this task is not being ptraced on exit,
> +				 * then wait for it to finish before killing
> +				 * some other task unnecessarily.
> +				 */
> +				if (!(task_ptrace(p->group_leader) &
> +							PT_TRACE_EXIT))
> +					return ERR_PTR(-1UL);

No, this can't help afaics. It is trivial to change the exploit and
get the same result.

Perhaps I missed something, I didn't read this patch carefully. Will
try to do later.

However. could you please answer my question above?


Also. We have the serious and easily exploitable bugs, I think we
should fix them first. I'll report more details later today.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
