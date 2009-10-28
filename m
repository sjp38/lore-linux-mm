Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B0B96B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 05:01:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S91FhF023158
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 18:01:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 254E045DE56
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:01:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBE4C45DE54
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:01:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0F18EF8003
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:01:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CF1BE08001
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:01:14 +0900 (JST)
Date: Wed, 28 Oct 2009 17:58:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] oom_kill: use rss value instead of vm size for badness
Message-Id: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, aarcange@redhat.com, vedran.furac@gmail.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I may add more tweaks based on this. But simple start point as this patch
will be good. This patch is based on mmotm + Kosaki's
http://marc.info/?l=linux-kernel&m=125669809305167&w=2

Test results on various environment are appreciated.

Regards.
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It's reported that OOM-Killer kills Gnone/KDE at first...
And yes, we can reproduce it easily.

Now, oom-killer uses mm->total_vm as its base value. But in recent
applications, there are a big gap between VM size and RSS size.
Because
  - Applications attaches much dynamic libraries. (Gnome, KDE, etc...)
  - Applications may alloc big VM area but use small part of them.
    (Java, and multi-threaded applications has this tendency because
     of default-size of stack.)

I think using mm->total_vm as score for oom-kill is not good.
By the same reason, overcommit memory can't work as expected.
(In other words, if we depends on total_vm, using overcommit more positive
 is a good choice.)

This patch uses mm->anon_rss/file_rss as base value for calculating badness.

Following is changes to OOM score(badness) on an environment with 1.6G memory
plus memory-eater(500M & 1G).

Top 10 of badness score. (The highest one is the first candidate to be killed)
Before
badness program
91228	gnome-settings-
94210	clock-applet
103202	mixer_applet2
106563	tomboy
112947	gnome-terminal
128944	mmap              <----------- 500M malloc
129332	nautilus
215476	bash              <----------- parent of 2 mallocs.
256944	mmap              <----------- 1G malloc
423586	gnome-session

After
badness 
1911	mixer_applet2
1955	clock-applet
1986	xinit
1989	gnome-session
2293	nautilus
2955	gnome-terminal
4113	tomboy
104163	mmap             <----------- 500M malloc.
168577	bash             <----------- parent of 2 mallocs
232375	mmap             <----------- 1G malloc

seems good for me. 

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/oom_kill.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: mm-test-kernel/mm/oom_kill.c
===================================================================
--- mm-test-kernel.orig/mm/oom_kill.c
+++ mm-test-kernel/mm/oom_kill.c
@@ -93,7 +93,7 @@ unsigned long badness(struct task_struct
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = mm->total_vm;
+	points = get_mm_counter(mm, anon_rss) + get_mm_counter(mm, file_rss);
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -116,8 +116,12 @@ unsigned long badness(struct task_struct
 	 */
 	list_for_each_entry(child, &p->children, sibling) {
 		task_lock(child);
-		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
+		if (child->mm != mm && child->mm) {
+			unsigned long cpoints;
+			cpoints = get_mm_counter(child->mm, anon_rss);
+				  + get_mm_counter(child->mm, file_rss);
+			points += cpoints/2 + 1;
+		}
 		task_unlock(child);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
