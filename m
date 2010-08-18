Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AA78C6B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 22:13:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I2Dedb008906
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Aug 2010 11:13:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 390B73A62C4
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:13:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F42E1EF086
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:13:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E48681DB801D
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:13:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 766421DB8017
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:13:39 +0900 (JST)
Date: Wed, 18 Aug 2010 11:08:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v2 2/2] oom: kill all threads sharing oom killed task's
 mm
Message-Id: <20100818110846.439987fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008161814450.26680@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1008161814450.26680@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010 18:16:08 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's necessary to kill all threads that share an oom killed task's mm if
> the goal is to lead to future memory freeing.
> 
> This patch reintroduces the code removed in 8c5cd6f3 (oom: oom_kill
> doesn't kill vfork parent (or child)) since it is obsoleted.
> 
> It's now guaranteed that any task passed to oom_kill_task() does not
> share an mm with any thread that is unkillable.  Thus, we're safe to
> issue a SIGKILL to any thread sharing the same mm.
> 
> This is especially necessary to solve an mm->mmap_sem livelock issue
> whereas an oom killed thread must acquire the lock in the exit path while
> another thread is holding it in the page allocator while trying to
> allocate memory itself (and will preempt the oom killer since a task was
> already killed).  Since tasks with pending fatal signals are now granted
> access to memory reserves, the thread holding the lock may quickly
> allocate and release the lock so that the oom killed task may exit.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
