Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 890046B005A
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 05:58:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n74APBxg003216
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 4 Aug 2009 19:25:11 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 414E845DE55
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:25:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF61F45DE53
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:25:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C056FE08004
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:25:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B4B71DB803E
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:25:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for 2.6.31 0/4] fix oom_adj regression v2
Message-Id: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  4 Aug 2009 19:25:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The commit 2ff05b2b (oom: move oom_adj value) move oom_adj value to mm_struct.
It is very good first step for sanitize OOM.

However Paul Menage reported the commit makes regression to his job scheduler.
Current OOM logic can kill OOM_DISABLED process.

Why? His program has the code of similar to the following.

	...
	set_oom_adj(OOM_DISABLE); /* The job scheduler never killed by oom */
	...
	if (vfork() == 0) {
		set_oom_adj(0); /* Invoked child can be killed */
		execve("foo-bar-cmd")
	}
	....

vfork() parent and child are shared the same mm_struct. then above set_oom_adj(0) doesn't
only change oom_adj for vfork() child, it's also change oom_adj for vfork() parent.
Then, vfork() parent (job scheduler) lost OOM immune and it was killed.

Actually, fork-setting-exec idiom is very frequently used in userland program. We must
not break this assumption.

This patch series are slightly big, but we must fix any regression soon.



Sorting out OOM requirements:
-----------------------
  - select_bad_process() must select killable process.
    otherwise OOM might makes following livelock.
      1. select_bad_process() select unkillable process
      2. oom_kill_process() do no-op and return.
      3. exit out_of_memory and makes next OOM soon. then, goto 1 again.
  - vfork parent and child must not shared oom_adj.


My proposal
-----------------------
  - oom_adj become per-process property. it have been documented long time.
    but the implementaion was not correct.
  - oom_score also become per-process property. it makes oom logic simpler and faster.
  - remove bogus vfork() parent killing logic





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
