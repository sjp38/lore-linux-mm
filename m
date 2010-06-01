Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D55806B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:42:59 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o51Kgu4M009694
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:42:56 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by hpaq6.eem.corp.google.com with ESMTP id o51KgRno003616
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:42:53 -0700
Received: by pwi3 with SMTP id 3so468970pwi.37
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 13:42:52 -0700 (PDT)
Date: Tue, 1 Jun 2010 13:42:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] oom: introduce find_lock_task_mm() to fix !mm false
 positives
In-Reply-To: <20100531183539.1849.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006011341380.13136@chino.kir.corp.google.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com> <20100531183539.1849.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010, KOSAKI Motohiro wrote:

> From: Oleg Nesterov <oleg@redhat.com>
> Subject: [PATCH 3/5] oom: introduce find_lock_task_mm() to fix !mm false positives
> 
> Almost all ->mm == NUL checks in oom_kill.c are wrong.
> 
> The current code assumes that the task without ->mm has already
> released its memory and ignores the process. However this is not
> necessarily true when this process is multithreaded, other live
> sub-threads can use this ->mm.
> 
> - Remove the "if (!p->mm)" check in select_bad_process(), it is
>   just wrong.
> 
> - Add the new helper, find_lock_task_mm(), which finds the live
>   thread which uses the memory and takes task_lock() to pin ->mm
> 
> - change oom_badness() to use this helper instead of just checking
>   ->mm != NULL.
> 
> - As David pointed out, select_bad_process() must never choose the
>   task without ->mm, but no matter what badness() returns the
>   task can be chosen if nothing else has been found yet.
> 
> Note! This patch is not enough, we need more changes.
> 
> 	- badness() was fixed, but oom_kill_task() still ignores
> 	  the task without ->mm
> 
> This will be addressed later.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [rebase
> latest -mm and remove some obsoleted description]

This is already pushed as part of my oom killer rewrite in patch 15/18 
"oom: introduce find_lock_task_mm to fix !mm false positives".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
