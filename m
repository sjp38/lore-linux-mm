Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A0A8A6B01EF
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 15:54:18 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o32JsFfb000809
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 12:54:15 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz24.hot.corp.google.com with ESMTP id o32JsDoo030392
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 12:54:14 -0700
Received: by pwi9 with SMTP id 9so1851874pwi.27
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 12:54:13 -0700 (PDT)
Date: Fri, 2 Apr 2010 12:54:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] oom: exclude tasks with badness score of 0 from being
 selected
In-Reply-To: <alpine.DEB.2.00.1004021244010.15445@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004021253480.18402@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com>
 <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <alpine.DEB.2.00.1004021159310.1773@chino.kir.corp.google.com>
 <20100402191414.GA982@redhat.com> <alpine.DEB.2.00.1004021244010.15445@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

An oom_badness() score of 0 means "never kill" according to
Documentation/filesystems/proc.txt, so explicitly exclude it from being
selected for kill.  These tasks have either detached their p->mm or are
set to OOM_DISABLE.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -336,6 +336,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			continue;
 
 		points = oom_badness(p, totalpages);
+		if (!points)
+			continue;
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
