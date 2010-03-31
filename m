Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 305EB6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:19:52 -0400 (EDT)
Date: Wed, 31 Mar 2010 22:17:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: fix the unsafe proc_oom_score()->badness() call
Message-ID: <20100331201746.GC11635@redhat.com>
References: <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <alpine.DEB.2.00.1003301331110.5234@chino.kir.corp.google.com> <20100331091628.GA11438@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100331091628.GA11438@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/31, Oleg Nesterov wrote:
>
> On 03/30, David Rientjes wrote:
> >
> > On Tue, 30 Mar 2010, Oleg Nesterov wrote:
> >
> > > proc_oom_score(task) have a reference to task_struct, but that is all.
> > > If this task was already released before we take tasklist_lock
> > >
> > > 	- we can't use task->group_leader, it points to nowhere
> > >
> > > 	- it is not safe to call badness() even if this task is
> > > 	  ->group_leader, has_intersects_mems_allowed() assumes
> > > 	  it is safe to iterate over ->thread_group list.
> > >
> > > Add the pid_alive() check to ensure __unhash_process() was not called.
> > >
> > > Note: I think we shouldn't use ->group_leader, badness() should return
> > > the same result for any sub-thread. However this is not true currently,
> > > and I think that ->mm check and list_for_each_entry(p->children) in
> > > badness are not right.
> > >
> >
> > I think it would be better to just use task and not task->group_leader.
>
> Sure, agreed. I preserved ->group_leader just because I didn't understand
> why the current code doesn't use task. But note that pid_alive() is still
> needed.

Oh. No, with the current code in -mm pid_alive() is not needed if
we use task instead of task->group_leader. But once we fix
oom_forkbomb_penalty() it will be needed again.


But. Oh well. David, oom-badness-heuristic-rewrite.patch changed badness()
to consult p->signal->oom_score_adj. Until recently this was wrong when it
is called from proc_oom_score().

This means oom-badness-heuristic-rewrite.patch depends on
signals-make-task_struct-signal-immutable-refcountable.patch, or we
need the pid_alive() check again.



oom_badness() gets the new argument, long totalpages, and the callers
were updated. However, long uptime is not used any longer, probably
it make sense to kill this arg and simplify the callers? Unless you
are going to take run-time into account later.

So, I think -mm needs the patch below, but I have no idea how to
write the changelog ;)

Oleg.

--- x/fs/proc/base.c
+++ x/fs/proc/base.c
@@ -430,12 +430,13 @@ static const struct file_operations proc
 /* The badness from the OOM killer */
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
-	unsigned long points;
+	unsigned long points = 0;
 	struct timespec uptime;
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = oom_badness(task->group_leader,
+	if (pid_alive(task))
+		points = oom_badness(task,
 				global_page_state(NR_INACTIVE_ANON) +
 				global_page_state(NR_ACTIVE_ANON) +
 				global_page_state(NR_INACTIVE_FILE) +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
