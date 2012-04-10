Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 42FA66B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 14:43:32 -0400 (EDT)
Date: Tue, 10 Apr 2012 11:43:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: correctly synchronize rss-counters at exit/exec
Message-Id: <20120410114329.138fe242.akpm@linux-foundation.org>
In-Reply-To: <20120410170732.18750.64274.stgit@zurg>
References: <20120409200336.8368.63793.stgit@zurg>
	<20120410170732.18750.64274.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 10 Apr 2012 21:07:32 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> mm->rss_stat counters have per-task delta: task->rss_stat, before changing
> task->mm pointer kernel must flush this delta with help of sync_mm_rss().
> 
> do_exit() already calls sync_mm_rss() to flush rss-counters before commiting
> rss-statistics into task->signal->maxrss, taskstats, audit and other stuff.
> Unfortunately kernel do this before calling mm_relese(), which can call put_user()
> for processing task->clear_child_tid. So at this point we can trigger page-faults
> and task->rss_stat becomes non-zero again, as result mm->rss_stat becomes
> inconsistent and check_mm() will print something like this:
> 
> | BUG: Bad rss-counter state mm:ffff88020813c380 idx:1 val:-1
> | BUG: Bad rss-counter state mm:ffff88020813c380 idx:2 val:1
> 
> This patch moves sync_mm_rss() into mm_release(), and moves mm_release() out of
> do_exit() and calls it earlier. After mm_release() there should be no page-faults.
> 
> ...
> 
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -751,6 +751,14 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
>  		}
>  		tsk->clear_child_tid = NULL;
>  	}
> +
> +	/*
> +	 * Final rss-counter synchronization. After this point must be
> +	 * no page-faults into this mm from current context, otherwise
> +	 * mm->rss_stat will be inconsistent.
> +	 */
> +	if (mm)
> +		sync_mm_rss(mm);
>  }
>  

Well that's scary.  AFACIT `mm' can indeed be NULL here, when a kernel
thread calls do_exit().  No implementation of deactivate_mm() actually
uses its `mm' arg and I guess that kernel threads never set
tsk->clear_child_tid.  Whee.


Do we think we should backport this into -stable kernels?  How hard is
it to make that warning come out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
