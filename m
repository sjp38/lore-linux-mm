Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B0F336B0211
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg420008131
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:04 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E571C45DE7D
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EC5845DE6F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CECB7E38005
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 051D81DB8043
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 17/18] oom: add forkbomb penalty to badness heuristic
In-Reply-To: <alpine.DEB.2.00.1006061527180.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061527180.32225@chino.kir.corp.google.com>
Message-Id: <20100608203146.765A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
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

Today, I've test this patch. but I can't observed this works.

test way

prepare:
	make 500M memory cgroup

console1:
	run memtoy (consume 100M memory)

console2: 
	run forkbomb bash script ":(){ :|:& };:"
	AFAIK, this is most typical forkbom.  see http://en.wikipedia.org/wiki/Fork_bomb

each bash consume about 100KB and about 4000 bash process consume rest 400M.
oom_score list is here. 

1) almost bash don't get forkbomb bonus at all
2) maxmumly root bash get 2x bonus and the score changed from 90 to 180.
   but memtoy (100MB process) have score 25840. Still 143 times score
difference is there.



  pid     uid     total_vs anonrss(kb) filerss(kb) oom_adj oom_score comm
-----------------------------------------------------------------------------------
 [ 1865]     0     2880      448     1264 |        0      415 bash
 [ 1887]     0    12076      284     1056 |        0      325 su
 [ 1889]  1264     6313      992     1604 |        0      649 zsh
 [ 1906]  1264    29317   102660      700 |        0    25840 memtoy
 [ 2006]     0    26999      448     1376 |        0      442 bash
 [ 2024]     0    36195      292     1160 |        0      352 su
 [ 2025]  1268    26968      360     1380 |        0      435 bash
 [ 5555]  1268    26968      364      300 |        0      166 bash
 [ 5623]  1268    26968      364      300 |        0      166 bash
 [ 5688]  1268    26968      364      300 |        0      166 bash
 [ 5711]  1268    26968      364      300 |        0      166 bash
 [ 5742]  1268    26968      364      300 |        0      166 bash
 [ 5749]  1268    26968      364      300 |        0      166 bash
 [ 5752]  1268    26968      364      388 |        0      188 bash
 [ 5755]  1268    26968      364      300 |        0      166 bash
 [ 5765]  1268    26968      364      300 |        0      166 bash
 [ 5791]  1268    26968      364      300 |        0      166 bash
 [ 5808]  1268    26968      364      300 |        0      166 bash
 [ 5819]  1268    26968      364      324 |        0      172 bash
 [ 5835]  1268    26968      364      300 |        0      166 bash
 [ 5889]  1268    26968      364      300 |        0      166 bash
 [ 5903]  1268    26968      364      300 |        0      166 bash
 [ 5924]  1268    26968      364      424 |        0      197 bash
..... (continue to very much bash)

[10198]  1268    26968      368       20 |        0       97 bash
[10199]  1268    26968      368       20 |        0       97 bash
[10200]  1268    26968      368       20 |        0       97 bash
[10201]  1268    26968      368       20 |        0       97 bash
[10202]  1268    26968      368       20 |        0       97 bash
[10203]  1268    26968      368       20 |        0       97 bash
[10204]  1268    26968      368       20 |        0       97 bash
[10205]  1268    26968      368       20 |        0       97 bash
[10206]  1268    26968      368       20 |        0       97 bash
[10207]  1268    26968      364       20 |        0       96 bash
[10208]  1268    26968      364       20 |        0       96 bash
[10209]  1268    26968      368       20 |        0       97 bash
[10210]  1268    26968      368       20 |        0       97 bash
[10211]  1268    26968      368       20 |        0       97 bash
[10212]  1268    26968      368       20 |        0       97 bash
[10213]  1268    26968      368       20 |        0       97 bash
[10214]  1268    26968      368       20 |        0       97 bash
[10215]  1268    26968      368       20 |        0       97 bash
[10216]  1268    26968      368       20 |        0       97 bash
[10217]  1268    26968      368       20 |        0       97 bash
[10218]  1268    26968      368       20 |        0       97 bash
Memory cgroup out of memory: Kill process 1906 (memtoy) with score 25840 or sacrifice child
Killed process 1906 (memtoy) vsz:117268kB, anon-rss:102660kB, file-rss:700kB



At least, the patch author must define which problem is called as "forkbomb"
in this description.

I don't pulled this one.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
