Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 02B386B01D6
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:41:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BfpkL014406
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 784D145DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C5F545DE4D
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 303661DB803F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C046F1DB8040
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 02/18] oom: sacrifice child with highest badness score for parent
In-Reply-To: <alpine.DEB.2.00.1006010013220.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013220.29202@chino.kir.corp.google.com>
Message-Id: <20100606175117.8721.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Reviewers may observe that the previous implementation would iterate
> through the children and attempt to kill each until one was successful and
> then the parent if none were found while the new code simply kills the
> most memory-hogging task or the parent.  Note that the only time
> oom_kill_task() fails, however, is when a child does not have an mm or has
> a /proc/pid/oom_adj of OOM_DISABLE.  badness() returns 0 for both cases,
> so the final oom_kill_task() will always succeed.

probably we need to call has_intersects_mems_allowed() in this loop. likes

        /* Try to sacrifice the worst child first */
        do {
                list_for_each_entry(c, &t->children, sibling) {
                        unsigned long cpoints;

                        if (c->mm == p->mm)
                                continue;
                        if (oom_unkillable(c, mem, nodemask))
                                continue;

                        /* oom_badness() returns 0 if the thread is unkillable */
                        cpoints = oom_badness(c);
                        if (cpoints > victim_points) {
                                victim = c;
                                victim_points = cpoints;
                        }
                }
        } while_each_thread(p, t);


It mean we shouldn't assume parent and child have the same mems_allowed,
perhaps.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
