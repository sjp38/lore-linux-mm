Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7JETHT5015991
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 00:29:17 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7JEUMbb262284
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 00:30:22 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7JEUMlu012908
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 00:30:22 +1000
Date: Tue, 19 Aug 2008 19:43:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
Message-ID: <20080819141344.GF25239@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jiri Slaby <jirislaby@gmail.com> [2008-08-14 22:16:53]:

> Hi,
> 
> found this in mmotm, a fix for
> mm-owner-fix-race-between-swap-and-exit.patch
>

Does the patch below fix your problem, it's against mmotm 19th August
2008.

 
Reported-by: jirislaby@gmail.com

Jiri reported a problem and saw an oops when the memrlimit-fix-race-with-swap
patch is applied. He sent his patch on top to fix the problem, but ran into
another issue. The root cause of the problem is that we are not suppose
to call task_cgroup on NULL tasks. This patch reverts Jiri's patch and
does not call task_cgroup if the passed task_struct (old) is NULL.


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 kernel/cgroup.c |    5 +++--
 kernel/exit.c   |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff -puN kernel/exit.c~memrlimit-fix-race-with-swap-oops kernel/exit.c
--- linux-2.6.27-rc3/kernel/exit.c~memrlimit-fix-race-with-swap-oops	2008-08-19 18:50:39.000000000 +0530
+++ linux-2.6.27-rc3-balbir/kernel/exit.c	2008-08-19 18:51:05.000000000 +0530
@@ -641,8 +641,8 @@ retry:
 	 * the callback and take action
 	 */
 	down_write(&mm->mmap_sem);
-	cgroup_mm_owner_callbacks(mm->owner, NULL);
 	mm->owner = NULL;
+	cgroup_mm_owner_callbacks(mm->owner, NULL);
 	up_write(&mm->mmap_sem);
 	return;
 
diff -puN kernel/cgroup.c~memrlimit-fix-race-with-swap-oops kernel/cgroup.c
--- linux-2.6.27-rc3/kernel/cgroup.c~memrlimit-fix-race-with-swap-oops	2008-08-19 18:50:39.000000000 +0530
+++ linux-2.6.27-rc3-balbir/kernel/cgroup.c	2008-08-19 18:55:38.000000000 +0530
@@ -2743,13 +2743,14 @@ void cgroup_fork_callbacks(struct task_s
  */
 void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
 {
-	struct cgroup *oldcgrp, *newcgrp = NULL;
+	struct cgroup *oldcgrp = NULL, *newcgrp = NULL;
 
 	if (need_mm_owner_callback) {
 		int i;
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
-			oldcgrp = task_cgroup(old, ss->subsys_id);
+			if (old)
+				oldcgrp = task_cgroup(old, ss->subsys_id);
 			if (new)
 				newcgrp = task_cgroup(new, ss->subsys_id);
 			if (oldcgrp == newcgrp)
diff -puN mm/memrlimitcgroup.c~memrlimit-fix-race-with-swap-oops mm/memrlimitcgroup.c
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
