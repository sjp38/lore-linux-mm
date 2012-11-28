Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id F248E6B0083
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 09:55:18 -0500 (EST)
Date: Wed, 28 Nov 2012 09:55:15 -0500
From: Dave Jones <davej@redhat.com>
Subject: livelock in __writeback_inodes_wb ?
Message-ID: <20121128145515.GA26564@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

We had a user report the soft lockup detector kicked after 22
seconds of no progress, with this trace..

:BUG: soft lockup - CPU#1 stuck for 22s! [flush-8:16:3137]
:Pid: 3137, comm: flush-8:16 Not tainted 3.6.7-4.fc17.x86_64 #1
:RIP: 0010:[<ffffffff812eeb8c>]  [<ffffffff812eeb8c>] __list_del_entry+0x2c/0xd0
:Call Trace:
: [<ffffffff811b783e>] redirty_tail+0x5e/0x80
: [<ffffffff811b8212>] __writeback_inodes_wb+0x72/0xd0
: [<ffffffff811b980b>] wb_writeback+0x23b/0x2d0
: [<ffffffff811b9b5c>] wb_do_writeback+0xac/0x1f0
: [<ffffffff8106c0e0>] ? __internal_add_timer+0x130/0x130
: [<ffffffff811b9d2b>] bdi_writeback_thread+0x8b/0x230
: [<ffffffff811b9ca0>] ? wb_do_writeback+0x1f0/0x1f0
: [<ffffffff8107fde3>] kthread+0x93/0xa0
: [<ffffffff81627e04>] kernel_thread_helper+0x4/0x10
: [<ffffffff8107fd50>] ? kthread_freezable_should_stop+0x70/0x70
: [<ffffffff81627e00>] ? gs_change+0x13/0x13

Looking over the code, is it possible that something could be
dirtying pages faster than writeback can get them written out,
keeping us in this loop indefitely ?

Should there be something in this loop periodically poking
the watchdog perhaps ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
