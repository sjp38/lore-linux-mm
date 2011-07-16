Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 455E76B007E
	for <linux-mm@kvack.org>; Sat, 16 Jul 2011 17:19:00 -0400 (EDT)
Date: Sat, 16 Jul 2011 23:18:50 +0200
From: Sebastian Siewior <sebastian@breakpoint.cc>
Subject: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
Message-ID: <20110716211850.GA23917@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, tglx@linutronix.de

Hi,

just hit the following with full debuging turned on:

| =============================================
| [ INFO: possible recursive locking detected ]
| 3.0.0-rc7-00088-g1765a36 #64
| ---------------------------------------------
| udevd/1054 is trying to acquire lock:
|  (&(&parent->list_lock)->rlock){..-...}, at: [<c00bf640>] cache_alloc_refill+0xac/0x868
|
| but task is already holding lock:
|  (&(&parent->list_lock)->rlock){..-...}, at: [<c00be47c>] cache_flusharray+0x58/0x148
|
| other info that might help us debug this:
|  Possible unsafe locking scenario:
|
|        CPU0
|        ----
|   lock(&(&parent->list_lock)->rlock);
|   lock(&(&parent->list_lock)->rlock);
|
|  *** DEADLOCK ***
|
|  May be due to missing lock nesting notation
|
| 1 lock held by udevd/1054:
|  #0:  (&(&parent->list_lock)->rlock){..-...}, at: [<c00be47c>] cache_flusharray+0x58/0x148
|
| stack backtrace:
| Call Trace:
| [ed077a30] [c0008034] show_stack+0x48/0x168 (unreliable)
| [ed077a70] [c006a184] __lock_acquire+0x15f8/0x1a14
| [ed077b10] [c006aa80] lock_acquire+0x7c/0x98
| [ed077b50] [c02f7160] _raw_spin_lock+0x3c/0x80
| [ed077b70] [c00bf640] cache_alloc_refill+0xac/0x868
| [ed077bd0] [c00bf4e0] kmem_cache_alloc+0x198/0x1c4
| [ed077bf0] [c01971ac] __debug_object_init+0x268/0x414
| [ed077c50] [c004ba24] rcuhead_fixup_activate+0x34/0x80
| [ed077c70] [c0196a1c] debug_object_activate+0xec/0x1a0
| [ed077ca0] [c007ef38] __call_rcu+0x38/0x1d4
| [ed077cc0] [c00bea44] slab_destroy+0x1f8/0x204
| [ed077d00] [c00beaac] free_block+0x5c/0x1e0
| [ed077d40] [c00be568] cache_flusharray+0x144/0x148
| [ed077d70] [c00be828] kmem_cache_free+0x118/0x13c
| [ed077d90] [c00b18a8] __put_anon_vma+0x88/0xf4
| [ed077da0] [c00b320c] unlink_anon_vmas+0x17c/0x180
| [ed077dd0] [c00ab364] free_pgtables+0x58/0xbc
| [ed077df0] [c00ae158] exit_mmap+0xe8/0x12c
| [ed077e60] [c002b63c] mmput+0x74/0x118
| [ed077e80] [c002fc90] exit_mm+0x13c/0x168
| [ed077eb0] [c0032450] do_exit+0x640/0x6b4
| [ed077f10] [c003250c] do_group_exit+0x48/0xa8
| [ed077f30] [c0032580] sys_exit_group+0x14/0x28
| [ed077f40] [c000ef14] ret_from_syscall+0x0/0x3c
| --- Exception: c01 at 0xfef5c9c
|     LR = 0xffaf988

haven't found a report of this so far.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
