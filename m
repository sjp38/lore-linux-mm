Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 59A3A6B005D
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:35:41 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so825716pbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 17:35:40 -0700 (PDT)
Date: Wed, 30 May 2012 17:35:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
In-Reply-To: <20120530232004.GA15423@shutemov.name>
Message-ID: <alpine.DEB.2.00.1205301729490.25774@chino.kir.corp.google.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <20120530232004.GA15423@shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Thu, 31 May 2012, Kirill A. Shutemov wrote:

> > Why?  Because the information exported by /proc/meminfo is considered by 
> > applications to be static whereas the limit of a memcg may change without 
> > any knowledge of the application.
> 
> Memory hotplug does the same, right?
> 

Memory hotplug is a seperate topic, it changes the amount of physical 
memory that is available to the kernel, not any limitation of memory 
available to a set of tasks.  For memory hot-add, this does not 
automatically increase the memory.limit_in_bytes of any non-root memcg, 
the memory usage is still constrained as it was before the hotplug event.  
Thus, applications would want to depend on memory.{limit,usage}_in_bytes 
specifically to determine the amount of available memory even with 
CONFIG_MEMORY_HOTPLUG.

Also, under certain cirucmstances such as when a thread is oom killed, it 
may allocate memory in excess of its memcg limitation and this wouldn't be 
visible as available with this patch via /proc/meminfo.  Cpusets allows 
softwall allocations even when a thread is simply exiting on all nodes 
(and for GFP_ATOMIC allocations) and this also wouldn't be visible in 
/proc/meminfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
