Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 97C266B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 21:03:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9T13DWQ023457
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Oct 2009 10:03:14 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8948445DE62
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:03:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A5CD45DE51
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:03:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3795F1DB8042
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:03:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D22941DB803F
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:03:12 +0900 (JST)
Date: Thu, 29 Oct 2009 10:00:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
Message-Id: <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
	<abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> I'll wait until the next week to post a new patch.
> We don't need rapid way.
> 
I wrote above...but for my mental health, this is bug-fixed version.
Sorry for my carelessness. David, thank you for your review.
Regards,
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

seems good for me. Maybe we can tweak this patch more,
but this one will be a good one as a start point.

Changelog: 2009/10/29
 - use get_mm_rss() instead of get_mm_counter()

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/oom_kill.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: mm-test-kernel/mm/oom_kill.c
===================================================================
--- mm-test-kernel.orig/mm/oom_kill.c
+++ mm-test-kernel/mm/oom_kill.c
@@ -93,7 +93,7 @@ unsigned long badness(struct task_struct
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = mm->total_vm;
+	points = get_mm_rss(mm);
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -117,7 +117,7 @@ unsigned long badness(struct task_struct
 	list_for_each_entry(child, &p->children, sibling) {
 		task_lock(child);
 		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
+			points += get_mm_rss(child->mm)/2 + 1;
 		task_unlock(child);
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
