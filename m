Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A2BA08D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:43:14 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p27NhA0Z021169
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 15:43:10 -0800
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by wpaz29.hot.corp.google.com with ESMTP id p27NgooC024346
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 15:43:09 -0800
Received: by pzk30 with SMTP id 30so1267468pzk.31
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 15:43:08 -0800 (PST)
Date: Mon, 7 Mar 2011 15:43:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <20110307135228.aad5a97d.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103071537270.21964@chino.kir.corp.google.com>
References: <1299286307-4386-1-git-send-email-avagin@openvz.org> <20110306193519.49DD.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1103061400170.23737@chino.kir.corp.google.com> <AANLkTi=d+eZxg_NgNWa7roo=1YQS06=EaWJzjseL_Hhs@mail.gmail.com>
 <alpine.DEB.2.00.1103071234480.10264@chino.kir.corp.google.com> <20110307135228.aad5a97d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Vagin <avagin@openvz.org>
Cc: Andrew Vagin <avagin@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 7 Mar 2011, Andrew Morton wrote:

> Andrew's v2 doesn't apply on top of
> oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch and I'm
> disinclined to fix that up and merge some untested patch combination.
> 

Ok.  Andrey, I rebased your patch on top of the latest -mm tree 
(mmotm-2011-03-02-16-52 with 
oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch from 
http://marc.info/?l=linux-mm-commits&m=129953480527038&q=raw) and rewrote 
the changelog.  They'll both apply on top of Linus' -git even without 
mmotm.  Could you try this out on your testcase?

Thanks!


oom: skip zombies when iterating tasklist

From: Andrey Vagin <avagin@openvz.org>

We shouldn't defer oom killing if a thread has already detached its ->mm
and still has TIF_MEMDIE set.  Memory needs to be freed, so find kill
other threads that pin the same ->mm or find another task to kill.

Signed-off-by: Andrey Vagin <avagin@openvz.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -299,6 +299,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	do_each_thread(g, p) {
 		unsigned int points;
 
+		if (!p->mm)
+			continue;
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
 
@@ -324,7 +326,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if ((p->flags & PF_EXITING) && p->mm) {
+		if (p->flags & PF_EXITING) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
