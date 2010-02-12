Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 211F26B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 04:58:19 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o1C9wF0k028046
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 01:58:15 -0800
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by spaceape9.eur.corp.google.com with ESMTP id o1C9wDAD022963
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 01:58:14 -0800
Received: by pxi14 with SMTP id 14so1509739pxi.20
        for <linux-mm@kvack.org>; Fri, 12 Feb 2010 01:58:12 -0800 (PST)
Date: Fri, 12 Feb 2010 01:58:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 5/7 -mm] oom: replace sysctls with quick mode
In-Reply-To: <20100212092634.60a76cf9.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002120150380.22883@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100229250.8001@chino.kir.corp.google.com> <20100212092634.60a76cf9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > Two VM sysctls, oom dump_tasks and oom_kill_allocating_task, were
> > implemented for very large systems to avoid excessively long tasklist
> > scans.  The former suppresses helpful diagnostic messages that are
> > emitted for each thread group leader that are candidates for oom kill
> > including their pid, uid, vm size, rss, oom_adj value, and name; this
> > information is very helpful to users in understanding why a particular
> > task was chosen for kill over others.  The latter simply kills current,
> > the task triggering the oom condition, instead of iterating through the
> > tasklist looking for the worst offender.
> > 
> > Both of these sysctls are combined into one for use on the aforementioned
> > large systems: oom_kill_quick.  This disables the now-default
> > oom_dump_tasks and kills current whenever the oom killer is called.
> > 
> > The oom killer rewrite is the perfect opportunity to combine both sysctls
> > into one instead of carrying around the others for years to come for
> > nothing else than legacy purposes.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> seems reasonable..but how old these APIs are ? Replacement is ok ?
> 

I'm not concerned about /proc/sys/vm/oom_dump_tasks because it was 
disabled by default and is now enabled by default (unless the user sets 
this new /proc/sys/vm/oom_kill_quick).  So existing users of 
oom_dump_tasks will just have their write fail but identical behavior as 
before.

/proc/sys/vm/oom_kill_allocating_task is different since it now requires 
enabling /proc/sys/vm/oom_kill_quick, but I think there are such few users 
(SGI originally requested it a couple years ago when we started scanning 
the tasklist for CONSTRAINT_CPUSET in 2.6.24) and the side-effect of not 
enabling it is minimal, it's just a long delay at oom kill time because 
they must scan the tasklist.  Therefore, I don't see it as a major problem 
that will cause large disruptions, instead I see it as a great opportunity 
to get rid of one more sysctl without taking away functionality.

> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
