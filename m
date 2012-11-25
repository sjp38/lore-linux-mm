Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C3AFB6B005A
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 05:17:11 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so4060097eaa.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2012 02:17:10 -0800 (PST)
Date: Sun, 25 Nov 2012 11:17:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121125101707.GA10623@dhcp22.suse.cz>
References: <20121121200207.01068046@pobox.sk>
 <20121122152441.GA9609@dhcp22.suse.cz>
 <20121122190526.390C7A28@pobox.sk>
 <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
 <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121123155904.490039C5@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121123155904.490039C5@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Fri 23-11-12 15:59:04, azurIt wrote:
> >If you could instrument mem_cgroup_handle_oom with some printks (before
> >we take the memcg_oom_lock, before we schedule and into
> >mem_cgroup_out_of_memory)
> 
> 
> If you send me patch i can do it. I'm, unfortunately, not able to code it.

Inlined at the end of the email. Please note I have compile tested
it. It might produce a lot of output.
 
> >> It, luckily, happend again so i have more info.
> >> 
> >>  - there wasn't any logs in kernel from OOM for that cgroup
> >>  - there were 16 processes in cgroup
> >>  - processes in cgroup were taking togather 100% of CPU (it
> >>    was allowed to use only one core, so 100% of that core)
> >>  - memory.failcnt was groving fast
> >>  - oom_control:
> >> oom_kill_disable 0
> >> under_oom 0 (this was looping from 0 to 1)
> >
> >So there was an OOM going on but no messages in the log? Really strange.
> >Kame already asked about oom_score_adj of the processes in the group but
> >it didn't look like all the processes would have oom disabled, right?
> 
> 
> There were no messages telling that some processes were killed because of OOM.

dmesg | grep "Out of memory"
doesn't tell anything, right?

> >>  - limit_in_bytes was set to 157286400
> >>  - content of stat (as you can see, the whole memory limit was used):
> >> cache 0
> >> rss 0
> >
> >This looks like a top-level group for your user.
> 
> 
> Yes, it was from /cgroup/<user-id>/
> 
> 
> >> mapped_file 0
> >> pgpgin 0
> >> pgpgout 0
> >> swap 0
> >> pgfault 0
> >> pgmajfault 0
> >> inactive_anon 0
> >> active_anon 0
> >> inactive_file 0
> >> active_file 0
> >> unevictable 0
> >> hierarchical_memory_limit 157286400
> >> hierarchical_memsw_limit 157286400
> >> total_cache 0
> >> total_rss 157286400
> >
> >OK, so all the memory is anonymous and you have no swap so the oom is
> >the only thing to do.
> 
> 
> What will happen if the same situation occurs globally? No swap, every
> bit of memory used. Will kernel be able to start OOM killer?

OOM killer is not a task. It doesn't allocate any memory. It just walks
the process list and picks up a task with the highest score. If the
global oom is not able to find any such a task (e.g. because all of them
have oom disabled) the the system panics.

> Maybe the same thing is happening in cgroup

cgroup oom differs only in that aspect that the system doesn't panic if
there is no suitable task to kill.

[...]
> >> Notice that stack is different for few processes.
> >
> >Yes others are in VFS resp ext3. ext3_write_begin looks a bit dangerous
> >but it grabs the page before it really starts a transaction.
> 
> 
> Maybe these processes were throttled by cgroup-blkio at the same time
> and are still keeping the lock?

If you are thinking about memcg_oom_lock then this is not possible
because the lock is held only for short times. There is no other lock
that memcg oom holds.

> So the problem occurs when there are low on memory and cgroup is doing
> IO out of it's limits. Only guessing and telling my thoughts.

The lockup (if this is what happens) still might be related to the IO
controller if the killed task cannot finish due to pending IO, though.
 
[...]
> >> didn't checked if cgroup was freezed but i suppose it wasn't):
> >> none            /cgroups        cgroup  defaults,cpuacct,cpuset,memory,freezer,task,blkio 0 0
> >
> >Do you see the same issue if only memory controller was mounted (resp.
> >cpuset which you seem to use as well from your description).
> 
> 
> Uh, we are using all mounted subsystems :( I will be able to umount
> only freezer and maybe blkio for some time. Will it help?

Not sure about that without further data.

> >I know you said booting into a vanilla kernel would be problematic but
> >could you at least rule out te cgroup patches that you have mentioned?
> >If you need to move a task to a group based by an uid you can use
> >cgrules daemon (libcgroup1 package) for that as well.
> 
> 
> We are using cgroup-uid cos it's MUCH MUCH MUCH more efective and
> better. For example, i don't believe that cgroup-task will work with
> that daemon. What will happen if cgrules won't be able to add process
> into cgroup because of task limit? Process will probably continue and
> will run outside of any cgroup which is wrong. With cgroup-task +
> cgroup-uid, such processes cannot be even started (and this is what we
> need).

I am not familiar with cgroup-task controller so I cannot comment on
that.

---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c8425b1..7f26ec8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1863,6 +1863,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 {
 	struct oom_wait_info owait;
 	bool locked, need_to_kill;
+	int ret = false;
 
 	owait.mem = memcg;
 	owait.wait.flags = 0;
@@ -1873,6 +1874,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 	mem_cgroup_mark_under_oom(memcg);
 
 	/* At first, try to OOM lock hierarchy under memcg.*/
+	printk("XXX: %d waiting for memcg_oom_lock\n", current->pid);
 	spin_lock(&memcg_oom_lock);
 	locked = mem_cgroup_oom_lock(memcg);
 	/*
@@ -1887,12 +1889,14 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 		mem_cgroup_oom_notify(memcg);
 	spin_unlock(&memcg_oom_lock);
 
+	printk("XXX: %d need_to_kill:%d locked:%d\n", current->pid, need_to_kill, locked);
 	if (need_to_kill) {
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, mask);
 	} else {
 		schedule();
 		finish_wait(&memcg_oom_waitq, &owait.wait);
+		printk("XXX: %d woken up\n", current->pid);
 	}
 	spin_lock(&memcg_oom_lock);
 	if (locked)
@@ -1903,10 +1907,13 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 	mem_cgroup_unmark_under_oom(memcg);
 
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
-		return false;
+		goto out;
 	/* Give chance to dying process */
 	schedule_timeout_uninterruptible(1);
-	return true;
+	ret = true;
+out:
+	printk("XXX: %d done with %d\n", current->pid, ret);
+	return ret;
 }
 
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 069b64e..a7db813 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -568,6 +568,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	 */
 	if (fatal_signal_pending(current)) {
 		set_thread_flag(TIF_MEMDIE);
+		printk("XXX: %d skipping task with fatal signal pending\n", current->pid);
 		return;
 	}
 
@@ -576,8 +577,10 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process(&points, limit, mem, NULL);
-	if (!p || PTR_ERR(p) == -1UL)
+	if (!p || PTR_ERR(p) == -1UL) {
+		printk("XXX: %d nothing to kill\n", current->pid);
 		goto out;
+	}
 
 	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem, NULL,
 				"Memory cgroup out of memory"))

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
