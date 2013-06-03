Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 3EC586B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 14:00:12 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so990436pab.22
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 11:00:11 -0700 (PDT)
Date: Mon, 3 Jun 2013 11:00:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130531144636.6b34c6ba48105482d1241a40@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1306031049070.7956@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com> <20130531144636.6b34c6ba48105482d1241a40@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 31 May 2013, Andrew Morton wrote:

> > Admins may set the oom killer delay using the new interface:
> > 
> > 	# echo 60000 > memory.oom_delay_millisecs
> > 
> > This will defer oom killing to the kernel only after 60 seconds has
> > elapsed by putting the task to sleep for 60 seconds.
> 
> How often is that delay actually useful, in the real world?
> 
> IOW, in what proportion of cases does the system just remain stuck for
> 60 seconds and then get an oom-killing?
> 

It wouldn't be the system, it would just be the oom memcg that would be 
stuck.  We actually use 10s by default, but it's adjustable for users in 
their own memcg hierarchies.  It gives just enough time for userspace to 
deal with the situation and then defer to the kernel if it's unresponsive, 
this tends to happen quite regularly when you have many, many servers.  
Same situation if the userspace oom handler has died and isn't running, 
perhaps because of its own memory constraints (everything on our systems 
is memory constrained).  Obviously it isn't going to reenable the oom 
killer before it dies from SIGSEGV.

I'd argue that the current functionality that allows users to disable the 
oom killer for a memcg indefinitely is a bit ridiculous.  It requires 
admin intervention to fix such a state and it would be pointless to have 
an oom memcg for a week, a month, a year, just completely deadlocked on 
making forward progress and consuming resources.

memory.oom_delay_millisecs in my patch is limited to MAX_SCHEDULE_TIMEOUT 
just as a sanity check since we currently allow indefinite oom killer 
disabling.  I think if we were to rethink disabling the oom killer 
entirely via memory.oom_control and realize such a condition over a 
prolonged period is insane then this memory.oom_delay_millisecs ceiling 
would be better defined as something in minutes.

At the same time, we really like userspace oom notifications so users can 
implement their own handlers.  So where's the compromise between instantly 
oom killing something and waiting forever for userspace to respond?  My 
suggestion is memory.oom_delay_millisecs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
