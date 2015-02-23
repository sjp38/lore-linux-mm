Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0986B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 17:08:21 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so27289693iec.4
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:08:21 -0800 (PST)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com. [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id b93si7837076ioj.49.2015.02.23.14.08.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 14:08:21 -0800 (PST)
Received: by iecrd18 with SMTP id rd18so27238938iec.8
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:08:21 -0800 (PST)
Date: Mon, 23 Feb 2015 14:08:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
In-Reply-To: <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1502231347510.21127@chino.kir.corp.google.com>
References: <20141229181937.GE32618@dhcp22.suse.cz> <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp> <20141230112158.GA15546@dhcp22.suse.cz> <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp> <20150216154201.GA27295@phnom.home.cmpxchg.org>
 <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue, 17 Feb 2015, Tetsuo Handa wrote:

> Yes, basic idea would be same with
> http://marc.info/?l=linux-mm&m=142002495532320&w=2 .
> 
> But Michal and David do not like the timeout approach.
> http://marc.info/?l=linux-mm&m=141684783713564&w=2
> http://marc.info/?l=linux-mm&m=141686814824684&w=2
> 
> Unless they change their opinion in response to the discovery explained at
> http://lwn.net/Articles/627419/ , timeout patches will not be accepted.
> 

Unfortunately, timeout based solutions aren't guaranteed to provide 
anything more helpful.  The problem you're referring to is when the oom 
kill victim is waiting on a mutex and cannot make forward progress even 
though it has access to memory reserves.  Threads that are holding the 
mutex and allocate in a blockable context will cause the oom killer to 
defer forever because it sees the presence of a victim waiting to exit.

	TaskA			TaskB
	=====			=====
	mutex_lock(i_mutex)
	allocate memory
	oom kill TaskB
				mutex_lock(i_mutex)

In this scenario, nothing on the system will be able to allocate memory 
without some type of memory reserve since at least one thread is holding 
the mutex that the victim needs and is looping forever, unless memory is 
freed by something else on the system which allows TaskA to allocate and 
drop the mutex.

In a timeout based solution, this would be detected and another thread 
would be chosen for oom kill.  There's currently no way for the oom killer 
to select a process that isn't waiting for that same mutex, however.  If 
it does, then the process has been killed needlessly since it cannot make 
forward progress itself without grabbing the mutex.

Certainly, it would be better to eventually kill something else in the 
hope that it does not need the mutex and will free some memory which would 
allow the thread that had originally been deferring forever, TaskA, in the 
oom killer waiting for the original victim, TaskB, to exit.  If that's the 
solution, then TaskA had been killed unnecessarily itself.

Perhaps we should consider an alternative: allow threads, such as TaskA, 
that are deferring for a long amount of time to simply allocate with 
ALLOC_NO_WATERMARKS itself in that scenario in the hope that the 
allocation succeeding will eventually allow it to drop the mutex.  Two 
problems: (1) there's no guarantee that the simple allocation is all TaskA 
needs before it will drop the lock and (2) another thread could 
immediately grab the same mutex and allocate, in which the same series of 
events repeats.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
