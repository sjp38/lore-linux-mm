Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 10B2C6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 14:47:36 -0500 (EST)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id nA3JlU5o005492
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 19:47:31 GMT
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by zps38.corp.google.com with ESMTP id nA3JlRvD017153
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 11:47:28 -0800
Received: by pwj6 with SMTP id 6so2915159pwj.22
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 11:47:27 -0800 (PST)
Date: Tue, 3 Nov 2009 11:47:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][-mm][PATCH 2/6] oom-killer: count swap usage per
 process.
In-Reply-To: <20091102162526.c985c5a8.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031144390.11821@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com> <20091102162526.c985c5a8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:

> Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> RSS usage is important information but one more information which
> is often asked by users is "usage of swap".(user support team said.)
> 
> This patch counts swap entry usage per process and show it via
> /proc/<pid>/status. I think status file is robust against new entry.
> Then, it is the first candidate..
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by; David Rientjes <rientjes@google.com>

Thanks!  I think this should be added to -mm now while the remainder of 
your patchset is developed and reviewed, it's helpful as an independent 
change.

> Index: mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> ===================================================================
> --- mmotm-2.6.32-Nov2.orig/fs/proc/task_mmu.c
> +++ mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> @@ -17,7 +17,7 @@
>  void task_mem(struct seq_file *m, struct mm_struct *mm)
>  {
>  	unsigned long data, text, lib;
> -	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
> +	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss, swap;
>  
>  	/*
>  	 * Note: to minimize their overhead, mm maintains hiwater_vm and
> @@ -36,6 +36,8 @@ void task_mem(struct seq_file *m, struct
>  	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
>  	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
>  	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
> +
> +	swap = get_mm_counter(mm, swap_usage);
>  	seq_printf(m,
>  		"VmPeak:\t%8lu kB\n"
>  		"VmSize:\t%8lu kB\n"

Not sure about this newline though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
