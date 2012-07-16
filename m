Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id BBAA26B0068
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 08:49:59 -0400 (EDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 16 Jul 2012 13:49:58 +0100
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6GCnsbg1892374
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:49:54 +0100
Received: from d06av10.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6GCRuSI006356
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 08:27:57 -0400
Date: Mon, 16 Jul 2012 14:49:51 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: ksm/memory hotplug: lockdep warning for ksm_thread_mutex vs.
 (memory_chain).rwsem
Message-ID: <20120716144951.1f1f574a@thinkpad>
In-Reply-To: <CAHGf_=rm286b5FWVRQ8Ob0vakxNcNOHPUksCtnZj4PvOEz47Jg@mail.gmail.com>
References: <4F2AB614.1060907@de.ibm.com>
	<CAHGf_=rm286b5FWVRQ8Ob0vakxNcNOHPUksCtnZj4PvOEz47Jg@mail.gmail.com>
Reply-To: gerald.schaefer@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, 2 Feb 2012 18:00:45 -0500
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> 2012/2/2 Gerald Schaefer <gerald.schaefer@de.ibm.com>:
> > Setting a memory block offline triggers the following lockdep
> > warning. This looks exactly like the issue reported by Kosaki
> > Motohiro in https://lkml.org/lkml/2010/10/25/110. Seems like the
> > resulting commit a0b0f58cdd did not fix the lockdep warning. I'm
> > able to reproduce it with current 3.3.0-rc2 as well as
> > 2.6.37-rc4-00147-ga0b0f58.
> >
> > I'm not familiar with lockdep annotations, but I tried using
> > down_read_nested() for (memory_chain).rwsem, similar to the
> > mutex_lock_nested() which was introduced for ksm_thread_mutex, but
> > that didn't help.
> 
> Heh, interesting. Simple question, do you have any user visible buggy
> behavior? or just false positive warn issue?
> 
> *_nested() is just hacky trick. so, any change may break their lie.
> Anyway I'd like to dig this one. thanks for reporting.

Hi,

any news on this? I'm still getting test reports about the lockdep
warning: the problem is still present in 3.5.0-rc7 and it still looks
like a false-positive to me (both locks inside mem_hotplug_mutex, so
there can't be a deadlock, see also comment in mm/ksm.c). Any ideas how
to convince lockdep of that, so that we can run memory hotplug tests
again with lockdep enabled?

======================================================
[ INFO: possible circular locking dependency detected ]
3.5.0-rc7 #40 Not tainted
-------------------------------------------------------
sh/698 is trying to acquire lock:
 ((memory_chain).rwsem){.+.+.+}, at: [<0000000000165372>] __blocking_notifier_call_chain+0x5e/0xe0

but task is already holding lock:
 (ksm_thread_mutex/1){+.+.+.}, at: [<000000000026a654>] ksm_memory_callback+0x48/0xd8

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (ksm_thread_mutex/1){+.+.+.}:
       [<00000000001a5b42>] __lock_acquire+0x3f6/0xb28
       [<00000000001a69d2>] lock_acquire+0xbe/0x250
       [<000000000064cefc>] mutex_lock_nested+0x98/0x3f4
       [<000000000026a654>] ksm_memory_callback+0x48/0xd8
       [<0000000000653af4>] notifier_call_chain+0x8c/0x174
       [<0000000000165388>] __blocking_notifier_call_chain+0x74/0xe0
       [<000000000016541e>] blocking_notifier_call_chain+0x2a/0x3c
       [<0000000000638cb4>] offline_pages.constprop.1+0x17c/0x740
       [<00000000004b5326>] memory_block_change_state+0x2aa/0x328
       [<00000000004b545e>] store_mem_state+0xba/0xf0
       [<000000000030b5f2>] sysfs_write_file+0xf6/0x1a8
       [<0000000000283a3a>] vfs_write+0x9a/0x184
       [<0000000000283d94>] SyS_write+0x58/0x94
       [<00000000006514f4>] sysc_noemu+0x22/0x28
       [<000003fffd5aa3e8>] 0x3fffd5aa3e8

-> #0 ((memory_chain).rwsem){.+.+.+}:
       [<00000000001a22bc>] validate_chain+0x880/0x1154
       [<00000000001a5b42>] __lock_acquire+0x3f6/0xb28
       [<00000000001a69d2>] lock_acquire+0xbe/0x250
       [<000000000064d8a6>] down_read+0x66/0xdc
       [<0000000000165372>] __blocking_notifier_call_chain+0x5e/0xe0
       [<000000000016541e>] blocking_notifier_call_chain+0x2a/0x3c
       [<0000000000638d00>] offline_pages.constprop.1+0x1c8/0x740
       [<00000000004b5326>] memory_block_change_state+0x2aa/0x328
       [<00000000004b545e>] store_mem_state+0xba/0xf0
       [<000000000030b5f2>] sysfs_write_file+0xf6/0x1a8
       [<0000000000283a3a>] vfs_write+0x9a/0x184
       [<0000000000283d94>] SyS_write+0x58/0x94
       [<00000000006514f4>] sysc_noemu+0x22/0x28
       [<000003fffd5aa3e8>] 0x3fffd5aa3e8

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(ksm_thread_mutex/1);
                               lock((memory_chain).rwsem);
                               lock(ksm_thread_mutex/1);
  lock((memory_chain).rwsem);

 *** DEADLOCK ***

6 locks held by sh/698:
 #0:  (&buffer->mutex){+.+.+.}, at: [<000000000030b546>] sysfs_write_file+0x4a/0x1a8
 #1:  (s_active#31){.+.+.+}, at: [<000000000030b5ce>] sysfs_write_file+0xd2/0x1a8
 #2:  (&mem->state_mutex){+.+.+.}, at: [<00000000004b50be>] memory_block_change_state+0x42/0x328
 #3:  (mem_hotplug_mutex){+.+.+.}, at: [<0000000000275324>] lock_memory_hotplug+0x2c/0x4c
 #4:  (pm_mutex){+.+.+.}, at: [<0000000000638c22>] offline_pages.constprop.1+0xea/0x740
 #5:  (ksm_thread_mutex/1){+.+.+.}, at: [<000000000026a654>] ksm_memory_callback+0x48/0xd8

stack backtrace:
CPU: 1 Not tainted 3.5.0-rc7 #40
Process sh (pid: 698, task: 00000000d6b74850, ksp: 00000000d71c7ac0)
       00000000d71c78d8 00000000d71c78e8 0000000000000002 0000000000000000 
       00000000d71c7978 00000000d71c78f0 00000000d71c78f0 00000000001009e0 
       0000000000000000 0000000000000001 000000000000000b 000000000000000b 
       00000000d71c7938 00000000d71c78d8 0000000000000000 0000000000000000 
       0000000000660768 00000000001009e0 00000000d71c78d8 00000000d71c7928 
Call Trace:
([<00000000001008e6>] show_trace+0xee/0x144)
 [<000000000064436e>] print_circular_bug+0x2ee/0x300
 [<00000000001a22bc>] validate_chain+0x880/0x1154
 [<00000000001a5b42>] __lock_acquire+0x3f6/0xb28
 [<00000000001a69d2>] lock_acquire+0xbe/0x250
 [<000000000064d8a6>] down_read+0x66/0xdc
 [<0000000000165372>] __blocking_notifier_call_chain+0x5e/0xe0
 [<000000000016541e>] blocking_notifier_call_chain+0x2a/0x3c
 [<0000000000638d00>] offline_pages.constprop.1+0x1c8/0x740
 [<00000000004b5326>] memory_block_change_state+0x2aa/0x328
 [<00000000004b545e>] store_mem_state+0xba/0xf0
 [<000000000030b5f2>] sysfs_write_file+0xf6/0x1a8
 [<0000000000283a3a>] vfs_write+0x9a/0x184
 [<0000000000283d94>] SyS_write+0x58/0x94
 [<00000000006514f4>] sysc_noemu+0x22/0x28
 [<000003fffd5aa3e8>] 0x3fffd5aa3e8
INFO: lockdep is turned off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
