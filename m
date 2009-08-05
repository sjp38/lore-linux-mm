Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F105E6B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 02:56:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n756up6R006313
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 5 Aug 2009 15:56:51 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A5DB845DE79
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:56:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 55E3245DE4D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:56:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 15A011DB8040
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:56:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D9831DB803A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:56:50 +0900 (JST)
Date: Wed, 5 Aug 2009 15:55:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
Message-Id: <20090805155500.b4692b27.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090805153701.b4f4385e.minchan.kim@barrios-desktop>
References: <20090805110107.5B97.A69D9226@jp.fujitsu.com>
	<20090805114004.459a7deb.minchan.kim@barrios-desktop>
	<20090805114650.5BA1.A69D9226@jp.fujitsu.com>
	<20090805145516.b2129f81.minchan.kim@barrios-desktop>
	<20090805150323.2624a68f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090805153701.b4f4385e.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Aug 2009 15:37:01 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:
> Hmm. I can't understand why it is troublesome. 
> I think it's related to moving oom_adj to singal_struct. 
> Unfortunately, I can't understand why we have to put oom_adj 
> in singal_struct?
> 
> That's why I have a question to Kosaki a while ago. 
> I can't understand it still. :-(
> 
> Could you elaborate it ?
> 

Current code is as following
==
  do_each_thread(g,p) {
	......
	p = badness();

	record p of highest badness.
  }
  p = higest badness thread.

  Scan all threads which shares mm_struct of p. and check oom_adj
  
==	
Assume a process which has 20000 threads. And 1 of thread has OOM_DISABLE.

Then, at worst, this scan will needs
	(1+2+3+....+20000) * (20000-1) scan. (when ignoring other processes)
even with your patch.

This means the kernel wastes enough long time that Cluster-Management-Software can
detetct this as livelock, and do reboot/cluster-fail-over.

Fixing livelock is not the last goal. I (we) would like to reduct stall time
to reasonable level. If we move oom_adj to signal_struct or mm_struct, scan-cost
will be only 20000. No retry at all.

And, if we can use for_each_process() rather than do_each_thread(),
scan-cost will be 1.

(BTW, "signal" struct is bad name I think, it should be "process" struct ;)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
