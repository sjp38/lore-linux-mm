Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF71B6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 13:19:40 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so22781112wib.4
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:19:40 -0800 (PST)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id i17si60599971wiv.21.2014.12.29.10.19.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 10:19:39 -0800 (PST)
Received: by mail-wg0-f43.google.com with SMTP id k14so1689806wgh.30
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:19:39 -0800 (PST)
Date: Mon, 29 Dec 2014 19:19:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141229181937.GE32618@dhcp22.suse.cz>
References: <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun 21-12-14 17:45:32, Tetsuo Handa wrote:
[...]
> Traces from uptime > 484 seconds of
> http://I-love.SAKURA.ne.jp/tmp/serial-20141221.txt.xz is a stalled case.
[  548.449780] Out of memory: Kill process 12718 (a.out) score 890 or sacrifice child
[...]
[  954.595576] a.out           D ffff8800764918a0     0 12718      1 0x00100084
[  954.597544]  ffff880077d7fca8 0000000000000086 ffff880076491470 ffff880077d7ffd8
[  954.599565]  0000000000013640 0000000000013640 ffff8800358c8210 ffff880076491470
[  954.601634]  0000000000000000 ffff88007c8a3e48 ffff88007c8a3e4c ffff880076491470
[  954.604091] Call Trace:
[  954.607766]  [<ffffffff81618669>] schedule_preempt_disabled+0x29/0x70
[  954.609792]  [<ffffffff8161a555>] __mutex_lock_slowpath+0xb5/0x120
[  954.611644]  [<ffffffff8161a5e3>] mutex_lock+0x23/0x37
[  954.613256]  [<ffffffffa025fb47>] xfs_file_buffered_aio_write.isra.9+0x77/0x270 [xfs]
[...]

and it seems that it is blocked by another allocator:
[  957.178207] a.out           R  running task        0 12804      1 0x00000084
[  957.180304] MemAlloc: 471962 jiffies on 0x10
[  957.181738]  ffff8800355df868 0000000000000086 ffff88007be98940 ffff8800355dffd8
[  957.183831]  0000000000013640 0000000000013640 ffff88007c4174b0 ffff88007be98940
[  957.185916]  0000000000000000 ffff8800355df940 0000000000000000 ffffffff81a621e8
[  957.188067] Call Trace:
[  957.189130]  [<ffffffff81618509>] _cond_resched+0x29/0x40
[  957.190790]  [<ffffffff8117752a>] shrink_slab+0x17a/0x1d0
[  957.192384]  [<ffffffff8117a330>] do_try_to_free_pages+0x280/0x450
[  957.194117]  [<ffffffff8117a5da>] try_to_free_pages+0xda/0x170
[  957.195800]  [<ffffffff8116db23>] __alloc_pages_nodemask+0x633/0xa50
[  957.197615]  [<ffffffff811b1ce7>] alloc_pages_current+0x97/0x110
[  957.199314]  [<ffffffff81164797>] __page_cache_alloc+0xa7/0xc0
[  957.201026]  [<ffffffff811652b0>] pagecache_get_page+0x70/0x1e0
[  957.202724]  [<ffffffff81165453>] grab_cache_page_write_begin+0x33/0x50
[  957.204546]  [<ffffffffa0252cb4>] xfs_vm_write_begin+0x34/0xe0 [xfs]

but this task managed to make some progress because we can clearly see
that pid 12718 (oom victim) managed to move on and get to OOM killer
many times
[  961.062042] a.out(12718) the OOM killer was skipped for 1965000 times.
[...]
[  983.140589] a.out(12718) the OOM killer was skipped for 2059000 times.

This shouldn't happen for the xfs pagecache allocation because
they all should be !__GFS_FS and we do not trigger OOM killer in
that case and fail instead. But as already pointed out by Dave
grab_cache_page_write_begin uses GFP_KERNEL for the radix tree
allocation and that would trigger the OOM killer. The rest is our
hopeless attempt to not fail the allocation. I believe that the patch
from http://marc.info/?l=linux-mm&m=141987483503279 should help in this
particular case. There are still other cases where we can livelock but
this seems to be a clear bug in grab_cache_page_write_begin.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
