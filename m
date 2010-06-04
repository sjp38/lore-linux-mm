Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E93246B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 06:54:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o54Asi5j015275
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Jun 2010 19:54:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 027B945DE6E
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3CE045DE60
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BBEAB1DB803A
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 747EE1DB8037
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 13/12] oom: dump_header() need tasklist_lock
In-Reply-To: <20100603152652.GA8743@redhat.com>
References: <20100603152350.725F.A69D9226@jp.fujitsu.com> <20100603152652.GA8743@redhat.com>
Message-Id: <20100604120844.72A4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Jun 2010 19:54:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> (off-topic)
> 
> out_of_memory() calls dump_header()->dump_tasks() lockless, we
> need tasklist.

Makes perfectly sense. Thank you!


================================================================
Commit 1b604d75(oom: dump stack and VM state when oom killer panics)
added dump_header() call to three places. But It forgot to add
the tasklist_lock. Now, dump_header() is called without the lock.
It is obviously inadequate.

This patch fixes it.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ad85e1b..2678a04 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -600,8 +600,8 @@ retry:
 
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		read_unlock(&tasklist_lock);
 		dump_header(NULL, gfp_mask, order, NULL);
+		read_unlock(&tasklist_lock);
 		panic("Out of memory and no killable processes...\n");
 	}
 
@@ -633,7 +633,9 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		return;
 
 	if (sysctl_panic_on_oom == 2) {
+		read_lock(&tasklist_lock);
 		dump_header(NULL, gfp_mask, order, NULL);
+		read_unlock(&tasklist_lock);
 		panic("out of memory. Compulsory panic_on_oom is selected.\n");
 	}
 
@@ -664,6 +666,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom) {
 			dump_header(NULL, gfp_mask, order, NULL);
+			read_unlock(&tasklist_lock);
 			panic("out of memory. panic_on_oom is selected\n");
 		}
 		/* Fall-through */
-- 
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
