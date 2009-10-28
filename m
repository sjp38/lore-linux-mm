Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 08B8D6B007B
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 05:15:53 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id n9S9Fn2a002582
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:15:49 -0700
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz29.hot.corp.google.com with ESMTP id n9S9Fkm3008987
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:15:47 -0700
Received: by pzk12 with SMTP id 12so445317pzk.13
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:15:46 -0700 (PDT)
Date: Wed, 28 Oct 2009 02:15:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, KAMEZAWA Hiroyuki wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> It's reported that OOM-Killer kills Gnone/KDE at first...
> And yes, we can reproduce it easily.
> 
> Now, oom-killer uses mm->total_vm as its base value. But in recent
> applications, there are a big gap between VM size and RSS size.
> Because
>   - Applications attaches much dynamic libraries. (Gnome, KDE, etc...)
>   - Applications may alloc big VM area but use small part of them.
>     (Java, and multi-threaded applications has this tendency because
>      of default-size of stack.)
> 
> I think using mm->total_vm as score for oom-kill is not good.
> By the same reason, overcommit memory can't work as expected.
> (In other words, if we depends on total_vm, using overcommit more positive
>  is a good choice.)
> 
> This patch uses mm->anon_rss/file_rss as base value for calculating badness.
> 

How does this affect the ability of the user to tune the badness score of 
individual threads?  It seems like there will now only be two polarizing 
options: the equivalent of an oom_adj value of +15 or -17.  It is now 
heavily dependent on the rss which may be unclear at the time of oom and 
very dynamic.

I think a longer-term solution may rely more on the difference in 
get_mm_hiwater_rss() and get_mm_rss() instead to know the difference 
between what is resident in RAM at the time of oom compared to what has 
been swaped.  Using this with get_mm_hiwater_vm() would produce a nice 
picture for the pattern of each task's memory consumption.

> Following is changes to OOM score(badness) on an environment with 1.6G memory
> plus memory-eater(500M & 1G).
> 
> Top 10 of badness score. (The highest one is the first candidate to be killed)
> Before
> badness program
> 91228	gnome-settings-
> 94210	clock-applet
> 103202	mixer_applet2
> 106563	tomboy
> 112947	gnome-terminal
> 128944	mmap              <----------- 500M malloc
> 129332	nautilus
> 215476	bash              <----------- parent of 2 mallocs.
> 256944	mmap              <----------- 1G malloc
> 423586	gnome-session
> 
> After
> badness 
> 1911	mixer_applet2
> 1955	clock-applet
> 1986	xinit
> 1989	gnome-session
> 2293	nautilus
> 2955	gnome-terminal
> 4113	tomboy
> 104163	mmap             <----------- 500M malloc.
> 168577	bash             <----------- parent of 2 mallocs
> 232375	mmap             <----------- 1G malloc
> 
> seems good for me. 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> Index: mm-test-kernel/mm/oom_kill.c
> ===================================================================
> --- mm-test-kernel.orig/mm/oom_kill.c
> +++ mm-test-kernel/mm/oom_kill.c
> @@ -93,7 +93,7 @@ unsigned long badness(struct task_struct
>  	/*
>  	 * The memory size of the process is the basis for the badness.
>  	 */
> -	points = mm->total_vm;
> +	points = get_mm_counter(mm, anon_rss) + get_mm_counter(mm, file_rss);
>  
>  	/*
>  	 * After this unlock we can no longer dereference local variable `mm'
> @@ -116,8 +116,12 @@ unsigned long badness(struct task_struct
>  	 */
>  	list_for_each_entry(child, &p->children, sibling) {
>  		task_lock(child);
> -		if (child->mm != mm && child->mm)
> -			points += child->mm->total_vm/2 + 1;
> +		if (child->mm != mm && child->mm) {
> +			unsigned long cpoints;
> +			cpoints = get_mm_counter(child->mm, anon_rss);
> +				  + get_mm_counter(child->mm, file_rss);

That shouldn't compile.

> +			points += cpoints/2 + 1;
> +		}
>  		task_unlock(child);
>  	}
>  

This can all be simplified by just using get_mm_rss(mm) and 
get_mm_rss(child->mm).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
