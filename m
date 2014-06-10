Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 85ED46B0114
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:37:17 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id tr6so2985610ieb.29
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:37:17 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id ph4si41051350icc.20.2014.06.10.15.37.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 15:37:16 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id h18so2243302igc.10
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:37:16 -0700 (PDT)
Date: Tue, 10 Jun 2014 15:37:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
In-Reply-To: <5397194B.9010606@1h.com>
Message-ID: <alpine.DEB.2.02.1406101530100.32203@chino.kir.corp.google.com>
References: <5396ED66.7090401@1h.com> <20140610115254.GA25631@dhcp22.suse.cz> <5397194B.9010606@1h.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marian Marinov <mm@1h.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 Jun 2014, Marian Marinov wrote:

> >> During these OOM states the load of the machine gradualy increases from 25 up to 120 in the interval of
> >> 10minutes.
> >> 
> >> Once we manually bring down the memory usage of a container(killing some tasks) the load drops down to 25 within
> >> 5 to 7 minutes.
> > 
> > So the OOM killer is not able to find a victim to kill?
> 
> It was constantly killing tasks. 245 oom invocations in less then 6min for that particular cgroup. With top 61 oom
> invocations in one minute.
> 
> It was killing... In that particular case, the problem was a web server that was under attack. New php processes was
> spawned very often and instead of killing each newly created process(which is allocating memory) the kernel tries to
> find more suitable task. Which in this case was not desired.
> 

This is a forkbomb problem, then, that causes processes to constantly be 
reforked and the memcg go out of memory immediately after another process 
has been killed for the same reason.

Enabling oom_kill_allocating_task (or its identical behavior targeted for 
a specific memcg or memcg hierarchy) would result in random kills of your 
processes, whichever process is the unlucky one to be allocating at the 
time would get killed as long as it wasn't oom disabled.  The only benefit 
in this case would be that the oom killer wouldn't need to iterate 
processes, but there's nothing to suggest that your problem -- the fact 
that you're under a forkbomb -- would be fixed.

If, once the oom killer has killed something, another process is 
immediately forked, charges the memory that was just freed by the oom 
killer, and hits the limit again, then that's outside the scope of the oom 
killer.

> >> I read the whole thread from 2012 but I do not see the expected behavior that is described by the people that
> >> commented the issue.
> > 
> > Why do you think that killing the allocating task would be helpful in your case?
> 
> As mentioned above, the usual case with the hosting companies is that, the allocating task should not be allowed to
> run. So killing it is the proper solution there.
> 

That's not what the oom killer does: it finds the process that is using 
the most amount of memory and is eligible for kill and it is killed.  That 
prevents memory leakers from killing everything else attached to the memcg 
or on the system and results in one process being killed instead of many 
processes.  Userspace can tune the selection of processes with 
/proc/pid/oom_score_adj.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
