Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DA01C6B005A
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 16:20:54 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n71KR0sZ008377
	for <linux-mm@kvack.org>; Sat, 1 Aug 2009 13:27:01 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by zps37.corp.google.com with ESMTP id n71KQu0k016629
	for <linux-mm@kvack.org>; Sat, 1 Aug 2009 13:26:57 -0700
Received: by pxi7 with SMTP id 7so2005325pxi.0
        for <linux-mm@kvack.org>; Sat, 01 Aug 2009 13:26:56 -0700 (PDT)
Date: Sat, 1 Aug 2009 13:26:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com> <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com> <20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com> <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com> <7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
 <alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com> <77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Aug 2009, KAMEZAWA Hiroyuki wrote:

> Summarizing I think now .....
>   - rename mm->oom_adj as mm->effective_oom_adj
>   - re-add per-thread oom_adj
>   - update mm->effective_oom_adj based on per-thread oom_adj
>   - if necessary, plz add read-only /proc/pid/effective_oom_adj file.
>     or show 2 values in /proc/pid/oom_adj
>   - rewrite documentation about oom_score.
>    " it's calclulated from  _process's_ memory usage and oom_adj of
>     all threads which shares a memor  context".
>    This behavior is not changed from old implemtation, anyway.
>  - If necessary, rewrite oom_kill itself to scan only thread group
>    leader. It's a way to go regardless of  vfork problem.
> 

Ok, so you've abandoned the signal_struct proposal and now want to add it 
back to task_struct with an effective member in mm_struct by changing the 
documentation.  Hmm.

This solves the livelock problem by adding additional tunables, but 
doesn't match how the documentation describes the use case for 
/proc/pid/oom_adj.  Your argument is that the behavior of that value can't 
change: that it must be per-thread.  And that allowance leads to one of 
two inconsistent scenarios:

 - /proc/pid/oom_score is inconsistent when tuning /proc/pid/oom_adj if it
   relies on the per-thread oom_adj; it now really represents nothing but
   an incorrect value if other threads share that memory and misleads the
   user on how the oom killer chooses victims, or

 - /proc/pid/oom_score is inconsistent when the thread that set the
   effective per-mm oom_adj exits and it is now obsolete since you have
   no way to determine what the next effective oom_adj value shall be.

Determining the next effective per-mm oom_adj isn't possible when the only 
threads sharing the mm remaining have different per-thread oom_adj values.  
That's a horribly inconsistent state to be getting into because it allows 
oom_score to change when a thread exits, which is completely unknown to 
userspace, OR is allows the effective per-mm oom_adj to be different from 
all threads sharing the same memory (and, thus, /proc/pid/oom_score not 
being representative of any thread's /proc/pid/oom_adj).

> I think documentation is wrong. It should say "you should think of
> multi-thread effect to oom_adj/oom_score".
> 

It's more likely than not that applications were probably written to the 
way the documentation described the two files: that is, adjust 
/proc/pid/oom_score by tuning /proc/pid/oom_adj instead of relying on an 
undocumented implementation detail concerning the tuning of oom_adj for a 
vfork'd child prior to exec().  The user is probably unaware of the oom 
killer's implementation and simply interprets a higher oom_score as a more 
likely candidate for oom kill.  My patches preserve that in all scenarios 
without altering the documentation or adding additional files that would 
be required to leave the oom_adj value itself in an inconsistent state as 
you propose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
