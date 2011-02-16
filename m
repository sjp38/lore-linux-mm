Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A68DD8D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 22:15:31 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p1G3FQtE004726
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:15:26 -0800
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by wpaz24.hot.corp.google.com with ESMTP id p1G3Eifn024217
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:15:25 -0800
Received: by pxi9 with SMTP id 9so151358pxi.23
        for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:15:24 -0800 (PST)
Date: Tue, 15 Feb 2011 19:15:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110210090428.6c8a7c21.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102151906030.19953@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com> <20110210090428.6c8a7c21.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Thu, 10 Feb 2011, KAMEZAWA Hiroyuki wrote:

> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks!

> Hm. But I'm not sure how this will be used.
> 

Since this patch hasn't been added to -mm even with your acked-by, I'm 
assuming Andrew is waiting for an answer to this :)  I thought it was 
fairly well covered in the changelog, but I'll elaborate:

We can already give userspace a grace period to act before oom killing a 
task by utilizing memory.oom_control.  That's not what the oom killer 
delay addresses, however.  This addresses a very specific (and real) 
problem that occurs when userspace wants that grace period but is unable 
to respond, for whatever reason, to either increase the hard limit or 
allow the oom kill to proceed.  The possibility of that happening would 
cause that memcg to livelock because no forward progress could be made 
when oom, which is a negative result.  We don't have that possibility with 
the global oom killer since the kernel will always choose to act if memory 
freeing is not imminent: in other words, since we've opened the window for 
livelock because of an unreliable userspace via a kernel feature -- namely 
memory.oom_control -- then it's only responsible to provide an alternate 
means to configure the cgroup for the same grace period without risking 
livelock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
