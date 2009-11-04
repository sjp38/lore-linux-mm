Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CAAED6B0062
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 19:05:15 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA405B4J026776
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 09:05:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DFBC945DE5B
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:05:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B19B45DE54
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:05:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D97E18009
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:05:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C383F1DB8063
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:05:06 +0900 (JST)
Date: Wed, 4 Nov 2009 09:02:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm][PATCH 2/6] oom-killer: count swap usage per process.
Message-Id: <20091104090225.54a70927.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911031144390.11821@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091102162526.c985c5a8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031144390.11821@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 11:47:23 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> > RSS usage is important information but one more information which
> > is often asked by users is "usage of swap".(user support team said.)
> > 
> > This patch counts swap entry usage per process and show it via
> > /proc/<pid>/status. I think status file is robust against new entry.
> > Then, it is the first candidate..
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Acked-by; David Rientjes <rientjes@google.com>
> 
> Thanks!  I think this should be added to -mm now while the remainder of 
> your patchset is developed and reviewed, it's helpful as an independent 
> change.
> 
> > Index: mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> > ===================================================================
> > --- mmotm-2.6.32-Nov2.orig/fs/proc/task_mmu.c
> > +++ mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> > @@ -17,7 +17,7 @@
> >  void task_mem(struct seq_file *m, struct mm_struct *mm)
> >  {
> >  	unsigned long data, text, lib;
> > -	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
> > +	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss, swap;
> >  
> >  	/*
> >  	 * Note: to minimize their overhead, mm maintains hiwater_vm and
> > @@ -36,6 +36,8 @@ void task_mem(struct seq_file *m, struct
> >  	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
> >  	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
> >  	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
> > +
> > +	swap = get_mm_counter(mm, swap_usage);
> >  	seq_printf(m,
> >  		"VmPeak:\t%8lu kB\n"
> >  		"VmSize:\t%8lu kB\n"
> 
> Not sure about this newline though.

I'll clean up more. Thank you for pointing out.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
