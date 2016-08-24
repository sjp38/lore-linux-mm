Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA5156B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 12:43:03 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so14925798lfe.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 09:43:03 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id yv8si9190058wjc.147.2016.08.24.09.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 09:43:02 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so3383293wme.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 09:43:02 -0700 (PDT)
Date: Wed, 24 Aug 2016 18:42:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160824164254.GA24047@dhcp22.suse.cz>
References: <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160822130311.GL13596@dhcp22.suse.cz>
 <20160822210123.5k6zwdrkhrwjw5vv@redhat.com>
 <20160823075555.GE23577@dhcp22.suse.cz>
 <20160823090655.GA23583@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Content-Disposition: inline
In-Reply-To: <20160823090655.GA23583@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 23-08-16 11:06:55, Michal Hocko wrote:
> On Tue 23-08-16 09:55:55, Michal Hocko wrote:
> > On Tue 23-08-16 00:01:23, Michael S. Tsirkin wrote:
> > [...]
> > > Actually, vhost net calls out to tun which does regular copy_from_iter.
> > > Returning 0 there will cause corrupted packets in the network: not a
> > > huge deal, but ugly.  And I don't think we want to annotate run and
> > > macvtap as well.
> > 
> > Hmm, OK, I wasn't aware of that path and being consistent here matters.
> > If the vhost driver can interact with other subsystems then there is
> > really no other option than hooking into the page fault path. Ohh well.
> 
> Here is a completely untested patch just for sanity check.

OK, so I've tested the patch and it seems to work as expected. I didn't
know how to configure vhost so I've just hacked up a quick kernel thread
which picks on a task (I am always selecting a first task which is the
OOM_SCORE_ADJ_MAX because that would be the selected victim - see the
code attached) and then read through its address space in a loop. The
oom victim then just mmaps and poppulates a private anon mapping which
causes the oom killer. It properly notices that the memor could have
been reaped.
[  628.559374] Out of memory: Kill process 3193 (oom_victim) score 1868 or sacrifice child
[  628.561713] Killed process 3193 (oom_victim) total-vm:1052540kB, anon-rss:782964kB, file-rss:12kB, shmem-rss:0kB
[  628.568120] Found a dead vma: ret:-14vma ffff88003c697000 start 00007f9227b33000 end 00007f9267b33000
next ffff88003d80d8a0 prev ffff88003d80d228 mm ffff88003d97b200
prot 8000000000000025 anon_vma ffff88003dbbc000 vm_ops           (null)
pgoff 7f9227b33 file           (null) private_data           (null)
flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
[  628.595684] oom_reaper: reaped process 3193 (oom_victim), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  673.366282] Waiting for kthread to stop
[  673.367487] Done

Are there any objections or suggestions to the apporach?
-- 
Michal Hocko
SUSE Labs

--n8g4imXOkfNTN/H1
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="oom_reaper_test.c"

#include <linux/module.h>
#include <linux/init.h>
#include <linux/printk.h>
#include <linux/sched.h>
#include <linux/mmu_context.h>
#include <linux/mm_types.h>
#include <linux/mm.h>
#include <linux/kthread.h>
#include <linux/oom.h>

struct task_struct *th = NULL;

static int read_vma(struct vm_area_struct *vma)
{
	unsigned long addr;
	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
		char __user *ptr = (char __user *)addr;
		int ret;
		char c;

		if ((ret = get_user(c, ptr)) < 0 && test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)) {
			pr_info("Found a dead vma: ret:%d", ret);
			dump_vma(vma);
			return 1;
		}
	}
	return 0;
}

static int scan_memory(void *data)
{
	struct task_struct *victim = data;
	struct mm_struct *mm;
	int reported = 0;

	pr_info("Starting with pid:%d %s\n", victim->pid, victim->comm);
	mm = get_task_mm(victim);
	if (!mm) {
		pr_info("Failed to get mm\n");
		return 1;
	}
	use_mm(mm);
	mmput(mm);

	while (!kthread_should_stop()) {
		struct vm_area_struct *vma = mm->mmap;
		
		if (!reported && test_bit(MMF_UNSTABLE, &mm->flags)) {
			pr_info("mm is unstable\n");
			reported = 1;
		}
		for (; vma; vma = vma->vm_next) {
			if (!(vma->vm_flags & VM_MAYREAD))
				continue;
			if (read_vma(vma))
				goto out;
		}
		schedule_timeout_idle(HZ);
	}
out:
	unuse_mm(mm);
	while (!kthread_should_stop()) {
		set_current_state(TASK_UNINTERRUPTIBLE);
		if (kthread_should_stop())
			break;
		schedule();
	}
	return 0;
}
static int __init mymodule_init(void)
{
	struct task_struct *p, *victim = NULL;

	rcu_read_lock();
	for_each_process(p) {
		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MAX) {
			get_task_struct(p);
			victim = p;
			break;
		}
	}
	rcu_read_unlock();
	if (!victim) {
		pr_info("No potential victim found\n");
		return 1;
	}

	th = kthread_run(scan_memory, victim, "scan_memory");
	return 0;
}

static void __exit mymodule_exit(void)
{
	if (!th)
		return;

	pr_info("Waiting for kthread to stop\n");
	kthread_stop(th);
	put_task_struct(th);
	pr_info("Done\n");
}

module_init(mymodule_init);
module_exit(mymodule_exit);

MODULE_LICENSE("GPL");

--n8g4imXOkfNTN/H1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
