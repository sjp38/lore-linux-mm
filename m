Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 4D3E26B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 19:33:52 -0400 (EDT)
Date: Fri, 21 Sep 2012 08:36:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] memory-hotplug: fix zone stat mismatch
Message-ID: <20120920233635.GJ13234@bbox>
References: <1348123405-30641-1-git-send-email-minchan@kernel.org>
 <20120920144232.a3e8b60f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120920144232.a3e8b60f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, Sep 20, 2012 at 02:42:32PM -0700, Andrew Morton wrote:
> On Thu, 20 Sep 2012 15:43:25 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > During memory-hotplug, I found NR_ISOLATED_[ANON|FILE]
> > are increasing so that kernel are hang out.
> > 
> > The cause is that when we do memory-hotadd after memory-remove,
> > __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
> > although vm_stat_diff of all CPU still have value.
> > 
> > In addtion, when we offline all pages of the zone, we reset them
> > in zone_pcp_reset without drain so that we lost zone stat item.
> > 
> 
> Here's what I ended up with for a changelog:
> 
> : During memory-hotplug, I found NR_ISOLATED_[ANON|FILE] are increasing,
> : causing the kernel to hang.  When the system doesn't have enough free
> : pages, it enters reclaim but never reclaim any pages due to
> : too_many_isolated()==true and loops forever.
> : 
> : The cause is that when we do memory-hotadd after memory-remove,
> : __zone_pcp_update() clears a zone's ZONE_STAT_ITEMS in setup_pageset()
> : although the vm_stat_diff of all CPUs still have values.
> : 
> : In addtion, when we offline all pages of the zone, we reset them in
> : zone_pcp_reset without draining so we loss some zone stat item.
> 

Thanks for clarifying the description, Andrew!

> 
> As memory hotplug seems fairly immature and broken, I'm thinking
> there's no point in backporting this into -stable.  And I don't *think*

I have no idea usecase of memory-hotplug in real practice.
If they do a ton of memory-hotadd/delete without rebooting
zone stat could be wrong. And it could turn for the worse
in case of using many CPUs.

Other zone stat items are not critical other than NR_ISOLATED
which could make system hang when VM start to reclaim heavily.
Anyway, If fujitsu guys don't yell, I'm okay. :)

> we really need it in 3.6 either?  (It doesn't apply cleanly to current
> mainline anyway - I didn't check why).

At least, it works in my side.

barrios@bbox:~/linux-2.6$ git log -n 1
commit c46de2263f42fb4bbde411b9126f471e9343cb22
Merge: 077fee0 2453f5f
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed Sep 19 11:04:34 2012 -0700

    Merge branch 'for-linus' of git://git.kernel.dk/linux-block
    
    Pull block fixes from Jens Axboe:
     "A small collection of driver fixes/updates and a core fix for 3.6.  It
      contains:
    
       - Bug fixes for mtip32xx, and support for new hardware (just addition
         of IDs).  They have been queued up for 3.7 for a few weeks as well.
    
       - rate-limit a failing command error message in block core.
    
       - A fix for an old cciss bug from Stephen.
    
       - Prevent overflow of partition count from Alan."
    
    * 'for-linus' of git://git.kernel.dk/linux-block:
      cciss: fix handling of protocol error
      blk: add an upper sanity check on partition adding
      mtip32xx: fix user_buffer check in exec_drive_command
      mtip32xx: Remove dead code
      mtip32xx: Change printk to pr_xxxx
      mtip32xx: Proper reporting of write protect status on big-endian
      mtip32xx: Increase timeout for standby command
      mtip32xx: Handle NCQ commands during the security locked state
      mtip32xx: Add support for new devices
      block: rate-limit the error message from failing commands

barrios@bbox:~/linux-2.6$ patch -p1 < ../linux-mmotm/0001-memory-hotplug-fix-zone-stat-mismatch.patch --dry-run
patching file include/linux/vmstat.h
patching file mm/page_alloc.c
Hunk #1 succeeded at 5874 (offset -30 lines).
Hunk #2 succeeded at 5891 (offset -30 lines).
patching file mm/vmstat.c

> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
