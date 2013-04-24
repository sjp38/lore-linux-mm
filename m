Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 50D8B6B0033
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 10:58:13 -0400 (EDT)
Date: Wed, 24 Apr 2013 16:55:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-ID: <20130424145514.GA24997@redhat.com>
References: <1366643184-3627-1-git-send-email-dserrg@gmail.com> <20130422195138.GB31098@dhcp22.suse.cz> <20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com> <20130423155638.GJ8001@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423155638.GJ8001@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: dserrg <dserrg@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>

On 04/23, Michal Hocko wrote:
>
> [CCing Oleg]
>
> On Tue 23-04-13 19:26:14, dserrg wrote:
> > On Mon, 22 Apr 2013 21:51:38 +0200
> >
> > Yes, we are holding tasklist_lock when iterating, but the thread can be deleted
> > from thread_group list _before_ that. In this case, while_each_thread loop exit
> > condition will never be true.

Yes, while_each_thread() should be only used if know that ->thread_group
list is valid.

For example, if you do find_task_by_vpid() under rcu_read_lock()
while_each_thread() is fine _unless_ you drop rcu lock in between.

This is the common mistake, people often forget about this.

But I can't understand how this patch can fix the problem, I think it
can't.

>From the changelog:

	When SIGKILL is sent to a task, it's also sent to all tasks in the same
	threadgroup. This information can be used to prevent triggering further
	oom killers for this threadgroup and avoid the infinite loop.
                                             ^^^^^^^^^^^^^^^^^^^^^^^

How??


> Oleg, is there anything that would prevent from this race? Maybe we need
> to call thread_group_empty before?

You need to check, say, pid_alive(). Or PF_EXITING.

For example oom_kill_process() looks wrong. It does check PF_EXITING
before while_each_thread(), but this is racy because it should check
it under tasklist_lock.

So I think that oom_kill_process() needs something like below, but
this code really needs the cleanups.

Oleg.


--- x/mm/oom_kill.c
+++ x/mm/oom_kill.c
@@ -436,6 +436,14 @@ void oom_kill_process(struct task_struct
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
+	rcu_read_lock();
+	if (!pid_alive(p)) {
+		rcu_read_unlock();
+		set_tsk_thread_flag(p, TIF_MEMDIE);
+		put_task_struct(p);
+		return;
+	}
+
 	read_lock(&tasklist_lock);
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
@@ -458,7 +466,6 @@ void oom_kill_process(struct task_struct
 	} while_each_thread(p, t);
 	read_unlock(&tasklist_lock);
 
-	rcu_read_lock();
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
