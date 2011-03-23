Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6918D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 03:56:21 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CF3F03EE0BD
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:56:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B117345DE56
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:56:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9711C45DE51
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:56:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 81358E78002
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:56:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AE991DB8037
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:56:18 +0900 (JST)
Date: Wed, 23 Mar 2011 16:49:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] x86,mm: make pagefault killable
Message-Id: <20110323164949.5be6aa48.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110322200945.B06D.A69D9226@jp.fujitsu.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
	<20110322194721.B05E.A69D9226@jp.fujitsu.com>
	<20110322200945.B06D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>

On Tue, 22 Mar 2011 20:09:29 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> When oom killer occured, almost processes are getting stuck following
> two points.
> 
> 	1) __alloc_pages_nodemask
> 	2) __lock_page_or_retry
> 
> 1) is not much problematic because TIF_MEMDIE lead to make allocation
> failure and get out from page allocator. 2) is more problematic. When
> OOM situation, Zones typically don't have page cache at all and Memory
> starvation might lead to reduce IO performance largely. When fork bomb
> occur, TIF_MEMDIE task don't die quickly mean fork bomb may create
> new process quickly rather than oom-killer kill it. Then, the system
> may become livelock.
> 
> This patch makes pagefault interruptible by SIGKILL.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  arch/x86/mm/fault.c |    9 +++++++++
>  include/linux/mm.h  |    1 +
>  mm/filemap.c        |   22 +++++++++++++++++-----
>  3 files changed, 27 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 20e3f87..797c7d0 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1035,6 +1035,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
>  	if (user_mode_vm(regs)) {
>  		local_irq_enable();
>  		error_code |= PF_USER;
> +		flags |= FAULT_FLAG_KILLABLE;
>  	} else {
>  		if (regs->flags & X86_EFLAGS_IF)
>  			local_irq_enable();
> @@ -1138,6 +1139,14 @@ good_area:
>  	}
>  
>  	/*
> +	 * Pagefault was interrupted by SIGKILL. We have no reason to
> +	 * continue pagefault.
> +	 */
> +	if ((flags & FAULT_FLAG_KILLABLE) && (fault & VM_FAULT_RETRY) &&
> +	    fatal_signal_pending(current))
> +		return;
> +

Hmm? up_read(&mm->mmap_sem) ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
