Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id E31F06B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 17:23:36 -0500 (EST)
Date: Thu, 8 Mar 2012 14:23:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, hugetlb: add thread name and pid to SHM_HUGETLB
 mlock rlimit warning
Message-Id: <20120308142335.e2dc17cb.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203081400340.23632@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061825070.9015@chino.kir.corp.google.com>
	<20120308120238.c4486547.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1203081333300.23632@chino.kir.corp.google.com>
	<20120308135643.225920ad.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1203081400340.23632@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 8 Mar 2012 14:08:30 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 8 Mar 2012, Andrew Morton wrote:
> 
> > >  We have a get_task_comm() that does the task_lock() 
> > > internally but requires a TASK_COMM_LEN buffer in the calling code.  It's 
> > > just easier for the calling code to the task_lock() itself for a tiny 
> > > little printk().
> > 
> > Well for a tiny little printk we could just omit the locking?  The
> > printk() won't oops and once in a million years one person will see a
> > garbled comm[] string?
> > 
> 
> Sure, but task_lock() shouldn't be highly contended when the thread isn't 
> forking or exiting (everything else is attaching/detaching from a cgroup 
> or testing a mempolicy).  I've always added it (like in the oom killer for 
> the same reason) just because the race exists.  Taking it for every thread 
> on the system for one call to the oom killer has never slowed it down.

I wasn't concerned about the performance side of things - just that
it's such a pain over such a silly thing.

btw, if the code had done

	printk_once(..., get_task_comm(...), ...)

the task_lock() would have been performed just a single time, rather
than every time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
