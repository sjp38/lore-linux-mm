Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 596A16B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 17:08:33 -0500 (EST)
Received: by iajr24 with SMTP id r24so1736978iaj.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 14:08:32 -0800 (PST)
Date: Thu, 8 Mar 2012 14:08:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, hugetlb: add thread name and pid to SHM_HUGETLB
 mlock rlimit warning
In-Reply-To: <20120308135643.225920ad.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1203081400340.23632@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061825070.9015@chino.kir.corp.google.com> <20120308120238.c4486547.akpm@linux-foundation.org> <alpine.DEB.2.00.1203081333300.23632@chino.kir.corp.google.com> <20120308135643.225920ad.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 8 Mar 2012, Andrew Morton wrote:

> >  We have a get_task_comm() that does the task_lock() 
> > internally but requires a TASK_COMM_LEN buffer in the calling code.  It's 
> > just easier for the calling code to the task_lock() itself for a tiny 
> > little printk().
> 
> Well for a tiny little printk we could just omit the locking?  The
> printk() won't oops and once in a million years one person will see a
> garbled comm[] string?
> 

Sure, but task_lock() shouldn't be highly contended when the thread isn't 
forking or exiting (everything else is attaching/detaching from a cgroup 
or testing a mempolicy).  I've always added it (like in the oom killer for 
the same reason) just because the race exists.  Taking it for every thread 
on the system for one call to the oom killer has never slowed it down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
