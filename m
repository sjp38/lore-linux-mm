Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 9230C6B005C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 10:51:01 -0400 (EDT)
Received: by yenr5 with SMTP id r5so2979060yen.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 07:51:00 -0700 (PDT)
Message-ID: <4FFEE452.40300@gmail.com>
Date: Thu, 12 Jul 2012 22:50:58 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 3/5] mm, memcg: introduce own oom handler to iterate only
 over its own threads
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291405500.6040@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206291405500.6040@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On 06/30/2012 05:06 AM, David Rientjes wrote:
> The global oom killer is serialized by the zonelist being used in the
> page allocation.  Concurrent oom kills are thus a rare event and only
> occur in systems using mempolicies and with a large number of nodes.
>
> Memory controller oom kills, however, can frequently be concurrent since
> there is no serialization once the oom killer is called for oom
> conditions in several different memcgs in parallel.
>
> This creates a massive contention on tasklist_lock since the oom killer
> requires the readside for the tasklist iteration.  If several memcgs are
> calling the oom killer, this lock can be held for a substantial amount of
> time, especially if threads continue to enter it as other threads are
> exiting.
>
> Since the exit path grabs the writeside of the lock with irqs disabled in
> a few different places, this can cause a soft lockup on cpus as a result
> of tasklist_lock starvation.
>
> The kernel lacks unfair writelocks, and successful calls to the oom
> killer usually result in at least one thread entering the exit path, so
> an alternative solution is needed.
>
> This patch introduces a seperate oom handler for memcgs so that they do
> not require tasklist_lock for as much time.  Instead, it iterates only
> over the threads attached to the oom memcg and grabs a reference to the
> selected thread before calling oom_kill_process() to ensure it doesn't
> prematurely exit.
>
> This still requires tasklist_lock for the tasklist dump, iterating
> children of the selected process, and killing all other threads on the
> system sharing the same memory as the selected victim.  So while this
> isn't a complete solution to tasklist_lock starvation, it significantly
> reduces the amount of time that it is held.
>

Looks good.
You can add Reviewed-by: Sha Zhengju <handai.szj@taobao.com>

Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
