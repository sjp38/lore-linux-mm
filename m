Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A03816B0095
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 04:28:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n738l7Ll025872
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 3 Aug 2009 17:47:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C6FB45DE4F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:47:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 10BE645DE50
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:47:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D292DE08008
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:47:06 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E3091DB8041
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:47:06 +0900 (JST)
Date: Mon, 3 Aug 2009 17:45:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
Message-Id: <20090803174519.74673413.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0908030107110.30778@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	<20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
	<20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
	<20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
	<7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com>
	<77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
	<20090803104244.b58220ba.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0908030050160.30778@chino.kir.corp.google.com>
	<20090803170217.e98b2e46.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0908030107110.30778@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009 01:08:42 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 3 Aug 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > You can't recalculate it if all the remaining threads have a different 
> > > oom_adj value than the effective oom_adj value from the thread that is now 
> > > exited.  
> > 
> > Then, crazy google apps pass different oom_adjs to each thread ?
> > And, threads other than thread-group-leader modifies its oom_adj.
> > 
> 
> Nope, but I'm afraid you've just made my point for me: it shows that 
> oom_adj really isn't sanely used as a per-thread attribute and actually 
> only represents a preference on oom killing a quantity of memory in all 
> other cases other than vfork() -> change /proc/pid-of-child/oom_adj -> 
> exec() for which we now appropriately have /proc/pid/oom_adj_child for.
> 
Maybe you're man I can't persuade. but making progress will be necessary.

The most ugly thing which annoies me is this part. 

@@ -679,6 +679,7 @@ good_mm:                    #  a label in copy_mm.
 
 	tsk->mm = mm;
 	tsk->active_mm = mm;
+	tsk->oom_adj_child = mm->oom_adj;
 	return 0;

Why ?

I wonder oom_adj_exec "change oom_adj to this value when execve() is called"
is much more straightforward, simple and easy to understand than oom_adj_child.

"just inherit at fork, change at exec" is an usual manner, I think.
If oom_adj_exec rather than oom_adj_child, I won't complain, more.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
