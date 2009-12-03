Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C542600762
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 18:25:21 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id nB3NPGrF005829
	for <linux-mm@kvack.org>; Thu, 3 Dec 2009 15:25:16 -0800
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by spaceape7.eur.corp.google.com with ESMTP id nB3NPCV7031242
	for <linux-mm@kvack.org>; Thu, 3 Dec 2009 15:25:13 -0800
Received: by pzk2 with SMTP id 2so1854395pzk.26
        for <linux-mm@kvack.org>; Thu, 03 Dec 2009 15:25:12 -0800 (PST)
Date: Thu, 3 Dec 2009 15:25:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <20091202091739.5C3D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912031514150.8928@chino.kir.corp.google.com>
References: <20091201131509.5C19.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0912011414510.27500@chino.kir.corp.google.com> <20091202091739.5C3D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, vedran.furac@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, KOSAKI Motohiro wrote:

>  - I mean you don't need almost kernel heuristic. but desktop user need it.

My point is that userspace needs to be able to identify memory leaking 
tasks and polarize oom killing priorities.  /proc/pid/oom_adj does a good 
job of both with total_vm as a baseline.

>  - All job scheduler provide memory limitation feature. but OOM killer isn't
>    for to implement memory limitation. we have memory cgroup.

Wrong, the oom killer implements cpuset memory limitations.

>  - if you need memory usage based know, read /proc/{pid}/statm and write
>    /proc/{pid}/oom_priority works well probably.

Constantly polling /proc/pid/stat and updating the oom killer priorities 
at a constant interval is a ridiculous proposal for identifying memory 
leakers, sorry.

>  - Unfortunatelly, We can't continue to use VSZ based heuristics. because
>    modern application waste 10x VSZ more than RSS comsumption. in nowadays,
>    VSZ isn't good approximation value of RSS. There isn't any good reason to
>    continue form desktop user view.
> 

Then leave the heuristic alone by default so we don't lose any 
functionality that we once had and then add additional heuristics 
depending on the environment as determined by the manipulation of a new 
tunable.

> IOW, kernel hueristic should adjust to target majority user. we provide a knob
> to help minority user.
> 

Moving the baseline to rss severely impacts the legitimacy of that knob, 
we lose a lot of control over identifying memory leakers and polarizing 
oom killer priorities because it depends on the state of the VM at the 
time of oom for which /proc/pid/oom_adj may not have recently been updated 
to represent.

I don't know why you continuously invoke the same arguments to completely 
change the baseline for the oom killer heuristic because you falsely 
believe that killing the task with the largest memory resident in RAM is 
more often than not the ideal task to kill.  It's very frustrating when 
you insist on changing the default heuristic based on your own belief that 
people use Linux in the same way you do.

If Andrew pushes the patch to change the baseline to rss 
(oom_kill-use-rss-instead-of-vm-size-for-badness.patch) to Linus, I'll 
strongly nack it because you totally lack the ability to identify memory 
leakers as defined by userspace which should be the prime target for the 
oom killer.  You have not addressed that problem, you've merely talked 
around it, and yet the patch unbelievably still sits in -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
