Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id F1BEA6B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:11:24 -0400 (EDT)
Date: Tue, 10 Apr 2012 21:10:59 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] mm: correctly synchronize rss-counters at exit/exec
Message-ID: <20120410191059.GA5678@redhat.com>
References: <20120409200336.8368.63793.stgit@zurg> <20120410170732.18750.64274.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120410170732.18750.64274.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 04/10, Konstantin Khlebnikov wrote:
>
> This patch moves sync_mm_rss() into mm_release(), and moves mm_release() out of
> do_exit() and calls it earlier. After mm_release() there should be no page-faults.

Can't prove, but I feel there should be a simpler fix...

Anyway, this patch is not exactly correct.

> @@ -959,9 +959,10 @@ void do_exit(long code)
>  				preempt_count());
>
>  	acct_update_integrals(tsk);
> -	/* sync mm's RSS info before statistics gathering */
> -	if (tsk->mm)
> -		sync_mm_rss(tsk->mm);
> +
> +	/* Release mm and sync mm's RSS info before statistics gathering */
> +	mm_release(tsk, tsk->mm);

This breaks kthread_stop() at least.

The exiting kthread shouldn't do complete_vfork_done() until it
sets ->exit_code.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
