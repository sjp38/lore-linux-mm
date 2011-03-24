Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A2E5F8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 13:22:18 -0400 (EDT)
Date: Thu, 24 Mar 2011 18:13:19 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/5] x86,mm: make pagefault killable
Message-ID: <20110324171319.GA20182@redhat.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com> <20110322194721.B05E.A69D9226@jp.fujitsu.com> <20110322200945.B06D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322200945.B06D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 03/22, KOSAKI Motohiro wrote:
>
> This patch makes pagefault interruptible by SIGKILL.

Not a comment, but the question...

> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1035,6 +1035,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
>  	if (user_mode_vm(regs)) {
>  		local_irq_enable();
>  		error_code |= PF_USER;
> +		flags |= FAULT_FLAG_KILLABLE;

OK, this is clear.

I am wondering, can't we set FAULT_FLAG_KILLABLE unconditionally
but check PF_USER when we get VM_FAULT_RETRY? I mean,

	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
		if (!(error_code & PF_USER))
			no_context(...);
		return;
	}


Probably not... but I can't find any example of in-kernel fault which
can be broken by -EFAULT if current was killed.

mm_release()->put_user(clear_child_tid) should be fine...

Just curious, I feel I missed something obvious.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
