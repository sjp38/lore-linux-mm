Date: Sun, 20 May 2007 20:31:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] limit print_fatal_signal() rate (was: [RFC] log
 out-of-virtual-memory events)
Message-Id: <20070520203123.5cde3224.akpm@linux-foundation.org>
In-Reply-To: <464ED258.2010903@users.sourceforge.net>
References: <E1Hp5PV-0001Bn-00@calista.eckenfels.net>
	<464ED258.2010903@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righiandr@users.sourceforge.net
Cc: Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2007 12:33:04 +0200 (MEST) Andrea Righi <righiandr@users.sourceforge.net> wrote:

> Bernd Eckenfels wrote:
> > In article <464DCEAB.3090905@users.sourceforge.net> you wrote:
> >>        printk("%s/%d: potentially unexpected fatal signal %d.\n",
> >>                current->comm, current->pid, signr);
> > 
> > can we have both KERN_WARNING please?
> > 
> > Gruss
> > Bernd
> 
> Depends on print_fatal_signals patch.
> 
> ---
> 
> Limit the rate of print_fatal_signal() to avoid potential denial-of-service
> attacks.
> 
> Signed-off-by: Andrea Righi <a.righi@cineca.it>
> 
> diff -urpN linux-2.6.22-rc1-mm1/kernel/signal.c linux-2.6.22-rc1-mm1-vm-log-enomem/kernel/signal.c
> --- linux-2.6.22-rc1-mm1/kernel/signal.c	2007-05-19 11:25:24.000000000 +0200
> +++ linux-2.6.22-rc1-mm1-vm-log-enomem/kernel/signal.c	2007-05-19 11:30:00.000000000 +0200
> @@ -790,7 +790,10 @@ static void print_vmas(void)
>  
>  static void print_fatal_signal(struct pt_regs *regs, int signr)
>  {
> -	printk("%s/%d: potentially unexpected fatal signal %d.\n",
> +	if (unlikely(!printk_ratelimit()))
> +		return;
> +
> +	printk(KERN_WARNING "%s/%d: potentially unexpected fatal signal %d.\n",
>  		current->comm, current->pid, signr);
>  
>  #ifdef __i386__

Well OK.  But vdso-print-fatal-signals.patch is designated not-for-mainline
anyway.

I think the DoS which you identify has been available for a very long time
on ia64, x86_64 and perhaps others.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
