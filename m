Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 093DC6B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 16:58:26 -0400 (EDT)
Date: Thu, 21 Jul 2011 13:58:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-Id: <20110721135817.baab2a2c.akpm@linux-foundation.org>
In-Reply-To: <44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
	<44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed, 13 Jul 2011 13:05:49 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> @@ -1893,6 +1942,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)

does:

: 	memcg_wakeup_oom(mem);
: 	mutex_unlock(&memcg_oom_mutex);
: 
: 	mem_cgroup_unmark_under_oom(mem);
: 
: 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
: 		return false;
: 	/* Give chance to dying process */
: 	schedule_timeout(1);
: 	return true;
: }

Calling schedule_timeout() in state TASK_RUNNING is equivalent to
calling schedule() and then pointlessly wasting some CPU cycles.

Someone might want to take a look at that, and wonder why this bug
wasn't detected in testing ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
