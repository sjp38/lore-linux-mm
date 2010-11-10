Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2506B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 16:00:43 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id oAAL0d5W024047
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 13:00:39 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by kpbe11.cbf.corp.google.com with ESMTP id oAAL0bHX004961
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 13:00:38 -0800
Received: by pwj4 with SMTP id 4so292131pwj.10
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 13:00:37 -0800 (PST)
Date: Wed, 10 Nov 2010 13:00:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3]mm/oom-kill: direct hardware access processes should
 get bonus
In-Reply-To: <1289402666.10699.28.camel@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1011101252260.830@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain> <1289305468.10699.2.camel@localhost.localdomain> <1289402093.10699.25.camel@localhost.localdomain> <1289402666.10699.28.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Figo.zhang" <zhangtianfei@leadcoretech.com>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2010, Figo.zhang wrote:

> the victim should not directly access hardware devices like Xorg server,
> because the hardware could be left in an unpredictable state, although 
> user-application can set /proc/pid/oom_score_adj to protect it. so i think
> those processes should get bonus for protection.
> 

Again, this argument doesn't work: if killing the task leaves hardware in 
an unpredictable state (and that's presumably harmful), then they 
shouldn't be killed at all.

Please show why CAP_SYS_RESOURCE equates to 3% additional memory for such 
tasks.

CAP_SYS_RESOURCE allows those threads to override resource limits, so 
these have potentially unbounded amounts of memory usage.  Thus, they may 
have the highest memory usage on the machine and now your patch has caused 
other innocent tasks to be killed before this is actually targeted.  
That's a bad result.  Why do we need this type of hack in the oom killer 
when these threads have the privilege to modify oom killing priorities for 
all tasks on the system?  Laziness, at the cost of a less predictable 
heuristic?

Why aren't you doing the same change for __vm_enough_memory() for LSMs?

> in v2, fix the incorrect comment.
> in v3, change the divided the badness score by 4, like old heuristic for protection. we just
> want the oom_killer don't select Root/RESOURCE/RAWIO process as possible.
> 
> suppose that if a user process A such as email cleint "evolution" and a process B with
> ditecly hareware access such as "Xorg", they have eat the equal memory (the badness score is 
> the same),so which process are you want to kill? so in new heuristic, it will kill the process B.
> but in reality, we want to kill process A.
> 

Then you need to protect process B accordingly and since it has 
CAP_SYS_RESOURCE it can easily do that on its own or the admin can protect 
Xorg.

> Signed-off-by: Figo.zhang <figo1802@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Unless you did this in private, I didn't see KOSAKI-san's reviewed-by line 
for this change and it is drastically different from what you've proposed 
before.

> ---
> mm/oom_kill.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4029583..f43d759 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -202,6 +202,15 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  		points -= 30;
>  
>  	/*
> +	 * Root and direct hareware access processes are usually more 
> +	 * important, so they should get bonus for protection. 
> +	 */
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> +	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
> +	    has_capability_noaudit(p, CAP_SYS_RAWIO))
> +		points /= 4;
> +

What on earth?  So now CAP_SYS_ADMIN gets a 3% bonus in the if-clause 
above this, then we divide a percentage of memory use by 4?  What does 
that mean AT ALL?

And now you've thrown CAP_SYS_RAWIO in there without any mention in the 
changelog?

Are you just trying to introduce all the old arbitrary heuristics from 
before the rewrite back into the oom killer like this?

Do you actually have a log from an event where the oom killer targeted the 
incorrect task?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
