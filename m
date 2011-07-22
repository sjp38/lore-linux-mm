Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 851576B00EA
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:23:09 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 22D133EE0BC
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:23:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7E1E45DEE5
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:23:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1AD245DEE3
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:23:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C68B81DB803B
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:23:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 909EB1DB8037
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:23:05 +0900 (JST)
Date: Fri, 22 Jul 2011 09:15:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-Id: <20110722091557.f78a7a9e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110721135817.baab2a2c.akpm@linux-foundation.org>
References: <cover.1310732789.git.mhocko@suse.cz>
	<44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
	<20110721135817.baab2a2c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 13:58:17 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 13 Jul 2011 13:05:49 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > @@ -1893,6 +1942,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> 
> does:
> 
> : 	memcg_wakeup_oom(mem);
> : 	mutex_unlock(&memcg_oom_mutex);
> : 
> : 	mem_cgroup_unmark_under_oom(mem);
> : 
> : 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> : 		return false;
> : 	/* Give chance to dying process */
> : 	schedule_timeout(1);
> : 	return true;
> : }
> 
> Calling schedule_timeout() in state TASK_RUNNING is equivalent to
> calling schedule() and then pointlessly wasting some CPU cycles.
> 
Ouch (--;

> Someone might want to take a look at that, and wonder why this bug
> wasn't detected in testing ;)
> 
I wonder just removing this is okay....because we didn't noticed this
in our recent oom tests. 

I'll do some.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
