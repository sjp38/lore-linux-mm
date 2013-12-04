Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id E3DCC6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 22:35:01 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so6387327bkz.33
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 19:35:01 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id le2si2524190bkb.290.2013.12.03.19.35.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 19:35:00 -0800 (PST)
Date: Tue, 3 Dec 2013 22:34:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131204033449.GX3556@cmpxchg.org>
References: <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
 <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <20131202200221.GC5524@dhcp22.suse.cz>
 <20131202212500.GN22729@cmpxchg.org>
 <20131203120454.GA12758@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, Dec 03, 2013 at 03:50:41PM -0800, David Rientjes wrote:
> On Tue, 3 Dec 2013, Michal Hocko wrote:
> 
> > OK, as it seems that the notification part is too controversial, how
> > would you like the following? It reverts the notification part and still
> > solves the fault on exit path. I will prepare the full patch with the
> > changelog if this looks reasonable:
> 
> Um, no, that's not satisfactory because it obviously does the check after 
> mem_cgroup_oom_notify().  There is absolutely no reason why userspace 
> should be woken up when current simply needs access to memory reserves to 
> exit.  You can already get such notification by memory thresholds at the 
> memcg limit.
> 
> I'll repeat: Section 10 of Documentation/cgroups/memory.txt specifies what 
> userspace should do when waking up; one of those options is not "check if 
> the memcg is still actually oom in a short period of time once a charging 
> task with a pending SIGKILL or in the exit path has been able to exit."  
> Users of this interface typically also disable the memcg oom killer 
> through the same file, it's ludicrous to put the responsibility on 
> userspace to determine if the wakeup is actionable and requires it to 
> intervene in one of the methods listed in section 10.

Kind of a bummer that you haven't read anything I wrote...

But here is a patch that defers wakeups until we know for sure that
userspace action is required:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f1a0ae6..cc6adac 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2254,8 +2254,17 @@ bool mem_cgroup_oom_synchronize(bool handle)
 
 	locked = mem_cgroup_oom_trylock(memcg);
 
+#if 0
+	/*
+	 * XXX: An unrelated task in the group might exit at any time,
+	 * making the OOM kill unnecessary.  We don't want to wake up
+	 * the userspace handler unless we are certain it needs to
+	 * intervene, so disable notifications until we solve the
+	 * halting problem.
+	 */
 	if (locked)
 		mem_cgroup_oom_notify(memcg);
+#endif
 
 	if (locked && !memcg->oom_kill_disable) {
 		mem_cgroup_unmark_under_oom(memcg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
