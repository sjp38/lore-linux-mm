Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9881E6B01B6
	for <linux-mm@kvack.org>; Mon, 31 May 2010 21:01:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5111dax031738
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Jun 2010 10:01:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 805B445DE5D
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:01:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6210B45DE57
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:01:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D631DB8041
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:01:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDFA61DB803E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:01:38 +0900 (JST)
Date: Tue, 1 Jun 2010 09:57:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] oom: introduce find_lock_task_mm() to fix !mm false
 positives
Message-Id: <20100601095727.9ba3e108.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100531183539.1849.A69D9226@jp.fujitsu.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com>
	<20100531183539.1849.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010 18:36:34 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

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

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
