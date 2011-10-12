Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EA3EF6B005C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 04:19:56 -0400 (EDT)
Received: from mailer (213.65.94.224) by smtp-gw21.han.skanova.net (8.5.133)
        id 4E79D82C00AEDCFE for linux-mm@kvack.org; Wed, 12 Oct 2011 10:19:54 +0200
Received: from quad.localnet (quad.mlab.se [172.24.1.70])
	by mailer (8.14.4/8.14.4) with ESMTP id p9C8O2fF002669
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 10:24:03 +0200
From: Hans Schillstrom <hans@schillstrom.com>
Subject: possible slab deadlock while doing ifenslave
Date: Wed, 12 Oct 2011 10:19:52 +0200
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201110121019.53100.hans@schillstrom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,
I got this when I was testing a VLAN patch i.e. using Dave Millers net-next from today.
When doing this on a single core i686 I got the warning every time,
however ifenslave is not hanging it's just a warning
Have not been testing this on a multicore jet.

There is no warnings with a 3.0.4 kernel.

Is this a known warning ?

~ # ifenslave bond0 eth1 eth2

=============================================
[ INFO: possible recursive locking detected ]
3.1.0-rc9+ #3
---------------------------------------------
ifenslave/749 is trying to acquire lock:
 (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb

but task is already holding lock:
 (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(&(&parent->list_lock)->rlock);
  lock(&(&parent->list_lock)->rlock);

 *** DEADLOCK ***

 May be due to missing lock nesting notation

2 locks held by ifenslave/749:
 #0:  (rtnl_mutex){+.+.+.}, at: [<c1321884>] rtnl_lock+0x14/0x20
 #1:  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb

stack backtrace:
Pid: 749, comm: ifenslave Not tainted 3.1.0-rc9+ #3
Call Trace:
 [<c1421e14>] ? printk+0x2d/0x2f
 [<c1076a01>] __lock_acquire+0xdc1/0x18d0
 [<c1077ae2>] lock_acquire+0x82/0x1b0
 [<c14234a0>] ? cache_flusharray+0x41/0xdb
 [<c14291ec>] ? _raw_spin_unlock+0x2c/0x50
 [<c14289e2>] _raw_spin_lock+0x42/0x50
 [<c14234a0>] ? cache_flusharray+0x41/0xdb
 [<c14234a0>] cache_flusharray+0x41/0xdb
 [<c10fc378>] kmem_cache_free+0xa8/0x190
 [<c10fc56b>] slab_destroy+0x10b/0x140
 [<c10fc727>] free_block+0x187/0x1d0
 [<c14234e7>] cache_flusharray+0x88/0xdb
 [<c10fcc5e>] kfree+0x10e/0x220
 [<f815543d>] ? rtl8169_rx_clear+0x6d/0xa0 [r8169]
 [<c10fcc36>] ? kfree+0xe6/0x220
 [<f815543d>] ? rtl8169_rx_clear+0x6d/0xa0 [r8169]
 [<f815543d>] rtl8169_rx_clear+0x6d/0xa0 [r8169]
 [<f81563a0>] rtl8169_close+0x110/0x230 [r8169]
 [<c1311bd9>] __dev_close_many+0x69/0xb0
 [<c1045737>] ? local_bh_enable_ip+0x67/0xd0
 [<c1311c44>] __dev_close+0x24/0x40
 [<c13159a2>] __dev_change_flags+0x82/0x150
 [<c1321884>] ? rtnl_lock+0x14/0x20
 [<c1315b11>] dev_change_flags+0x21/0x60
 [<c1394140>] devinet_ioctl+0x5a0/0x710
 [<c13950cd>] inet_ioctl+0x8d/0xb0
 [<c12fd69f>] sock_ioctl+0x5f/0x270
 [<c12fd640>] ? sock_fasync+0xd0/0xd0
 [<c11180a6>] do_vfs_ioctl+0x86/0x5a0
 [<c106575b>] ? up_read+0x1b/0x30
 [<c102532b>] ? do_page_fault+0x18b/0x3c0
 [<c1108a67>] ? fget_light+0x167/0x2f0
 [<c130046c>] ? sys_socketcall+0x5c/0x2a0
 [<c11185f2>] sys_ioctl+0x32/0x60
 [<c1429f50>] sysenter_do_call+0x12/0x36


-- 
Regards
Hans Schillstrom <hans@schillstrom.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
