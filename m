Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4362D6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 04:12:12 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o7I8C94N004257
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 01:12:09 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq5.eem.corp.google.com with ESMTP id o7I8C39q004595
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 01:12:08 -0700
Received: by pxi7 with SMTP id 7so185201pxi.11
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 01:12:02 -0700 (PDT)
Date: Wed, 18 Aug 2010 01:11:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 1/2] oom: avoid killing a task if a thread sharing
 its mm cannot be killed
In-Reply-To: <20100818125501.90db0770.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008180109450.7425@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com> <20100818110746.5c030b34.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008171925250.2823@chino.kir.corp.google.com> <20100818121137.20192c31.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008172038140.11263@chino.kir.corp.google.com> <20100818125501.90db0770.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > Is it worth adding
> > 
> > 	if (unlikely(current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN))
> > 		atomic_dec(&current->mm->oom_disable_count);
> > 
> > to exit_mm() under task_lock() to avoid the O(n^2) select_bad_process() on 
> > oom?  Or do you think that's too expensive?
> > 
> 
> Hmm, if this coutner is changed only under down_write(mmap_sem),
> simple 'int' counter is enough quick. 
> 

task->mm->oom_disable_count would be protected by task_lock(task) to pin 
the ->mm, which we already take in exit_mm() to set task->mm to NULL.  We 
can take task_lock() in the proc handler, oom killer, and exec() paths 
where we're interested in the accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
