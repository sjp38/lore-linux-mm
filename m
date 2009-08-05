Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ABB8A6B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:40:16 -0400 (EDT)
Date: Wed, 5 Aug 2009 16:39:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH for 2.6.31 0/4] fix oom_adj regression v2
Message-Id: <20090805163945.056c463c.akpm@linux-foundation.org>
In-Reply-To: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue,  4 Aug 2009 19:25:08 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> The commit 2ff05b2b (oom: move oom_adj value) move oom_adj value to mm_struct.
> It is very good first step for sanitize OOM.
> 
> However Paul Menage reported the commit makes regression to his job scheduler.
> Current OOM logic can kill OOM_DISABLED process.
> 
> Why? His program has the code of similar to the following.
> 
> 	...
> 	set_oom_adj(OOM_DISABLE); /* The job scheduler never killed by oom */
> 	...
> 	if (vfork() == 0) {
> 		set_oom_adj(0); /* Invoked child can be killed */
> 		execve("foo-bar-cmd")
> 	}
> 	....
> 
> vfork() parent and child are shared the same mm_struct. then above set_oom_adj(0) doesn't
> only change oom_adj for vfork() child, it's also change oom_adj for vfork() parent.
> Then, vfork() parent (job scheduler) lost OOM immune and it was killed.
> 
> Actually, fork-setting-exec idiom is very frequently used in userland program. We must
> not break this assumption.
> 
> This patch series are slightly big, but we must fix any regression soon.
> 

So I merged these but I have a feeling that this isn't the last I'll be
hearing on the topic ;)

Given the amount of churn, the amount of discussion and the size of the
patches, this doesn't look like something we should push into 2.6.31.  

If we think that the 2ff05b2b regression is sufficiently serious to be
a must-fix for 2.6.31 then can we please find something safer and
smaller?  Like reverting 2ff05b2b?


These patches clash with the controversial
mm-introduce-proc-pid-oom_adj_child.patch, so I've disabled that patch
now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
