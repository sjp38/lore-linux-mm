Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A17F06B0044
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 07:59:37 -0500 (EST)
Date: Fri, 23 Nov 2012 11:13:17 +0100
From: Tomas Racek <tracek@redhat.com>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
Message-ID: <20121123101316.GA10295@luke.redhat.com>
Reply-To: 20121123085137.GA646@suse.de
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, riel@redhat.com

Hi Mel,

I've encoutered the same problem as George yesterday running xfstests in qemu with latest git sources:
 
 BUG: soft lockup - CPU#0 stuck for 23s! [kswapd0:31]
 irq event stamp: 9740956
 hardirqs last  enabled at (9740955): [<ffffffff8166c273>] restore_args+0x0/0x30
 hardirqs last disabled at (9740956): [<ffffffff8166d9ad>] apic_timer_interrupt+0x6d/0x80
 softirqs last  enabled at (9740954): [<ffffffff8105c887>] __do_softirq+0x167/0x3d0
 softirqs last disabled at (9740949): [<ffffffff8166e0fc>] call_softirq+0x1c/0x30
 CPU 0 
 Pid: 31, comm: kswapd0 Not tainted 3.7.0-rc6+ #232 Bochs Bochs
 Process kswapd0 (pid: 31, threadinfo ffff88003d2cc000, task ffff88003d2d8000)
 Call Trace:
  [<ffffffff8113bb81>] zone_watermark_ok_safe+0x71/0x100
  [<ffffffff8113baff>] ? zone_watermark_ok+0x1f/0x30
  [<ffffffff8114bd6e>] kswapd+0x2fe/0xd70
  [<ffffffff8114ba70>] ? try_to_free_pages+0x830/0x830
  [<ffffffff8107f9bd>] kthread+0xed/0x100
  [<ffffffff8107f8d0>] ? insert_kthread_work+0x80/0x80
  [<ffffffff8166cdac>] ret_from_fork+0x7c/0xb0
  [<ffffffff8107f8d0>] ? insert_kthread_work+0x80/0x80
 Code: 4c 2b 8f 00 01 00 00 48 d1 fa 49 39 d1 7e 30 31 c9 eb 20 0f 1f 80 00 00 00 00 48 8b 87 58 01 00 00 48 d1 fa 48 83 c7 58 48 d3 e0 <49> 29 c1 49 39 d1 7e 0f 83 c1 01 39 f1 75 e0 b8 01 00 00 00 5d 

Git bisect pointed me to:

c654345924f mm: remove __GFP_NO_KSWAPD

[adding Rik to Cc:]

Prior to this commit I wasn't able to reproduce it.

(BTW: I hope I managed to send this mail with proper Reply-To:, strangely your mail and those from Honza were not delivered to my mailbox.)

Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
