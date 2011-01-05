Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E42566B008A
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 02:58:02 -0500 (EST)
Date: Wed, 5 Jan 2011 16:51:34 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: + memcg-fix-deadlock-between-cpuset-and-memcg.patch added to
 -mm tree
Message-Id: <20110105165134.46d868f4.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <201101032131.p03LVTp8029638@imap1.linux-foundation.org>
References: <201101032131.p03LVTp8029638@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: balbir@in.ibm.com, bblum@andrew.cmu.edu, kamezawa.hiroyuki@gmail.com, menage@google.com, miaox@cn.fujitsu.com, rientjes@google.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

(resend with adding Cc: containers and linux-mm)

Hi, Andrew.

Thank you for picking up this patch.

But this version has a small race problem. This is a fix-up patch.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

We must clear "mc.moving_task" before waking up all waiters at the end of
task migration.

Otherwise, there can be a small race like:

        mem_cgroup_clear_mc()        |    mem_cgroup_wait_acct_move()
    ---------------------------------+-----------------------------------
          __mem_cgroup_clear_mc()    |
            wake_up_all()            |
                                     |    prepare_to_wait()
                                     |    if (mc.moving_task) -> true
                                     |      schedule()
                                     |      -> noone wakes it up.
          mc.moving_task = NULL      |

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b108b30..61678be 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4714,12 +4714,16 @@ static void mem_cgroup_clear_mc(void)
 {
 	struct mem_cgroup *from = mc.from;
 
+	/*
+	 * we must clear moving_task before waking up waiters at the end of
+	 * task migration.
+	 */
+	mc.moving_task = NULL;
 	__mem_cgroup_clear_mc();
 	spin_lock(&mc.lock);
 	mc.from = NULL;
 	mc.to = NULL;
 	spin_unlock(&mc.lock);
-	mc.moving_task = NULL;
 	mem_cgroup_end_move(from);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
