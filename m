Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B3B3C6B005C
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 06:04:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6UA43C9026993
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Jul 2009 19:04:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4957745DE4F
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 19:04:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1716645DE52
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 19:04:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C491EEF8001
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 19:04:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 77AD81DB8041
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 19:04:02 +0900 (JST)
Date: Thu, 30 Jul 2009 19:02:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
Message-Id: <20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	<20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Jul 2009 02:31:04 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 30 Jul 2009, KAMEZAWA Hiroyuki wrote:
> 
> > 1. IIUC, the name is strange.
> > 
> > At job scheduler, which does this.
> > 
> > if (vfork() == 0) {
> > 	/* do some job */
> > 	execve(.....)
> > }
> > 
> > Then, when oom_adj_child can be effective is after execve().
> > IIUC, the _child_ means a process created by vfork().
> > 
> 
> It's certainly a difficult thing to name and I don't claim that "child" is 
> completely accurate since, as you said, vfork'd tasks are also children 
> of the parent yet they share the same oom_adj value since it's an 
> attribute of the shared mm.
> 
> If you have suggestions for a better name, I'd happily ack it.
> 

Simply, reset_oom_adj_at_new_mm_context or some.

> > 2. More simple plan is like this, IIUC.
> > 
> >   fix oom-killer's select_bad_process() not to be in deadlock.
> > 
> 
> Alternate ideas?
> 
At brief thiking.

1. move oom_adj from mm_struct to signal struct. or somewhere.
   (see copy_signal())
   Then,
    - all threads in a process will have the same oom_adj.
    - vfork()'ed thread will inherit its parent's oom_adj.   
    - vfork()'ed thread can override oom_adj of its own.

    In other words, oom_adj is shared when CLONE_PARENT is not set.

2. rename  mm_struct's oom_adj as shadow_oom_adj.

   update this shadow_oom_adj as the highest oom_adj among
   the values all threads share this mm_struct have.
   This update is done when
   - mm_init()
   - oom_adj is written.

   User's 
   # echo XXXX > /proc/<x>/oom_adj
   is not necessary to be very very fast.

   I don't think a process which calls vfork() is multi-threaded.

3. use shadow_oom_adj in select_bad_process().



> > rather than this new stupid interface.
> > 
> 
> Well, thank you.  Regardless of whether you think it's stupid or not, it 
> doesn't allow you to livelock the kernel in a very trivial way when the 
> oom killer gets invoked prior to execve() and the parent is OOM_DISABLE.
> 


just plz consider more.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
