Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E65358D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 19:25:25 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p1M0PNMp014962
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 16:25:23 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by hpaq1.eem.corp.google.com with ESMTP id p1M0PKWX014942
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 16:25:21 -0800
Received: by pvg7 with SMTP id 7so593629pvg.37
        for <linux-mm@kvack.org>; Mon, 21 Feb 2011 16:25:19 -0800 (PST)
Date: Mon, 21 Feb 2011 16:25:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
In-Reply-To: <4D61DA04.4060007@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102211617510.23557@chino.kir.corp.google.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com> <alpine.DEB.2.00.1102191745180.27722@chino.kir.corp.google.com> <4D61DA04.4060007@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org

On Mon, 21 Feb 2011, Li Zefan wrote:

> Unfortunately, as I looked into the code again I found cpuset_change_nodemask()
> is called by other functions that use the global cpuset_mems, so I
> think we'd better check the refcnt of cpuset_mems.
> 
> How about this:
> 
> [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
> 
> Those functions that use NODEMASK_ALLOC() can't propogate errno
> to users, so might fail silently.
> 
> Based on the fact that all of them are called with cgroup_mutex
> held, we fix this by using a global nodemask.
> 

If all of the functions that require a nodemask are protected by 
cgroup_mutex, then I think it would be much better to just statically 
allocate them within the function and avoid any nodemask in file scope.  
cpuset_mems cannot be shared so introducing it with a refcount would 
probably just be confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
