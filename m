Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0E5818D0001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 06:49:55 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9PAnqit001783
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 25 Oct 2010 19:49:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AF2845DE52
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 19:49:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E0DB45DE54
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 19:49:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DFB781DB8013
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 19:49:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B5441DB8015
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 19:49:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: mem-hotplug + ksm make lockdep warning
Message-Id: <20101025193711.917F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Oct 2010 19:49:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Hugh,

commit 62b61f611e(ksm: memory hotremove migration only) makes following
lockdep warnings. Is this intentional?

More detail: current lockdep hieralcy is here.

memory_notify
	offline_pages
		lock_system_sleep();
			mutex_lock(&pm_mutex);
		memory_notify(MEM_GOING_OFFLINE)
			__blocking_notifier_call_chain
				down_read(memory_chain.rwsem)
				ksm_memory_callback()
					mutex_lock(&ksm_thread_mutex);  // memory_chain.rmsem -> ksm_thread_mutex order
				up_read(memory_chain.rwsem)
		memory_notify(MEM_OFFLINE)
			__blocking_notifier_call_chain
				down_read(memory_chain.rwsem)		// ksm_thread_mutex -> memory_chain.rmsem order
				ksm_memory_callback()
					mutex_unlock(&ksm_thread_mutex);
				up_read(memory_chain.rwsem)
		unlock_system_sleep();
			mutex_unlock(&pm_mutex);

So, I think pm_mutex protect ABBA deadlock. but it exist only when
CONFIG_HIBERNATION=y. IOW, this code is not correct generically. Am I
missing something?

Thanks.



=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.36-rc7-mm1+ #148
-------------------------------------------------------
bash/1621 is trying to acquire lock:
 ((memory_chain).rwsem){.+.+.+}, at: [<ffffffff81079339>] __blocking_notifier_call_chain+0x69/0xc0

but task is already holding lock:
 (ksm_thread_mutex){+.+.+.}, at: [<ffffffff8113a3aa>] ksm_memory_callback+0x3a/0xc0

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (ksm_thread_mutex){+.+.+.}:
       [<ffffffff8108b70a>] lock_acquire+0xaa/0x140
       [<ffffffff81505d74>] __mutex_lock_common+0x44/0x3f0
       [<ffffffff81506228>] mutex_lock_nested+0x48/0x60
       [<ffffffff8113a3aa>] ksm_memory_callback+0x3a/0xc0		
       [<ffffffff8150c21c>] notifier_call_chain+0x8c/0xe0
       [<ffffffff8107934e>] __blocking_notifier_call_chain+0x7e/0xc0	
       [<ffffffff810793a6>] blocking_notifier_call_chain+0x16/0x20
       [<ffffffff813afbfb>] memory_notify+0x1b/0x20
       [<ffffffff81141b7c>] remove_memory+0x1cc/0x5f0
       [<ffffffff813af53d>] memory_block_change_state+0xfd/0x1a0
       [<ffffffff813afd62>] store_mem_state+0xe2/0xf0
       [<ffffffff813a0bb0>] sysdev_store+0x20/0x30
       [<ffffffff811bc116>] sysfs_write_file+0xe6/0x170
       [<ffffffff8114f398>] vfs_write+0xc8/0x190
       [<ffffffff8114fc14>] sys_write+0x54/0x90
       [<ffffffff810028b2>] system_call_fastpath+0x16/0x1b

-> #0 ((memory_chain).rwsem){.+.+.+}:
       [<ffffffff8108b5ba>] __lock_acquire+0x155a/0x1600
       [<ffffffff8108b70a>] lock_acquire+0xaa/0x140
       [<ffffffff81506601>] down_read+0x51/0xa0
       [<ffffffff81079339>] __blocking_notifier_call_chain+0x69/0xc0	
       [<ffffffff810793a6>] blocking_notifier_call_chain+0x16/0x20
       [<ffffffff813afbfb>] memory_notify+0x1b/0x20
       [<ffffffff81141f1e>] remove_memory+0x56e/0x5f0
       [<ffffffff813af53d>] memory_block_change_state+0xfd/0x1a0
       [<ffffffff813afd62>] store_mem_state+0xe2/0xf0
       [<ffffffff813a0bb0>] sysdev_store+0x20/0x30
       [<ffffffff811bc116>] sysfs_write_file+0xe6/0x170
       [<ffffffff8114f398>] vfs_write+0xc8/0x190
       [<ffffffff8114fc14>] sys_write+0x54/0x90
       [<ffffffff810028b2>] system_call_fastpath+0x16/0x1b

other info that might help us debug this:

5 locks held by bash/1621:
 #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff811bc074>] sysfs_write_file+0x44/0x170
 #1:  (s_active#110){.+.+.+}, at: [<ffffffff811bc0fd>] sysfs_write_file+0xcd/0x170
 #2:  (&mem->state_mutex){+.+.+.}, at: [<ffffffff813af478>] memory_block_change_state+0x38/0x1a0
 #3:  (pm_mutex){+.+.+.}, at: [<ffffffff81141ad9>] remove_memory+0x129/0x5f0
 #4:  (ksm_thread_mutex){+.+.+.}, at: [<ffffffff8113a3aa>] ksm_memory_callback+0x3a/0xc0

stack backtrace:
Pid: 1621, comm: bash Not tainted 2.6.36-rc7-mm1+ #148
Call Trace:
 [<ffffffff81088b5b>] print_circular_bug+0xeb/0xf0
 [<ffffffff8108b5ba>] __lock_acquire+0x155a/0x1600
 [<ffffffff8103a1f9>] ? finish_task_switch+0x79/0xe0
 [<ffffffff815049a9>] ? schedule+0x419/0xa80
 [<ffffffff8108b70a>] lock_acquire+0xaa/0x140
 [<ffffffff81079339>] ? __blocking_notifier_call_chain+0x69/0xc0	
 [<ffffffff81506601>] down_read+0x51/0xa0
 [<ffffffff81079339>] ? __blocking_notifier_call_chain+0x69/0xc0
 [<ffffffff81079339>] __blocking_notifier_call_chain+0x69/0xc0
 [<ffffffff81110f06>] ? next_online_pgdat+0x26/0x50
 [<ffffffff810793a6>] blocking_notifier_call_chain+0x16/0x20
 [<ffffffff813afbfb>] memory_notify+0x1b/0x20			
 [<ffffffff81141f1e>] remove_memory+0x56e/0x5f0
 [<ffffffff8108ba98>] ? lock_release_non_nested+0x2f8/0x3a0
 [<ffffffff813af53d>] memory_block_change_state+0xfd/0x1a0
 [<ffffffff8111705c>] ? might_fault+0x5c/0xb0
 [<ffffffff813afd62>] store_mem_state+0xe2/0xf0
 [<ffffffff811bc0fd>] ? sysfs_write_file+0xcd/0x170
 [<ffffffff813a0bb0>] sysdev_store+0x20/0x30
 [<ffffffff811bc116>] sysfs_write_file+0xe6/0x170
 [<ffffffff8114f398>] vfs_write+0xc8/0x190
 [<ffffffff8114fc14>] sys_write+0x54/0x90
 [<ffffffff810028b2>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
