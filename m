Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EAE456B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 10:18:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so44267103wme.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 07:18:32 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id bk7si38913518wjb.34.2016.05.16.07.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 07:18:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so18421686wmn.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 07:18:31 -0700 (PDT)
Date: Mon, 16 May 2016 16:18:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160516141829.GK23146@dhcp22.suse.cz>
References: <201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
 <20160425095508.GE23933@dhcp22.suse.cz>
 <20160426135402.GB20813@dhcp22.suse.cz>
 <201604271943.GAC60432.FFJHtFVSOQOOLM@I-love.SAKURA.ne.jp>
 <20160427111147.GI2179@dhcp22.suse.cz>
 <201605140939.BFG05745.FJOOOSVQtLFMHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605140939.BFG05745.FJOOOSVQtLFMHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Sat 14-05-16 09:39:49, Tetsuo Handa wrote:
[...]
> What I got is that the OOM victim is blocked at
> down_write(vma->file->f_mapping) in i_mmap_lock_write() called from
> link_file_vma(vma) etc.
> 
> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160514.txt.xz .
> ----------
[...]
> [  364.158972] Call Trace:
> [  364.159979]  [<ffffffff8172b257>] ? _raw_spin_unlock_irq+0x27/0x50
> [  364.161691]  [<ffffffff81725e1a>] schedule+0x3a/0x90
> [  364.163170]  [<ffffffff8172a366>] rwsem_down_write_failed+0x106/0x220
> [  364.164925]  [<ffffffff813bd2c7>] call_rwsem_down_write_failed+0x17/0x30
> [  364.166737]  [<ffffffff81729877>] down_write+0x47/0x60
> [  364.168258]  [<ffffffff811c3284>] ? vma_link+0x44/0xc0
> [  364.169773]  [<ffffffff811c3284>] vma_link+0x44/0xc0
> [  364.171255]  [<ffffffff811c5c05>] mmap_region+0x3a5/0x5b0
> [  364.172822]  [<ffffffff811c6204>] do_mmap+0x3f4/0x4c0
> [  364.174324]  [<ffffffff811a64dc>] vm_mmap_pgoff+0xbc/0x100
> [  364.175894]  [<ffffffff811c4060>] SyS_mmap_pgoff+0x1c0/0x290
> [  364.177499]  [<ffffffff81002c91>] ? do_syscall_64+0x21/0x170
> [  364.179118]  [<ffffffff81022b7d>] SyS_mmap+0x1d/0x20
> [  364.180592]  [<ffffffff81002ccc>] do_syscall_64+0x5c/0x170
> [  364.182140]  [<ffffffff8172b9da>] entry_SYSCALL64_slow_path+0x25/0x25
> [  364.183855] oom_reaper: unable to reap pid:5652 (tgid=5398)
[...]
> static inline void i_mmap_lock_write(struct address_space *mapping)
> {
>         down_write(&mapping->i_mmap_rwsem);
> }
> 
> static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
>                         struct vm_area_struct *prev, struct rb_node **rb_link,
>                         struct rb_node *rb_parent)
> {
>         struct address_space *mapping = NULL;
> 
>         if (vma->vm_file) {
>                 mapping = vma->vm_file->f_mapping;
>                 i_mmap_lock_write(mapping);
>         }
> 
>         __vma_link(mm, vma, prev, rb_link, rb_parent); /* [<ffffffff811c3284>] vma_link+0x44/0xc0 */
>         __vma_link_file(vma);
> 
>         if (mapping)
>                 i_mmap_unlock_write(mapping);
> 
>         mm->map_count++;
>         validate_mm(mm);
> }
> 
> As you said that "I consider unkillable sleep while holding mmap_sem
> for write to be a _bug_ which should be fixed rather than worked around
> by some timeout based heuristics.", you of course have a plan to rewrite
> functions to return "int" which are currently "void" in order to use
> killable waits, don't you?

Thanks for the report. Yes this seems quite simple to fix actually. All
the callers are able to handle the failure. Well, copy_vma is a bit
complicated because it already did anon_vma_clone and other state
related stuff so it would be slightly more tricky but nothing unfixable.

> I think that clearing TIF_MEMDIE even if the OOM reaper failed to reap the
> OOM vitctim's memory is confusing for panic_on_oom_timeout timer (which stops
> itself when TIF_MEMDIE is cleared) and kmallocwd (which prints victim=0 in
> MemAlloc-Info: line). Until you complete rewriting all functions which could
> be called with mmap_sem held for write, we should allow the OOM killer to
> select next OOM victim upon timeout; otherwise calling panic() is premature.

I would agree if this was an easily triggerable issue in the real life.
You are basically DoSing your machine and that leads to corner cases of
course. We can and should try to plug them but I still do not see any
reason to rush into any solutions.

You seem to be bound to the timeout solution so much that you even
refuse to think about any other potential ways to move on. I think that
is counter productive. I have tried to explain many times that once you
define a _user_ _visible_ knob you should better define a proper semantic
for it. Do something with a random outcome is not it.

So let's move on and try to think outside of the box:
---
diff --git a/include/linux/sched.h b/include/linux/sched.h
index df8778e72211..027d5bc1e874 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -513,6 +513,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
+#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c0e37dd1422f..b1a1e3317231 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -538,8 +538,27 @@ static void oom_reap_task(struct task_struct *tsk)
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
+		struct task_struct *p;
+
 		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 				task_pid_nr(tsk), tsk->comm);
+
+		/*
+		 * If we've already tried to reap this task in the past and
+		 * failed it probably doesn't make much sense to try yet again
+		 * so hide the mm from the oom killer so that it can move on
+		 * to another task with a different mm struct.
+		 */
+		p = find_lock_task_mm(tsk);
+		if (p) {
+			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
+				pr_info("oom_reaper: giving up pid:%d (%s)\n",
+						task_pid_nr(tsk), tsk->comm);
+				set_bit(MMF_OOM_REAPED, &p->mm->flags);
+			}
+			task_unlock(p);
+		}
+
 		debug_show_all_locks();
 	}
 

See the difference? This is 11LOC and we do not have export any knobs
which would tie us for future implementations. We will cap the number
of times each mm struct is attempted for OOM killer and do not have
to touch any subtle oom killer paths so the patch would be quite easy
to review. We can change this implementation if it turns out to be
impractical, too optimistic or pesimistic.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
