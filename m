Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 54E4E6B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 05:35:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4V9ZeDw029388
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 31 May 2010 18:35:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FB4745DE5D
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:35:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CB4245DE4E
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:35:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4224E1DB8038
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:35:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 023951DB803E
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:35:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/5] oom: select_bad_process: PF_EXITING check should take ->mm into account
In-Reply-To: <20100531182526.1843.A69D9226@jp.fujitsu.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com>
Message-Id: <20100531183335.1846.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 31 May 2010 18:35:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: Oleg Nesterov <oleg@redhat.com>
Subject: oom: select_bad_process: PF_EXITING check should take ->mm into account

select_bad_process() checks PF_EXITING to detect the task which is going
to release its memory, but the logic is very wrong.

	- a single process P with the dead group leader disables
	  select_bad_process() completely, it will always return
	  ERR_PTR() while P can live forever

	- if the PF_EXITING task has already released its ->mm
	  it doesn't make sense to expect it is goiing to free
	  more memory (except task_struct/etc)

Change the code to ignore the PF_EXITING tasks without ->mm.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [rebase to latest -mm]
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 070b713..c87a6f4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -287,7 +287,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if (p->flags & PF_EXITING) {
+		if ((p->flags & PF_EXITING) && p->mm) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
