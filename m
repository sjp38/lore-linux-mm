Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 219F46B01DB
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:41:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BftJW012317
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8F0145DE6F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F6E45DE4D
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 77461E38008
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1972CE38004
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 09/18] oom: add forkbomb penalty to badness heuristic
In-Reply-To: <alpine.DEB.2.00.1006010015220.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015220.29202@chino.kir.corp.google.com>
Message-Id: <20100607105832.876B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Add a forkbomb penalty for processes that fork an excessively large
> number of children to penalize that group of tasks and not others.  A
> threshold is configurable from userspace to determine how many first-
> generation execve children (those with their own address spaces) a task
> may have before it is considered a forkbomb.  This can be tuned by
> altering the value in /proc/sys/vm/oom_forkbomb_thres, which defaults to
> 1000.
> 
> When a task has more than 1000 first-generation children with different
> address spaces than itself, a penalty of
> 
> 	(average rss of children) * (# of 1st generation execve children)
> 	-----------------------------------------------------------------
> 			oom_forkbomb_thres
> 
> is assessed.  So, for example, using the default oom_forkbomb_thres of
> 1000, the penalty is twice the average rss of all its execve children if
> there are 2000 such tasks.  A task is considered to count toward the
> threshold if its total runtime is less than one second; for 1000 of such
> tasks to exist, the parent process must be forking at an extremely high
> rate either erroneously or maliciously.
> 
> Even though a particular task may be designated a forkbomb and selected as
> the victim, the oom killer will still kill the 1st generation execve child
> with the highest badness() score in its place.  The avoids killing
> important servers or system daemons.  When a web server forks a very large
> number of threads for client connections, for example, it is much better
> to kill one of those threads than to kill the server and make it
> unresponsive.

Reviewers need to trace patch author's intention, this description seems
only focus "how to implement". but reviewers need the explaination of the 
big picture.

The old stragegy is here
  (1) accumulate half of child vsz
  (2) instead, kill the child at first

Your stragegy is here
  (a) usually dont accumulate child mem
  (b) but short lived child is accumulated
  (c) kill the child at first

I think, at least two explaination is necessary.

 - Usually, legitimate process (e.g. web server, rdb) makes a lot of
   1st generation child. but forkbomb usually makes multi level generation
   child. why do you only care 1st generation?
 - In usual case, your don't care the child rsz. but kill the child.
   That seems inconsistency than old. Why do you choose this technique?

Now, I don't have any objection at all because I haven't understand your point.
Ok, the concept of forkbomb detection is good. but need to describe

 - why do you choose this way?
 - how do you confirm your ways works fine?

Any heuristic can't reach perfect in practical. that's ok. but unclear
code intention easily makes code unmaintable. please avoid it.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
