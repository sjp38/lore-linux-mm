Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9CC096B01D5
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:41:53 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BfpCa014399
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:51 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D951545DE4F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C098845DD71
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B81BE08001
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 506911DB8014
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
Message-Id: <20100606170713.8718.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -267,6 +259,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  			continue;
>  		if (mem && !task_in_mem_cgroup(p, mem))
>  			continue;
> +		if (!has_intersects_mems_allowed(p))
> +			continue;
>  
>  		/*
>  		 * This task already has access to memory reserves and is

now we have three places of oom filtering
  (1) select_bad_process
  (2) dump_tasks
  (3) oom_kill_task (when oom_kill_allocating_task==1 only)

this patch only add the check to (1). I think we need (2) and (3) too.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
