Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E64896B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 13:24:46 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o89H6Kjt028470
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 13:06:20 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o89HOimL127262
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 13:24:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o89HOhOL003845
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 13:24:44 -0400
Subject: OOM panics with zram
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1281374816-904-1-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 09 Sep 2010 10:24:41 -0700
Message-ID: <1284053081.7586.7910.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Nitin,

I've been playing with using zram (from -staging) to back some qemu
guest memory directly.  Basically mmap()'ing the device in instead of
using anonymous memory.  The old code with the backing swap devices
seemed to work pretty well, but I'm running into a problem with the new
code.

I have plenty of swap on the system, and I'd been running with compcache
nicely for a while.  But, I went to go tar up (and gzip) a pretty large
directory in my qemu guest.  It panic'd the qemu host system:

[703826.003126] Kernel panic - not syncing: Out of memory and no killable processes...
[703826.003127] 
[703826.012350] Pid: 25508, comm: cat Not tainted 2.6.36-rc3-00114-g9b9913d #29
[703826.019385] Call Trace:
[703826.021928]  [<ffffffff8104032a>] panic+0xba/0x1e0
[703826.026801]  [<ffffffff810bb4a1>] ? next_online_pgdat+0x21/0x50
[703826.032799]  [<ffffffff810a7713>] ? find_lock_task_mm+0x23/0x60
[703826.038795]  [<ffffffff810a79ab>] ? dump_header+0x19b/0x1b0
[703826.044446]  [<ffffffff810a8157>] out_of_memory+0x297/0x2d0
[703826.050098]  [<ffffffff810abbaf>] __alloc_pages_nodemask+0x72f/0x740
[703826.056528]  [<ffffffff81110d4e>] ? __set_page_dirty+0x6e/0xc0
[703826.062438]  [<ffffffff810da477>] alloc_pages_current+0x87/0xd0
[703826.068438]  [<ffffffff810a533b>] __page_cache_alloc+0xb/0x10
[703826.074263]  [<ffffffff810ae2ff>] __do_page_cache_readahead+0xdf/0x220
[703826.080865]  [<ffffffff810ae45c>] ra_submit+0x1c/0x20
[703826.085998]  [<ffffffff810ae5f8>] ondemand_readahead+0xa8/0x1d0
[703826.091994]  [<ffffffff810ae797>] page_cache_async_readahead+0x77/0xc0
[703826.098595]  [<ffffffff810a6489>] generic_file_aio_read+0x259/0x6d0
[703826.104941]  [<ffffffff810eac21>] do_sync_read+0xd1/0x110
[703826.110418]  [<ffffffff810eb3f6>] vfs_read+0xc6/0x170
[703826.115547]  [<ffffffff810eb860>] sys_read+0x50/0x90
[703826.120591]  [<ffffffff81002c2b>] system_call_fastpath+0x16/0x1b

I have the feeling that the compcache device all of a sudden lost its
efficiency.  It can't do much about having non-compressible data stuck
in it, of course.

But, it used to be able to write things out to backing storage.  It
tries to return I/O errors when it runs out of space, but my system
didn't get that far.  It panic'd before it got the chance.

This seems like an issue that will probably crop up when we use zram as
a swap device too.  A panic seems like pretty undesirable behavior when
you've simply changed the kind of data being used.  Have you run into
this at all?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
