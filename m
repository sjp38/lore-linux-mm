Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A1B598D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:48:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3BBEB3EE0BD
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:48:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 01EE345DE91
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:48:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D99B845DE98
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:48:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA46BE1800C
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:48:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8511CE18007
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:48:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
In-Reply-To: <20110324152757.GC1938@barrios-desktop>
References: <20110322200657.B064.A69D9226@jp.fujitsu.com> <20110324152757.GC1938@barrios-desktop>
Message-Id: <20110328184856.F078.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Mar 2011 18:48:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

Hi

> @@ -434,9 +452,17 @@ static int oom_kill_task(struct task_struct *p)
>                 K(get_mm_counter(p->mm, MM_FILEPAGES)));
>         task_unlock(p);
>  
> -       p->rt.time_slice = HZ; <<---- THIS
> +
>         set_tsk_thread_flag(p, TIF_MEMDIE);
>         force_sig(SIGKILL, p);
> +
> +       /*
> +        * We give our sacrificial lamb high priority and access to
> +        * all the memory it needs. That way it should be able to
> +        * exit() and clear out its resources quickly...
> +        */
> +       boost_dying_task_prio(p, mem);
> +
>         return 0;
>  }
> 
> At that time, I thought that routine is meaningless in non-RT scheduler.
> So I Cced Peter but don't get the answer.
> I just want to confirm it.
> 
> Do you still think it's meaningless? 

In short, yes.


> so you remove it when you revert 93b43fa5508?
> Then, this isn't just revert patch but revert + killing meaningless code patch.

If you want, I'd like to rename a patch title. That said, we can't revert
93b43fa5508 simple cleanly, several patches depend on it. therefore I
reverted it manualy. and at that time, I don't want to resurrect
meaningless logic. anyway it's no matter. Luis is preparing new patches.
therefore we will get the same end result. :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
