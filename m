Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 49CB16B01AD
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:54:05 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o52Ds0gA016796
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Jun 2010 22:54:01 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AE65F45DE4F
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BAA945DE4E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 737C91DB803F
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F06C1DB8038
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] oom: Fix child process iteration properly
In-Reply-To: <20100601192726.GA19120@redhat.com>
References: <20100601144810.2440.A69D9226@jp.fujitsu.com> <20100601192726.GA19120@redhat.com>
Message-Id: <20100602200323.F515.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Jun 2010 22:53:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On 06/01, KOSAKI Motohiro wrote:
> >
> > @@ -88,6 +88,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  {
> >  	unsigned long points, cpu_time, run_time;
> >  	struct task_struct *c;
> > +	struct task_struct *t = p;
> 
> This initialization should be moved down to
> 
> > +	do {
> > +		list_for_each_entry(c, &t->children, sibling) {
> > +			child = find_lock_task_mm(c);
> > +			if (child) {
> > +				if (child->mm != p->mm)
> > +					points += child->mm->total_vm/2 + 1;
> > +				task_unlock(child);
> > +			}
> >  		}
> > -	}
> > +	} while_each_thread(p, t);
> 
> this loop. We have "p = find_lock_task_mm(p)" in between which can change p.
> 
> Apart from this, I think the whole series is nice.

Nich catch!

simple incremental patch is here.

========================================================
Subject: [PATCH] Fix oom: Fix child process iteration properly

p can be changed by find_lock_task_mm()

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9631f1b..9e7f0f9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -88,7 +88,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
 	struct task_struct *c;
-	struct task_struct *t = p;
+	struct task_struct *t;
 	struct task_struct *child;
 	int oom_adj = p->signal->oom_adj;
 	struct task_cputime task_time;
@@ -126,6 +126,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	 * child is eating the vast majority of memory, adding only half
 	 * to the parents will make the child our kill candidate of choice.
 	 */
+	t = p;
 	do {
 		list_for_each_entry(c, &t->children, sibling) {
 			child = find_lock_task_mm(c);
-- 
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
