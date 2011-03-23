Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 39D838D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 21:27:42 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 59AA43EE0C1
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:27:37 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 395C545DE54
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:27:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1498245DE4E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:27:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 05A94E78004
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:27:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C28C11DB803E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:27:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] oom: create oom autogroup
In-Reply-To: <AANLkTikN835dfU9xozTWbOh6cjSEG0XgU_Ayn+dRqDug@mail.gmail.com>
References: <20110322200759.B067.A69D9226@jp.fujitsu.com> <AANLkTikN835dfU9xozTWbOh6cjSEG0XgU_Ayn+dRqDug@mail.gmail.com>
Message-Id: <20110323102738.1AC2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 23 Mar 2011 10:27:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mike Galbraith <efault@gmx.de>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>

> On Tue, Mar 22, 2011 at 8:08 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > When plenty processes (eg fork bomb) are running, the TIF_MEMDIE task
> > never exit, at least, human feel it's never. therefore kernel become
> > hang-up.
> >
> > "perf sched" tell us a hint.
> >
> > A ------------------------------------------------------------------------------
> > A Task A  A  A  A  A  A  A  A  A | A  Runtime ms A | Average delay ms | Maximum delay ms |
> > A ------------------------------------------------------------------------------
> > A python:1754 A  A  A  A  A  | A  A  A 0.197 ms | avg: 1731.727 ms | max: 3433.805 ms |
> > A python:1843 A  A  A  A  A  | A  A  A 0.489 ms | avg: 1707.433 ms | max: 3622.955 ms |
> > A python:1715 A  A  A  A  A  | A  A  A 0.220 ms | avg: 1707.125 ms | max: 3623.246 ms |
> > A python:1818 A  A  A  A  A  | A  A  A 2.127 ms | avg: 1527.331 ms | max: 3622.553 ms |
> > A ...
> > A ...
> >
> > Processes flood makes crazy scheduler delay. and then the victim process
> > can't run enough. Grr. Should we do?
> >
> > Fortunately, we already have anti process flood framework, autogroup!
> > This patch reuse this framework and avoid kernel live lock.
> 
> That's cool idea but I have a concern.
> 
> You remove boosting priority in [2/5] and move victim tasks into autogroup.
> If I understand autogroup right, victim process and threads in the
> process take less schedule chance than now.

Right. Icky cpu-cgroup rt-runtime default enforce me to seek another solution.
Today, I got private mail from Luis and he seems to have another improvement
idea. so, I might drop this patch if his one works fine.

> Could it make unnecessary killing of other tasks?
> I am not sure. Just out of curiosity.

If you are talking about OOM serialization, It isn't. I don't change
OOM serialization stuff. at least for now.
If you are talking about scheduler fairness, both current and this patch
have scheduler unfairness. But that's ok. 1) When OOM situation, scheduling
fairness has been broken already by heavy memory reclaim effort 2) autogroup
mean to change scheduling grouping *automatically*. then, the patch change it
again for exiting memory starvation.

> 
> Thanks for nice work, Kosaki.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
