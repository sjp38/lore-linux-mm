Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 0038E6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 01:02:26 -0400 (EDT)
Received: by dakp5 with SMTP id p5so913107dak.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 22:02:26 -0700 (PDT)
Date: Wed, 30 May 2012 22:02:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
In-Reply-To: <4FC6D881.4090706@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com>
 <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com> <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com> <4FC6D881.4090706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Thu, 31 May 2012, Kamezawa Hiroyuki wrote:

> > It's not just a memcg issue, it would also be a cpusets issue.
> 
> I think you can add cpuset.meminfo.
> 

It's simple to find the same information by reading the per-node meminfo 
files in sysfs for each of the allowed cpuset mems.  This is why this 
approach has been nacked in the past, specifically by Paul Jackson when he 
implemented cpusets.

The bottomline is that /proc/meminfo is one of many global resource state 
interfaces and doesn't imply that every thread has access to the full 
resources.  It never has.  It's very simple for another thread to consume 
a large amount of memory as soon as your read() of /proc/meminfo completes 
and then that information is completely bogus.  We also don't want to 
virtualize every single global resource state interface, it would be never 
ending.

Applications that administer memory cgroups or cpusets can get this 
information very easily, each application within those memory cgroups or 
cpusets does not need it and should not rely on it: it provides no 
guarantee about future usage nor notifies the application when the amount 
of free memory changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
