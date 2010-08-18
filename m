Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E728A6B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 22:36:10 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o7I2a8GP001828
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 19:36:08 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by kpbe12.cbf.corp.google.com with ESMTP id o7I2a6bj018061
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 19:36:07 -0700
Received: by pwi5 with SMTP id 5so140248pwi.26
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 19:36:06 -0700 (PDT)
Date: Tue, 17 Aug 2010 19:36:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 1/2] oom: avoid killing a task if a thread sharing
 its mm cannot be killed
In-Reply-To: <20100818110746.5c030b34.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008171925250.2823@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com> <20100818110746.5c030b34.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > The oom killer's goal is to kill a memory-hogging task so that it may
> > exit, free its memory, and allow the current context to allocate the
> > memory that triggered it in the first place.  Thus, killing a task is
> > pointless if other threads sharing its mm cannot be killed because of its
> > /proc/pid/oom_adj or /proc/pid/oom_score_adj value.
> > 
> > This patch checks all user threads on the system to determine whether
> > oom_badness(p) should return 0 for p, which means it should not be killed.
> > If a thread shares p's mm and is unkillable, p is considered to be
> > unkillable as well.
> > 
> > Kthreads are not considered toward this rule since they only temporarily
> > assume a task's mm via use_mm().
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks!

> Thank you. BTW, do you have good idea for speed-up ?
> This code seems terribly slow when a system has many processes.
> 

I was thinking about adding an "unsinged long oom_kill_disable_count" to 
struct mm_struct that would atomically increment anytime a task attached 
to it had a signal->oom_score_adj of OOM_SCORE_ADJ_MIN.

The proc handler when changing /proc/pid/oom_score_adj would inc or dec 
the counter depending on the new value, and exit_mm() would dec the 
counter if current->signal->oom_score_adj is OOM_SCORE_ADJ_MIN.

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
