Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 789566B003D
	for <linux-mm@kvack.org>; Sun,  5 Apr 2009 23:30:04 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n363UUJS002702
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 6 Apr 2009 12:30:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2519F45DE5B
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:30:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 926F345DE56
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:30:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E98AC1DB805F
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:30:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 997191DB805D
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:30:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: + mm-align-vmstat_works-timer.patch added to -mm tree
In-Reply-To: <200904011945.n31JjWqG028114@imap1.linux-foundation.org>
References: <200904011945.n31JjWqG028114@imap1.linux-foundation.org>
Message-Id: <20090406120533.450B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  6 Apr 2009 12:30:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, anton@samba.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

(swich to lkml and linux-mm)

Hi Anton,

Do you have any mesurement data?

Honestly, I made the same patch few week ago.
but I found two problems.

1)
work queue tracer (in -tip) reported it isn't proper rounded.

The fact is, schedule_delayed_work(work, round_jiffies_relative()) is
a bit ill.

it mean
  - round_jiffies_relative() calculate rounded-time - jiffies
  - schedule_delayed_work() calculate argument + jiffies

it assume no jiffies change at above two place. IOW it assume
non preempt kernel.


2)
> -	schedule_delayed_work_on(cpu, vmstat_work, HZ + cpu);
> +	schedule_delayed_work_on(cpu, vmstat_work,
> +				 __round_jiffies_relative(HZ, cpu));

isn't same meaning.

vmstat_work mean to move per-cpu stastics to global stastics.
Then, (HZ + cpu) mean to avoid to touch the same global variable at the same time.

Oh well, this patch have performance regression risk on _very_ big server.
(perhaps, only sgi?)

but I agree vmstat_work is one of most work queue heavy user.
For power consumption view, it isn't proper behavior.

I still think improving another way.

> 
> The patch titled
>      mm: align vmstat_work's timer
> has been added to the -mm tree.  Its filename is
>      mm-align-vmstat_works-timer.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> Subject: mm: align vmstat_work's timer
> From: Anton Blanchard <anton@samba.org>
> 
> Even though vmstat_work is marked deferrable, there are still benefits to
> aligning it.  For certain applications we want to keep OS jitter as low as
> possible and aligning timers and work so they occur together can reduce
> their overall impact.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/vmstat.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff -puN mm/vmstat.c~mm-align-vmstat_works-timer mm/vmstat.c
> --- a/mm/vmstat.c~mm-align-vmstat_works-timer
> +++ a/mm/vmstat.c
> @@ -984,7 +984,7 @@ static void vmstat_update(struct work_st
>  {
>  	refresh_cpu_vm_stats(smp_processor_id());
>  	schedule_delayed_work(&__get_cpu_var(vmstat_work),
> -		sysctl_stat_interval);
> +		round_jiffies_relative(sysctl_stat_interval));
>  }
>  
>  static void __cpuinit start_cpu_timer(int cpu)
> @@ -992,7 +992,8 @@ static void __cpuinit start_cpu_timer(in
>  	struct delayed_work *vmstat_work = &per_cpu(vmstat_work, cpu);
>  
>  	INIT_DELAYED_WORK_DEFERRABLE(vmstat_work, vmstat_update);
> -	schedule_delayed_work_on(cpu, vmstat_work, HZ + cpu);
> +	schedule_delayed_work_on(cpu, vmstat_work,
> +				 __round_jiffies_relative(HZ, cpu));
>  }
>  
>  /*
> _
> 
> Patches currently in -mm which might be from anton@samba.org are
> 
> origin.patch
> mm-align-vmstat_works-timer.patch
> random-align-rekey_works-timer.patch
> sunrpc-align-cache_clean-works-timer.patch
> 
> --
> To unsubscribe from this list: send the line "unsubscribe mm-commits" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
