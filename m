Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 20EA46B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:59:34 -0500 (EST)
Received: by iajr24 with SMTP id r24so1722927iaj.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 13:59:33 -0800 (PST)
Date: Thu, 8 Mar 2012 13:59:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: allow exiting tasks to have access to memory
 reserves
In-Reply-To: <20120308120859.f7bc8cad.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1203081353150.23632@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061824280.9015@chino.kir.corp.google.com> <4F570286.8020704@gmail.com> <alpine.DEB.2.00.1203062316430.4158@chino.kir.corp.google.com> <20120308120859.f7bc8cad.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, 8 Mar 2012, Andrew Morton wrote:

> > It closes the risk of livelock if an oom killed thread, thread A, cannot 
> > exit because it's blocked on another thread, thread B, which cannot exit 
> > because it requires memory in the exit path and doesn't have access to 
> > memory reserves.  So this patch makes it more likely that an oom killed 
> > thread will be able to exit without livelocking.
> 
> But it also "allow to eat all of reserve memory and bring us new
> serious failure".  In theory, at least.
> 

Exactly, "in theory."  We've never seen an issue where a set of threads in 
do_exit() allocated memory at the same time to deplete all memory reserves 
while never freeing the memory so that reclaim consistently fails and all 
threads continue to enter into the oom killer to get access to memory 
reserves.

And, with the way the code is written before this patch, only one thread 
will have access to memory reserves and the oom killer will be a no-op 
until it exits.  There's a much higher liklihood that an oom killed thread 
may not exit because it's blocked on another thread that requires memory.  
That's what this patch addresses.

> And afaict the proposed patch is a theoretical thing as well.  Has
> anyone sat down and created tests to demonstrate either problem?

We've run with this patch internally for a year because an oom killed 
thread can't exit.  We used to address this with an oom killer timeout 
that would kill another thread only after 10s but it was much faster to 
just give access to memory reserves and to let them exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
