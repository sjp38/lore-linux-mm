Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 35AD16B005A
	for <linux-mm@kvack.org>; Tue, 29 May 2012 16:18:37 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so5011084bkc.14
        for <linux-mm@kvack.org>; Tue, 29 May 2012 13:18:35 -0700 (PDT)
Message-ID: <4FC52F17.20709@openvz.org>
Date: Wed, 30 May 2012 00:18:31 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
 val:-59
References: <4FBC1618.5010408@fold.natur.cuni.cz> <20120522162835.c193c8e0.akpm@linux-foundation.org> <20120522162946.2afcdb50.akpm@linux-foundation.org> <20120523172146.GA27598@redhat.com>
In-Reply-To: <20120523172146.GA27598@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>, LKML <linux-kernel@vger.kernel.org>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "hughd@google.com" <hughd@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Oleg Nesterov wrote:
> On 05/22, Andrew Morton wrote:
>>
>> Also, I have a note here that Oleg was unhappy with the patch.  Oleg
>> happiness is important.  Has he cheered up yet?
>
> Well, yes, I do not really like this patch ;) Because I think there is
> a more simple/straightforward fix, see below. In my opinion it also
> makes the original code simpler.
>
> But. Obviously this is subjective, I can't prove my patch is "better",
> and I didn't try to test it.
>
> So I won't argue with Konstantin who dislikes my patch, although I
> would like to know the reason.

I don't remember why I dislike your patch.
For now I can only say ACK )

>
> Oleg.
>
>
> --- a/kernel/tsacct.c
> +++ b/kernel/tsacct.c
> @@ -91,6 +91,7 @@ void xacct_add_tsk(struct taskstats *sta
>   	stats->virtmem = p->acct_vm_mem1 * PAGE_SIZE / MB;
>   	mm = get_task_mm(p);
>   	if (mm) {
> +		sync_mm_rss(mm);
>   		/* adjust to KB unit */
>   		stats->hiwater_rss   = get_mm_hiwater_rss(mm) * PAGE_SIZE / KB;
>   		stats->hiwater_vm    = get_mm_hiwater_vm(mm)  * PAGE_SIZE / KB;
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -643,6 +643,8 @@ static void exit_mm(struct task_struct *
>   	mm_release(tsk, mm);
>   	if (!mm)
>   		return;
> +
> +	sync_mm_rss(mm);
>   	/*
>   	 * Serialize with any possible pending coredump.
>   	 * We must hold mmap_sem around checking core_state
> @@ -960,9 +962,6 @@ void do_exit(long code)
>   				preempt_count());
>
>   	acct_update_integrals(tsk);
> -	/* sync mm's RSS info before statistics gathering */
> -	if (tsk->mm)
> -		sync_mm_rss(tsk->mm);
>   	group_dead = atomic_dec_and_test(&tsk->signal->live);
>   	if (group_dead) {
>   		hrtimer_cancel(&tsk->signal->real_timer);
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -823,10 +823,10 @@ static int exec_mmap(struct mm_struct *m
>   	/* Notify parent that we're no longer interested in the old VM */
>   	tsk = current;
>   	old_mm = current->mm;
> -	sync_mm_rss(old_mm);
>   	mm_release(tsk, old_mm);
>
>   	if (old_mm) {
> +		sync_mm_rss(old_mm);
>   		/*
>   		 * Make sure that if there is a core dump in progress
>   		 * for the old mm, we get out and die instead of going
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
