Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4B58F8D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 20:51:37 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p1K1pZ8n006243
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:35 -0800
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe19.cbf.corp.google.com with ESMTP id p1K1pX4K001025
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:34 -0800
Received: by pwj9 with SMTP id 9so188524pwj.34
        for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:33 -0800 (PST)
Date: Sat, 19 Feb 2011 17:51:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
In-Reply-To: <4D5C7ED1.2070601@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102191745180.27722@chino.kir.corp.google.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org

On Thu, 17 Feb 2011, Li Zefan wrote:

> Those functions that use NODEMASK_ALLOC() can't propogate errno
> to users, but will fail silently.
> 
> Since all of them are called with cgroup_mutex held, here we use
> a global nodemask_t variable.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

I like the idea and the comment is explicit enough that we don't need any 
refcounting to ensure double usage under cgroup_lock.  I think each 
function should be modified to use cpuset_mems directly, though, instead 
of defining local variables that indirectly access it which only serves to 
make this patch smaller.  Then we can ensure that all occurrences of 
cpuset_mems appear within the lock without being concerned about other 
references.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
