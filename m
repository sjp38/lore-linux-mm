Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 68A816B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 16:33:20 -0500 (EST)
Received: by yenm10 with SMTP id m10so2196116yen.14
        for <linux-mm@kvack.org>; Thu, 17 Nov 2011 13:33:17 -0800 (PST)
Date: Thu, 17 Nov 2011 13:33:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.2-rc3] cpusets: stall when updating mems_allowed
 for mempolicy or disjoint nodemask
In-Reply-To: <4EC4C603.8050704@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1111171328120.15918@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1111161307020.23629@chino.kir.corp.google.com> <4EC4C603.8050704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 17 Nov 2011, Miao Xie wrote:

> Oh~, David
> 
> I find these is another problem, please take account of the following case:
> 
>   2-3 -> 1-2 -> 0-1
> 
> the user change mems_allowed twice continuously, the task may see the empty
> mems_allowed.
> 
> So, it is still dangerous.
> 

With this patch, we're protected by task_lock(tsk) to determine whether we 
want to take the exception, i.e. whether need_loop is false, and the 
setting of tsk->mems_allowed.  So this would see the nodemask change at 
the individual steps from 2-3 -> 1-2 -> 0-1, not some inconsistent state 
in between or directly from 2-3 -> 0-1.  The only time we don't hold 
task_lock(tsk) to change tsk->mems_allowed is when tsk == current and in 
that case we're not concerned about intermediate reads to its own nodemask 
while storing to a mask where MAX_NUMNODES > BITS_PER_LONG.

Thus, there's no problem here with regard to such behavior if we exclude 
mempolicies, which this patch does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
