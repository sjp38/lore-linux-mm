Message-ID: <42C1C627.5040404@engr.sgi.com>
Date: Tue, 28 Jun 2005 16:50:31 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable
 for other purposes
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242311220.7971@graphe.net> <20050626023053.GA2871@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506251954470.26198@graphe.net> <20050626030925.GA4156@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506261928010.1679@graphe.net> <Pine.LNX.4.58.0506262121070.19755@ppc970.osdl.org> <Pine.LNX.4.62.0506262249080.4374@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0506262249080.4374@graphe.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

<snip>

>  
> Index: linux-2.6.12/kernel/power/process.c
> ===================================================================
> --- linux-2.6.12.orig/kernel/power/process.c	2005-06-27 05:20:15.000000000 +0000
> +++ linux-2.6.12/kernel/power/process.c	2005-06-27 05:22:00.000000000 +0000

<snip>

> @@ -69,12 +63,12 @@ int freeze_processes(void)
>  			unsigned long flags;
>  			if (!freezeable(p))
>  				continue;
> -			if ((frozen(p)) ||
> +			if ((p->flags & PF_FROZEN) ||
>  			    (p->state == TASK_TRACED) ||
>  			    (p->state == TASK_STOPPED))
>  				continue;
>  
> -			freeze(p);
> +			set_thread_flag(TIF_FREEZE);

Shouldn't that be "set_ti_thread_flag(p->thread_info, TIF_FREEZE)"?
Otherwise you freeze current, not the thread "p".

>  			spin_lock_irqsave(&p->sighand->siglock, flags);
>  			signal_wake_up(p, 0);
>  			spin_unlock_irqrestore(&p->sighand->siglock, flags);
>

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
