Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD9E68D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:59:21 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oAF9xJD3005693
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 01:59:19 -0800
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by wpaz24.hot.corp.google.com with ESMTP id oAF9xHlm003133
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 01:59:18 -0800
Received: by pzk30 with SMTP id 30so806457pzk.41
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 01:59:17 -0800 (PST)
Date: Mon, 15 Nov 2010 01:59:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101115092238.BEEE.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011150152490.2986@chino.kir.corp.google.com>
References: <20101109105801.BC30.A69D9226@jp.fujitsu.com> <20101109122817.BC5A.A69D9226@jp.fujitsu.com> <20101115092238.BEEE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, KOSAKI Motohiro wrote:

> At v2.6.36-rc1, oom-killer doesn't work at all because YOU BROKE.
> And I was working on fixing it.
> 
> 2010-08-19
> http://marc.info/?t=128223176900001&r=1&w=2

This existed before my oom killer rewrite, it was only noticed because the 
rewrite enabled oom_dump_tasks by default.

> http://marc.info/?t=128221532700003&r=1&w=2

Yes, tasklist_lock was dropped in a mismerge of my patches when posting 
them.  Thanks for finding it and posting a patch, I appreciate it.

> http://marc.info/?t=128221532500008&r=1&w=2
> 

Yes, if a task was racing between oom_kill_process() and oom_kill_task() 
and all threads had dropped its mm between calls then there was a NULL 
pointer dereference, thanks for fixing that as well.

> However, You submitted new crap before the fixing. 
> 
> 2010-08-15
> http://marc.info/?t=128184669600001&r=1&w=2
> 

This isn't "crap", this is a necessary bit to ensure that tasks that share 
an ->mm with a task immune from kill aren't killed themselves since we 
can't free the memory.  We came to the consensus that it would be better 
to count the tasks that are OOM_DISABLE in the mm_struct to avoid the 
O(2*n) tasklist scan.

> If you tested mainline a bit, you could find the problem quickly.
> You should have fixed mainline kernel at first.
> 

Thanks for finding a couple fixes during the 2.6.36-rc1 when the rewrite 
was first merged, it's much appreciated!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
