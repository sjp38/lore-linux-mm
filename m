Date: Fri, 4 Jul 2003 18:15:39 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.5.74-mm1
Message-Id: <20030704181539.2be0762a.akpm@osdl.org>
In-Reply-To: <20030704210737.GI955@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org>
	<20030704210737.GI955@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: anton@samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> On Thu, Jul 03, 2003 at 02:37:14AM -0700, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.74/2.5.74-mm1/
> 
> anton saw the OOM killer try to kill pdflush, causing tons of spurious
> wakeups. This should avoid picking kernel threads in select_bad_process().
> 
> 
> -- wli
> 
> 
> ===== mm/oom_kill.c 1.23 vs edited =====
> --- 1.23/mm/oom_kill.c	Wed Apr 23 03:15:53 2003
> +++ edited/mm/oom_kill.c	Fri Jul  4 14:03:32 2003
> @@ -123,7 +123,7 @@
>  	struct task_struct *chosen = NULL;
>  
>  	do_each_thread(g, p)
> -		if (p->pid) {
> +		if (p->pid && p->mm) {
>  			int points = badness(p);
>  			if (points > maxpoints) {
>  				chosen = p;

Look at select_bad_process(), and the ->mm test in badness().  pdflush
can never be chosen.

Nevertheless, there have been several report where kernel threads _are_ 
being hit my the oom killer.  Any idea why that is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
