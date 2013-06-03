Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CFC0A6B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 12:31:39 -0400 (EDT)
Received: by mail-wg0-f53.google.com with SMTP id m15so3378081wgh.8
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 09:31:38 -0700 (PDT)
Date: Mon, 3 Jun 2013 18:31:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130603163012.GA23257@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130601061151.GC15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Sat 01-06-13 02:11:51, Johannes Weiner wrote:
> @@ -2076,6 +2077,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *memcg)
>  {
>  	/* for filtering, pass "memcg" as argument. */
>  	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
> +	atomic_inc(&memcg->oom_wakeups);
>  }
>  
>  static void memcg_oom_recover(struct mem_cgroup *memcg)
[...]
> +	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> +	/* Only sleep if we didn't miss any wakeups since OOM */
> +	if (atomic_read(&memcg->oom_wakeups) == current->memcg_oom.wakeups)
> +		schedule();

On the way home it occured to me that the ordering might be wrong here.
The wake up can be lost here.
					__wake_up(memcg_oom_waitq)
					<preempted>
prepare_to_wait
atomic_read(&memcg->oom_wakeups)
					atomic_inc(oom_wakeups)

I guess we want atomic_inc before __wake_up, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
