Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 894016B0083
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 08:13:12 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n73CWg2N020526
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 3 Aug 2009 21:32:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C295C45DE52
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:32:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E9745DE4F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:32:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 752F61DB804A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:32:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B8F1DB803F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:32:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <alpine.DEB.2.00.0908030050160.30778@chino.kir.corp.google.com>
References: <20090803104244.b58220ba.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0908030050160.30778@chino.kir.corp.google.com>
Message-Id: <20090803212945.CC2F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  3 Aug 2009 21:32:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

Sorry for queue jumping. I have one question.


> > >  - /proc/pid/oom_score is inconsistent when the thread that set the
> > >    effective per-mm oom_adj exits and it is now obsolete since you have
> > >    no way to determine what the next effective oom_adj value shall be.
> > > 
> > plz re-caluculate it. it's not a big job if done in lazy way.
> > 
> 
> You can't recalculate it if all the remaining threads have a different 
> oom_adj value than the effective oom_adj value from the thread that is now 
> exited.  There is no assumption that, for instance, the most negative 
> oom_adj value shall then be used.  Imagine the effective oom_adj value 
> being +15 and a thread sharing the same memory has an oom_adj value of 
> -16.  Under no reasonable circumstance should the oom preference of the 
> entire thread then change to -16 just because its the side-effect of a 
> thread exiting.

Why do we need recaluculate AT thread exiting time?
it is only used when oom_score is readed or actual OOM happend.
both those are slow-path.


> 
> That's the _entire_ reason why we need consistency in oom_adj values so 
> that userspace is aware of how the oom killer really works and chooses 
> tasks.  I understand that it differs from the previously allowed behavior, 
> but those userspace applications need to be fixed if, for no other reason, 
> they are now consistent with how the oom killer kills tasks.  I think 
> that's a very worthwhile goal and the cost of moving to a new interface 
> such as /proc/pid/oom_adj_child to have the same inheritance property that 
> was available in the past is justified.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
