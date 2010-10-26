Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF776B004A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 03:11:02 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o9Q7AvKF013652
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 00:10:57 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by kpbe12.cbf.corp.google.com with ESMTP id o9Q7AtdS030696
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 00:10:56 -0700
Received: by pzk35 with SMTP id 35so925703pzk.9
        for <linux-mm@kvack.org>; Tue, 26 Oct 2010 00:10:55 -0700 (PDT)
Date: Tue, 26 Oct 2010 00:10:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mem-hotplug + ksm make lockdep warning
In-Reply-To: <20101025193711.917F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1010252248210.2939@sister.anvils>
References: <20101025193711.917F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010, KOSAKI Motohiro wrote:
> Hi Hugh,
> 
> commit 62b61f611e(ksm: memory hotremove migration only) makes following
> lockdep warnings. Is this intentional?

No, certainly not intentional: thanks for finding this.  Looking back,
I think the machine I tested memory hotplug versus KSM upon was not
the machine I habitually ran lockdep on, I bet I forgot to try it.

> 
> More detail: current lockdep hieralcy is here.

And especial thanks for taking the trouble to present it in a way
that I find much easier to understand than lockdep's pronouncements.

> 
> memory_notify
> 	offline_pages
> 		lock_system_sleep();
> 			mutex_lock(&pm_mutex);
> 		memory_notify(MEM_GOING_OFFLINE)
> 			__blocking_notifier_call_chain
> 				down_read(memory_chain.rwsem)
> 				ksm_memory_callback()
> 					mutex_lock(&ksm_thread_mutex);  // memory_chain.rmsem -> ksm_thread_mutex order
> 				up_read(memory_chain.rwsem)
> 		memory_notify(MEM_OFFLINE)
> 			__blocking_notifier_call_chain
> 				down_read(memory_chain.rwsem)		// ksm_thread_mutex -> memory_chain.rmsem order
> 				ksm_memory_callback()
> 					mutex_unlock(&ksm_thread_mutex);
> 				up_read(memory_chain.rwsem)
> 		unlock_system_sleep();
> 			mutex_unlock(&pm_mutex);
> 
> So, I think pm_mutex protect ABBA deadlock. but it exist only when
> CONFIG_HIBERNATION=y. IOW, this code is not correct generically. Am I
> missing something?

I do remember taking great comfort from lock_system_sleep() i.e. pm_mutex
when I did the ksm_memory_callback(); but I think that comfort was more
along the lines of it making obvious that taking a mutex was okay there,
than it providing any safety.  I think I was unconscious of the issue you
raise, perhaps didn't even notice rwsem in __blocking_notifier_call_chain.

But is it really a problem, given that it's down_read(rwsem) in each case?
Yes, but I had to look up akpm's comment on msync in ChangeLog-2.6.11 to
remember why:

	And yes, the ranking of down_read() versus down() does matter:
	
		Task A			Task B		Task C
	
		down_read(rwsem)
					down(sem)
							down_write(rwsem)
		down(sem)
					down_read(rwsem)
	
	C's down_write() will cause B's down_read to block.
	B holds `sem', so A will never release `rwsem'.

Am I mistaken, or is get_any_page() in mm/memory-failure.c also relying
on lock_system_sleep() to do real locking, even without CONFIG_HIBERNATION?

If it is, then I think we should solve both problems by making it lock
unconditionally: though neither "lock_system_sleep" nor "pm_mutex" is an
appropriate name then... maybe "lock_memory_hotplug", but still using a
pm_mutex declared outside of CONFIG_PM?  Seems a bit weird.

And some kind of lockdep annotation needed for ksm_memory_callback(),
to help it understand how the outer mutex makes the inner inversion safe?
Or does lockdep manage that without help?

I think I'm not going to find time to do the patch for a while,
so please go ahead if you can.

Thanks,
Hugh

> 
> Thanks.
> 
> 
> 
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.36-rc7-mm1+ #148
> -------------------------------------------------------
> bash/1621 is trying to acquire lock:
>  ((memory_chain).rwsem){.+.+.+}, at: [<ffffffff81079339>] __blocking_notifier_call_chain+0x69/0xc0
> 
> but task is already holding lock:
>  (ksm_thread_mutex){+.+.+.}, at: [<ffffffff8113a3aa>] ksm_memory_callback+0x3a/0xc0
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #1 (ksm_thread_mutex){+.+.+.}:
>        [<ffffffff8108b70a>] lock_acquire+0xaa/0x140
>        [<ffffffff81505d74>] __mutex_lock_common+0x44/0x3f0
>        [<ffffffff81506228>] mutex_lock_nested+0x48/0x60
>        [<ffffffff8113a3aa>] ksm_memory_callback+0x3a/0xc0		
>        [<ffffffff8150c21c>] notifier_call_chain+0x8c/0xe0
>        [<ffffffff8107934e>] __blocking_notifier_call_chain+0x7e/0xc0	
>        [<ffffffff810793a6>] blocking_notifier_call_chain+0x16/0x20
>        [<ffffffff813afbfb>] memory_notify+0x1b/0x20
>        [<ffffffff81141b7c>] remove_memory+0x1cc/0x5f0
>        [<ffffffff813af53d>] memory_block_change_state+0xfd/0x1a0
>        [<ffffffff813afd62>] store_mem_state+0xe2/0xf0
>        [<ffffffff813a0bb0>] sysdev_store+0x20/0x30
>        [<ffffffff811bc116>] sysfs_write_file+0xe6/0x170
>        [<ffffffff8114f398>] vfs_write+0xc8/0x190
>        [<ffffffff8114fc14>] sys_write+0x54/0x90
>        [<ffffffff810028b2>] system_call_fastpath+0x16/0x1b
> 
> -> #0 ((memory_chain).rwsem){.+.+.+}:
>        [<ffffffff8108b5ba>] __lock_acquire+0x155a/0x1600
>        [<ffffffff8108b70a>] lock_acquire+0xaa/0x140
>        [<ffffffff81506601>] down_read+0x51/0xa0
>        [<ffffffff81079339>] __blocking_notifier_call_chain+0x69/0xc0	
>        [<ffffffff810793a6>] blocking_notifier_call_chain+0x16/0x20
>        [<ffffffff813afbfb>] memory_notify+0x1b/0x20
>        [<ffffffff81141f1e>] remove_memory+0x56e/0x5f0
>        [<ffffffff813af53d>] memory_block_change_state+0xfd/0x1a0
>        [<ffffffff813afd62>] store_mem_state+0xe2/0xf0
>        [<ffffffff813a0bb0>] sysdev_store+0x20/0x30
>        [<ffffffff811bc116>] sysfs_write_file+0xe6/0x170
>        [<ffffffff8114f398>] vfs_write+0xc8/0x190
>        [<ffffffff8114fc14>] sys_write+0x54/0x90
>        [<ffffffff810028b2>] system_call_fastpath+0x16/0x1b
> 
> other info that might help us debug this:
> 
> 5 locks held by bash/1621:
>  #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff811bc074>] sysfs_write_file+0x44/0x170
>  #1:  (s_active#110){.+.+.+}, at: [<ffffffff811bc0fd>] sysfs_write_file+0xcd/0x170
>  #2:  (&mem->state_mutex){+.+.+.}, at: [<ffffffff813af478>] memory_block_change_state+0x38/0x1a0
>  #3:  (pm_mutex){+.+.+.}, at: [<ffffffff81141ad9>] remove_memory+0x129/0x5f0
>  #4:  (ksm_thread_mutex){+.+.+.}, at: [<ffffffff8113a3aa>] ksm_memory_callback+0x3a/0xc0
> 
> stack backtrace:
> Pid: 1621, comm: bash Not tainted 2.6.36-rc7-mm1+ #148
> Call Trace:
>  [<ffffffff81088b5b>] print_circular_bug+0xeb/0xf0
>  [<ffffffff8108b5ba>] __lock_acquire+0x155a/0x1600
>  [<ffffffff8103a1f9>] ? finish_task_switch+0x79/0xe0
>  [<ffffffff815049a9>] ? schedule+0x419/0xa80
>  [<ffffffff8108b70a>] lock_acquire+0xaa/0x140
>  [<ffffffff81079339>] ? __blocking_notifier_call_chain+0x69/0xc0	
>  [<ffffffff81506601>] down_read+0x51/0xa0
>  [<ffffffff81079339>] ? __blocking_notifier_call_chain+0x69/0xc0
>  [<ffffffff81079339>] __blocking_notifier_call_chain+0x69/0xc0
>  [<ffffffff81110f06>] ? next_online_pgdat+0x26/0x50
>  [<ffffffff810793a6>] blocking_notifier_call_chain+0x16/0x20
>  [<ffffffff813afbfb>] memory_notify+0x1b/0x20			
>  [<ffffffff81141f1e>] remove_memory+0x56e/0x5f0
>  [<ffffffff8108ba98>] ? lock_release_non_nested+0x2f8/0x3a0
>  [<ffffffff813af53d>] memory_block_change_state+0xfd/0x1a0
>  [<ffffffff8111705c>] ? might_fault+0x5c/0xb0
>  [<ffffffff813afd62>] store_mem_state+0xe2/0xf0
>  [<ffffffff811bc0fd>] ? sysfs_write_file+0xcd/0x170
>  [<ffffffff813a0bb0>] sysdev_store+0x20/0x30
>  [<ffffffff811bc116>] sysfs_write_file+0xe6/0x170
>  [<ffffffff8114f398>] vfs_write+0xc8/0x190
>  [<ffffffff8114fc14>] sys_write+0x54/0x90
>  [<ffffffff810028b2>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
