Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD6AA8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:28:00 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p29LRurG020119
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 13:27:57 -0800
Received: from ywa8 (ywa8.prod.google.com [10.192.1.8])
	by wpaz1.hot.corp.google.com with ESMTP id p29LRtYo015203
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 13:27:55 -0800
Received: by ywa8 with SMTP id 8so446178ywa.8
        for <linux-mm@kvack.org>; Wed, 09 Mar 2011 13:27:55 -0800 (PST)
Date: Wed, 9 Mar 2011 13:27:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] memcg: give current access to memory reserves if it's trying
 to die
In-Reply-To: <alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1103091327260.15068@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com> <20110307171853.c31ec416.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
 <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com>
 <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com> <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com>
 <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com> <20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

When a memcg is oom and current has already received a SIGKILL, then give
it access to memory reserves with a higher scheduling priority so that it
may quickly exit and free its memory.

This is identical to the global oom killer and is done even before
checking for panic_on_oom: a pending SIGKILL here while panic_on_oom is
selected is guaranteed to have come from userspace; the thread only needs
access to memory reserves to exit and thus we don't unnecessarily panic
the machine until the kernel has no last resort to free memory.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -537,6 +537,17 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	unsigned int points = 0;
 	struct task_struct *p;
 
+	/*
+	 * If current has a pending SIGKILL, then automatically select it.  The
+	 * goal is to allow it to allocate so that it may quickly exit and free
+	 * its memory.
+	 */
+	if (fatal_signal_pending(current)) {
+		set_thread_flag(TIF_MEMDIE);
+		boost_dying_task_prio(current, NULL);
+		return;
+	}
+
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
 	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
