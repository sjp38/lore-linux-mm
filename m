Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C8F216B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 05:58:59 -0400 (EDT)
Date: Tue, 6 Sep 2011 11:58:52 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
Message-ID: <20110906095852.GA25053@redhat.com>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313650253-21794-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Wed, Aug 17, 2011 at 11:50:53PM -0700, Greg Thelen wrote:
> Both mem_cgroup_charge_statistics() and mem_cgroup_move_account() were
> unnecessarily disabling preemption when adjusting per-cpu counters:
>     preempt_disable()
>     __this_cpu_xxx()
>     __this_cpu_yyy()
>     preempt_enable()
> 
> This change does not disable preemption and thus CPU switch is possible
> within these routines.  This does not cause a problem because the total
> of all cpu counters is summed when reporting stats.  Now both
> mem_cgroup_charge_statistics() and mem_cgroup_move_account() look like:
>     this_cpu_xxx()
>     this_cpu_yyy()
> 
> Reported-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

I just noticed that both cases have preemption disabled anyway because
of the page_cgroup bit spinlock.

So removing the preempt_disable() is fine but we can even keep the
non-atomic __this_cpu operations.

Something like this instead?

---
From: Johannes Weiner <jweiner@redhat.com>
Subject: mm: memcg: remove needless recursive preemption disabling

Callsites of mem_cgroup_charge_statistics() hold the page_cgroup bit
spinlock, which implies disabled preemption.

The same goes for the explicit preemption disabling to account mapped
file pages in mem_cgroup_move_account().

The explicit disabling of preemption in both cases is redundant.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |    6 ------
 1 file changed, 6 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -618,8 +618,6 @@ static unsigned long mem_cgroup_read_eve
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 bool file, int nr_pages)
 {
-	preempt_disable();
-
 	if (file)
 		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], nr_pages);
 	else
@@ -634,8 +632,6 @@ static void mem_cgroup_charge_statistics
 	}
 
 	__this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_pages);
-
-	preempt_enable();
 }
 
 unsigned long
@@ -2582,10 +2578,8 @@ static int mem_cgroup_move_account(struc
 
 	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
 		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
 	if (uncharge)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
