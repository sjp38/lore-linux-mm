Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 0284E6B006C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 09:29:08 -0400 (EDT)
Received: by lahi5 with SMTP id i5so1703513lah.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 06:29:07 -0700 (PDT)
Message-ID: <4FD1FE20.40600@openvz.org>
Date: Fri, 08 Jun 2012 17:29:04 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at exit/exec
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com> <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com> <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com> <alpine.LSU.2.00.1206071759050.1291@eggly.anvils> <4FD1D1F7.2090503@openvz.org> <20120608122459.GB23147@redhat.com>
In-Reply-To: <20120608122459.GB23147@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>

Oleg Nesterov wrote:
> On 06/08, Konstantin Khlebnikov wrote:
>>
>> As result you can see "BUG: Bad rss-counter state mm:ffff88040783a680 idx:1 val:-1" in dmesg
>>
>> There left only one problem: nobody calls sync_mm_rss() after put_user() in mm_release().
>
> Both callers call sync_mm_rss() to make check_mm() happy. But please
> see the changelog, I think we should move it into mm_release(). See
> the patch below (on top of v2 I sent). I need to recheck.

Patch below broken: it removes one hunk from kernel/exit.c twice.
And it does not add anything into mm_release().

>
> As for xacct_add_tsk(), yes it can "miss" that put_user(). But this
> is what we have now, I think we do not care.
>
> Oleg.
>
> --- x/fs/exec.c
> +++ x/fs/exec.c
> @@ -822,7 +822,6 @@ static int exec_mmap(struct mm_struct *m
>   	mm_release(tsk, old_mm);
>
>   	if (old_mm) {
> -		sync_mm_rss(old_mm);
>   		/*
>   		 * Make sure that if there is a core dump in progress
>   		 * for the old mm, we get out and die instead of going
> --- x/kernel/exit.c
> +++ x/kernel/exit.c
> @@ -656,7 +656,6 @@ static void exit_mm(struct task_struct *
>   	if (!mm)
>   		return;
>
> -	sync_mm_rss(mm);
>   	/*
>   	 * Serialize with any possible pending coredump.
>   	 * We must hold mmap_sem around checking core_state
> --- x/kernel/taskstats.c
> +++ x/kernel/taskstats.c
> @@ -630,8 +630,7 @@ void taskstats_exit(struct task_struct *
>   	if (!stats)
>   		goto err;
>
> -	if (tsk->mm)
> -		sync_mm_rss(tsk->mm);
> +	sync_mm_rss(tsk->mm);
>   	fill_stats(tsk, stats);
>
>   	/*
> --- x/kernel/exit.c
> +++ x/kernel/exit.c
> @@ -656,7 +656,6 @@ static void exit_mm(struct task_struct *
>   	if (!mm)
>   		return;
>
> -	sync_mm_rss(mm);
>   	/*
>   	 * Serialize with any possible pending coredump.
>   	 * We must hold mmap_sem around checking core_state
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
