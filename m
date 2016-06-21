Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B47426B025E
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:48:05 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id ot10so24290278obb.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 04:48:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p191si39665042ioe.171.2016.06.21.04.48.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 04:48:04 -0700 (PDT)
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
References: <20160616212641.GA3308@sig21.net>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <c9c87635-6e00-5ce7-b05a-966011c8fe3f@I-love.SAKURA.ne.jp>
Date: Tue, 21 Jun 2016 20:47:51 +0900
MIME-Version: 1.0
In-Reply-To: <20160616212641.GA3308@sig21.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Stezenbach <js@sig21.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

Johannes Stezenbach wrote:
> Hi,
> 
> a man's got to have a hobby, thus I'm running Android AOSP
> builds on my home PC which has 4GB of RAM, 4GB swap.
> Apparently it is not really adequate for the job but used to
> work with a 4.4.10 kernel.  Now I upgraded to 4.6.2
> and it crashes usually within 30mins during compilation.

Such reproducer is welcomed.
You might be hitting OOM livelock using innocent workload.

> The crash is a hard hang, mouse doesn't move, no reaction
> to keyboard, nothing in logs (systemd journal) after reboot.

Yes, it seems to me that your system is OOM livelocked.

It is sad that we haven't merged kmallocwd which will report
which memory allocations are stalling
 ( http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).

> 
> Then I tried 4.5.7, it seems to be stable so far.
> 
> I'm using dm-crypt + lvm + ext4 (swap also in lvm).
> 
> Now I hooked up a laptop to the serial port and captured
> some logs of the crash which seems to be repeating
> 
> [ 2240.842567] swapper/3: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
> or
> [ 2241.167986] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
> 
> over and over.  Based on the backtraces in the log I decided
> to hot-unplug USB devices, and twice the kernel came
> back to live, but on the 3rd crash it was dead for good.

The values

  DMA free:12kB min:32kB
  DMA32 free:2268kB min:6724kB
  Normal free:84kB min:928kB 

suggest that memory reserves are spent for pointless purpose. Maybe your system is
falling into situation which was mitigated by commit 78ebc2f7146156f4 ("mm,writeback:
don't use memory reserves for wb_start_writeback"). Thus, applying that commit to
your 4.6.2 kernel might help avoiding flood of these allocation failure messages.

> Before I pressed the reset button I used SysRq-W.  At the bottom
> is a "BUG: workqueue lockup", it could be the result of
> the log spew on serial console taking so long but it looks
> like some IO is never completing.

But even after you apply that commit, I guess you will still see silent hang up
because the page allocator would think there is still reclaimable memory. So, is
it possible to also try current linux.git kernels? I'd like to know whether
"OOM detection rework" (which went to 4.7) helps giving up reclaiming and
invoking the OOM killer with your workload.

Maybe __GFP_FS allocations start invoking the OOM killer. But maybe __GFP_FS
allocations still remain stuck waiting for !__GFP_FS allocations whereas !__GFP_FS
allocations gives up without invoking the OOM killer (i.e. effectively no "give up").

> 
> Below I'm pasting some log snippets, let me know if you like
> it so much you want more of it ;-/  The total log is about 1.7MB.

Yes, I'd like to browse it. Could you send it to me?

> [ 2378.279029] kswapd0         D ffff88003744f538     0   766      2 0x00000000
> [ 2378.286167]  ffff88003744f538 00ff88011b5ccd80 ffff88011b5d62d8 ffff88011ae58000
> [ 2378.293628]  ffff880037450000 ffff880037450000 00000001000984f2 ffff88003744f570
> [ 2378.301168]  ffff88011b5ccd80 ffff880037450000 ffff88003744f550 ffffffff81845cec
> [ 2378.308674] Call Trace:
> [ 2378.311154]  [<ffffffff81845cec>] schedule+0x8b/0xa3
> [ 2378.316153]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
> [ 2378.322028]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
> [ 2378.327931]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
> [ 2378.333960]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
> [ 2378.340166]  [<ffffffff81162c2b>] mempool_alloc+0x123/0x154
> [ 2378.345781]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
> [ 2378.351148]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
> [ 2378.356910]  [<ffffffff816342ea>] alloc_tio+0x2d/0x47
> [ 2378.361996]  [<ffffffff8163587e>] __split_and_process_bio+0x310/0x3a3
> [ 2378.368470]  [<ffffffff81635e15>] dm_make_request+0xb5/0xe2
> [ 2378.374078]  [<ffffffff81347ae7>] generic_make_request+0xcc/0x180
> [ 2378.380206]  [<ffffffff81347c98>] submit_bio+0xfd/0x145
> [ 2378.385482]  [<ffffffff81198948>] __swap_writepage+0x202/0x225
> [ 2378.391349]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
> [ 2378.397398]  [<ffffffff8184a5f7>] ? _raw_spin_unlock+0x31/0x44
> [ 2378.403273]  [<ffffffff8119a903>] ? page_swapcount+0x45/0x4c
> [ 2378.408984]  [<ffffffff811989a5>] swap_writepage+0x3a/0x3e
> [ 2378.414530]  [<ffffffff811727ef>] pageout.isra.16+0x160/0x2a7
> [ 2378.420320]  [<ffffffff81173a8f>] shrink_page_list+0x5a0/0x8c4
> [ 2378.426197]  [<ffffffff81174489>] shrink_inactive_list+0x29e/0x4a1
> [ 2378.432434]  [<ffffffff81174e8b>] shrink_zone_memcg+0x4c1/0x661
> [ 2378.438406]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
> [ 2378.443742]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
> [ 2378.449238]  [<ffffffff8117628f>] kswapd+0x6df/0x814
> [ 2378.454222]  [<ffffffff81175bb0>] ? mem_cgroup_shrink_node_zone+0x209/0x209
> [ 2378.461196]  [<ffffffff8109f208>] kthread+0xff/0x107
> [ 2378.466182]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
> [ 2378.471631]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea

Unfortunately, kswapd which attempted to swap out some page to
swap partition cannot make forward progress because memory allocation
for storage I/O is stalling.

> [ 2418.938946] Showing busy workqueues and worker pools:
> [ 2418.944034] workqueue events: flags=0x0
> [ 2418.947898]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=6/256
> [ 2418.954048]     in-flight: 31967:linkwatch_event
> [ 2418.958727]     pending: em28xx_ir_work [em28xx_rc], ieee80211_delayed_tailroom_dec [mac80211], console_callback, push_to_pool, do_cache_clean
> [ 2418.971728] workqueue events_freezable_power_: flags=0x84
> [ 2418.977180]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
> [ 2418.983277]     in-flight: 10655:disk_events_workfn

disk_events_workfn with in-flight suggests that storage I/O cannot make
forward progress because small (order <= 3) GFP_NOIO allocation request
issued by that work is looping forever inside page allocator. From my
experience, this indicates that your system is dead due to OOM livelock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
