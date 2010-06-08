Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3887F6B01D6
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:41:57 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BfsE5014431
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 501B145DE51
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1163A45DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E2DB4E08002
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B11BE08003
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 09/18] oom: add forkbomb penalty to badness heuristic
In-Reply-To: <alpine.DEB.2.00.1006010015220.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015220.29202@chino.kir.corp.google.com>
Message-Id: <20100607091034.875C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +	list_for_each_entry(child, &tsk->children, sibling) {

this loop only check childs that created by main-thread.
we need to iterate sub-threads created childs.

> +		struct task_cputime task_time;
> +		unsigned long runtime;
> +		unsigned long rss;
> +
> +		task_lock(child);
> +		if (!child->mm || child->mm == tsk->mm) {
> +			task_unlock(child);
> +			continue;
> +		}

need to use find_lock_task_mm().



> +		rss = get_mm_rss(child->mm);

need rss+swap for keeping consistency. I think.

> +		task_unlock(child);
> +
> +		thread_group_cputime(child, &task_time);
> +		runtime = cputime_to_jiffies(task_time.utime) +
> +			  cputime_to_jiffies(task_time.stime);
> +		/*
> +		 * Only threads that have run for less than a second are
> +		 * considered toward the forkbomb penalty, these threads rarely
> +		 * get to execute at all in such cases anyway.
> +		 */
> +		if (runtime < HZ) {
> +			child_rss += rss;
> +			forkcount++;
> +		}
> +	}
> +
> +	return forkcount > sysctl_oom_forkbomb_thres ?
> +				(child_rss / sysctl_oom_forkbomb_thres) : 0;

0 divide risk is there.
correct style is

	thres = sysctl_oom_forkbomb_thres
	if (!thres)
		return;
	child_rss / thres;

copying local variable is must.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
