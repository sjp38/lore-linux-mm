Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id B99F76B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:57:53 -0400 (EDT)
Date: Tue, 19 Jun 2012 15:55:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch v2] mm, oom: do not schedule if current has been killed
Message-ID: <20120619135551.GA24542@redhat.com>
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On 06/18, David Rientjes wrote:
>
> This patch only schedules away from current if it does not have a pending
> kill,

Can't really comment this patch, just one note...

> -	if (killed && !test_thread_flag(TIF_MEMDIE))
> +	if (killed && !fatal_signal_pending(current) &&
> +		      !(current->flags & PF_EXITING))
>  		schedule_timeout_uninterruptible(1);

Perhaps

	if (killed && !(current->flags & PF_EXITING))
		schedule_timeout_killable(1);

makes more sense?

If fatal_signal_pending() == T then schedule_timeout_killable()
is nop, but unline uninterruptible_ it can be SIGKILL'ed.

But if you prefer to check fatal_signal_pending() I won't argue.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
