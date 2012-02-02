Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id EF7E76B13F2
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 11:13:15 -0500 (EST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 2 Feb 2012 16:13:14 -0000
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q12GDAqh2945092
	for <linux-mm@kvack.org>; Thu, 2 Feb 2012 16:13:10 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q122DAee019228
	for <linux-mm@kvack.org>; Wed, 1 Feb 2012 19:13:11 -0700
Message-ID: <4F2AB614.1060907@de.ibm.com>
Date: Thu, 02 Feb 2012 17:13:08 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
MIME-Version: 1.0
Subject: ksm/memory hotplug: lockdep warning for ksm_thread_mutex vs. (memory_chain).rwsem
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Setting a memory block offline triggers the following lockdep warning. This
looks exactly like the issue reported by Kosaki Motohiro in
https://lkml.org/lkml/2010/10/25/110. Seems like the resulting commit a0b0f58cdd
did not fix the lockdep warning. I'm able to reproduce it with current 3.3.0-rc2
as well as 2.6.37-rc4-00147-ga0b0f58.

I'm not familiar with lockdep annotations, but I tried using down_read_nested()
for (memory_chain).rwsem, similar to the mutex_lock_nested() which was
introduced for ksm_thread_mutex, but that didn't help.


======================================================
[ INFO: possible circular locking dependency detected ]
3.3.0-rc2 #8 Not tainted
-------------------------------------------------------
sh/973 is trying to acquire lock:
 ((memory_chain).rwsem){.+.+.+}, at: [<000000000015b0e4>] __blocking_notifier_call_chain+0x40/0x8c

but task is already holding lock:
 (ksm_thread_mutex/1){+.+.+.}, at: [<0000000000247484>] ksm_memory_callback+0x48/0xd0

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (ksm_thread_mutex/1){+.+.+.}:
       [<0000000000195746>] __lock_acquire+0x47a/0xbd4
       [<00000000001964b6>] lock_acquire+0xc2/0x148
       [<00000000005dba62>] mutex_lock_nested+0x5a/0x354
       [<0000000000247484>] ksm_memory_callback+0x48/0xd0
       [<00000000005e1d4e>] notifier_call_chain+0x52/0x9c
       [<000000000015b0fa>] __blocking_notifier_call_chain+0x56/0x8c
       [<000000000015b15a>] blocking_notifier_call_chain+0x2a/0x3c
       [<00000000005d116e>] offline_pages.clone.21+0x17a/0x6f0
       [<000000000046363a>] memory_block_change_state+0x172/0x2f4
       [<0000000000463876>] store_mem_state+0xba/0xf0
       [<00000000002e1592>] sysfs_write_file+0xf6/0x1a8
       [<0000000000260d94>] vfs_write+0xb0/0x18c
       [<0000000000261108>] SyS_write+0x58/0xb4
       [<00000000005dfab8>] sysc_noemu+0x22/0x28
       [<000003fffcfa46c0>] 0x3fffcfa46c0

-> #0 ((memory_chain).rwsem){.+.+.+}:
       [<00000000001946ee>] validate_chain.clone.24+0x1106/0x11b4
       [<0000000000195746>] __lock_acquire+0x47a/0xbd4
       [<00000000001964b6>] lock_acquire+0xc2/0x148
       [<00000000005dc30e>] down_read+0x4a/0x88
       [<000000000015b0e4>] __blocking_notifier_call_chain+0x40/0x8c
       [<000000000015b15a>] blocking_notifier_call_chain+0x2a/0x3c
       [<00000000005d16be>] offline_pages.clone.21+0x6ca/0x6f0
       [<000000000046363a>] memory_block_change_state+0x172/0x2f4
       [<0000000000463876>] store_mem_state+0xba/0xf0
       [<00000000002e1592>] sysfs_write_file+0xf6/0x1a8
       [<0000000000260d94>] vfs_write+0xb0/0x18c
       [<0000000000261108>] SyS_write+0x58/0xb4
       [<00000000005dfab8>] sysc_noemu+0x22/0x28
       [<000003fffcfa46c0>] 0x3fffcfa46c0

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(ksm_thread_mutex/1);
                               lock((memory_chain).rwsem);
                               lock(ksm_thread_mutex/1);
  lock((memory_chain).rwsem);

 *** DEADLOCK ***

6 locks held by sh/973:
 #0:  (&buffer->mutex){+.+.+.}, at: [<00000000002e14e6>] sysfs_write_file+0x4a/0x1a8
 #1:  (s_active#53){.+.+.+}, at: [<00000000002e156e>] sysfs_write_file+0xd2/0x1a8
 #2:  (&mem->state_mutex){+.+.+.}, at: [<000000000046350a>] memory_block_change_state+0x42/0x2f4
 #3:  (mem_hotplug_mutex){+.+.+.}, at: [<0000000000252e30>] lock_memory_hotplug+0x2c/0x4c
 #4:  (pm_mutex#2){+.+.+.}, at: [<00000000005d10ea>] offline_pages.clone.21+0xf6/0x6f0
 #5:  (ksm_thread_mutex/1){+.+.+.}, at: [<0000000000247484>] ksm_memory_callback+0x48/0xd0

stack backtrace:
CPU: 1 Not tainted 3.3.0-rc2 #8
Process sh (pid: 973, task: 000000003ecb8000, ksp: 000000003b24b898)
000000003b24b930 000000003b24b8b0 0000000000000002 0000000000000000.
       000000003b24b950 000000003b24b8c8 000000003b24b8c8 00000000005da66a.
       0000000000000000 0000000000000000 000000003b24ba08 000000003ecb8000.
       000000000000000d 000000000000000c 000000003b24b918 0000000000000000.
       0000000000000000 0000000000100af8 000000003b24b8b0 000000003b24b8f0.
Call Trace:
([<0000000000100a06>] show_trace+0xee/0x144)
 [<0000000000192564>] print_circular_bug+0x220/0x328
 [<00000000001946ee>] validate_chain.clone.24+0x1106/0x11b4
 [<0000000000195746>] __lock_acquire+0x47a/0xbd4
 [<00000000001964b6>] lock_acquire+0xc2/0x148
 [<00000000005dc30e>] down_read+0x4a/0x88
 [<000000000015b0e4>] __blocking_notifier_call_chain+0x40/0x8c
 [<000000000015b15a>] blocking_notifier_call_chain+0x2a/0x3c
 [<00000000005d16be>] offline_pages.clone.21+0x6ca/0x6f0
 [<000000000046363a>] memory_block_change_state+0x172/0x2f4
 [<0000000000463876>] store_mem_state+0xba/0xf0
 [<00000000002e1592>] sysfs_write_file+0xf6/0x1a8
 [<0000000000260d94>] vfs_write+0xb0/0x18c
 [<0000000000261108>] SyS_write+0x58/0xb4
 [<00000000005dfab8>] sysc_noemu+0x22/0x28
 [<000003fffcfa46c0>] 0x3fffcfa46c0
INFO: lockdep is turned off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
