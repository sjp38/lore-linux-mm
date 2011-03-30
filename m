Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE798D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 17:43:08 -0400 (EDT)
Date: Wed, 30 Mar 2011 14:36:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Accelerate OOM killing
Message-Id: <20110330143617.3d57aad2.akpm@linux-foundation.org>
In-Reply-To: <1300960353-2596-1-git-send-email-minchan.kim@gmail.com>
References: <1300960353-2596-1-git-send-email-minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>

On Thu, 24 Mar 2011 18:52:33 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> When I test Andrey's problem, I saw the livelock and sysrq-t says
> there are many tasks in cond_resched after try_to_free_pages.

__alloc_pages_direct_reclaim() has two cond_resched()s, in
straight-line code.  So I think you're concluding that the first
cond_resched() is a no-op, but the second one frequently schedules
away.

For this to be true, the try_to_free_pages() call must be doing
something to cause it, such as taking a large amount of time, or
delivering wakeups, etc.  Do we know?

The patch is really a bit worrisome and ugly.  If the CPU scheduler has
decided that this task should be preempted then *that* is the problem,
and we need to work out why it is happening and see if there is anything
we should fix.  Instead the patch simply ignores the scheduler's
directive, which is known as "papering over a bug".

IOW, we should work out why need_resched is getting set so frequently
rather than just ignoring it (and potentially worsening kernel
scheduling latency).

> If did_some_progress is false, cond_resched could delay oom killing so
> It might be killing another task.
> 
> This patch accelerates oom killing without unnecessary giving CPU
> to another task. It could help avoding unnecessary another task killing
> and livelock situation a litte bit.

Well...  _does_ it help?  What were the results of your testing of this
patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
