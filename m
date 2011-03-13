Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C23838D003B
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 20:12:06 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p2D1C44w018823
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:12:04 -0800
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by wpaz29.hot.corp.google.com with ESMTP id p2D1C2aB019653
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:12:02 -0800
Received: by pzk27 with SMTP id 27so691558pzk.26
        for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:12:02 -0800 (PST)
Date: Sat, 12 Mar 2011 17:11:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <20110312123413.GA18351@redhat.com>
Message-ID: <alpine.DEB.2.00.1103121709230.10317@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Sat, 12 Mar 2011, Oleg Nesterov wrote:

> > It's a problem, but not because of
> > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch.
> 
> It is, afaics. oom-killer can't ussume that a single PF_EXITING && p->mm
> thread is going to free the memory.
> 

We can add a check to see if a PF_EXITING thread will stall in the exit 
path as in your testcase, we do not need to filter threads that are still 
running that results in panics if nothing else is eligible in cpusets.

> > but its other threads do not and they trigger oom kills
> > themselves.  for_each_process() does not iterate over these threads and so
> > it finds no eligible threads to kill and then panics
> 
> Could you explain what do you mean? No need to kill these threads, they
> are already killed, we should wait until they all exit.
> 

Yes, and the check for PF_EXITING is intended to do exactly that (and 
give the thread access to memory reserves if it is trying to allocate 
memory itself).  The problem with your testcase is that the thread will 
indefinitely stall, so the appropriate fix is to detect that possibility 
and avoid the deferral if its possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
