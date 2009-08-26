Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 197CC6B0055
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 05:32:50 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7Q9Wn51008187
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Aug 2009 18:32:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1991545DE52
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:32:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D8E8E45DE51
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:32:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B6CB1DB803C
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:32:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 37710E08001
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:32:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 0/4] per-process OOM kill v3
Message-Id: <20090826182634.3968.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Aug 2009 18:32:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Changelog
  since v2
    - rebase to latest mmotm
    - fixed strstrip abuse
    - oom_adjust_write() use strict_strtol() instead simple_strtol()
    - remove unnecessary signal lock (pointed by Oleg)


--------------------------------------------------------
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

This patch moves oom_adj to signal_struct instead mm_struct. signal_struct is
shared by thread but isn't shared vfork.

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
