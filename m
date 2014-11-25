Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 28E286B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 08:46:02 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id w7so548075lbi.29
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:46:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bt13si2058337wjb.99.2014.11.25.05.46.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 05:46:00 -0800 (PST)
Date: Tue, 25 Nov 2014 14:45:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
Message-ID: <20141125134558.GA4415@dhcp22.suse.cz>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
 <201411231350.DDH78622.LOtOQOFMFSHFJV@I-love.SAKURA.ne.jp>
 <20141124165032.GA11745@curandero.mameluci.net>
 <alpine.DEB.2.10.1411241417250.7986@chino.kir.corp.google.com>
 <20141125103820.GA4607@dhcp22.suse.cz>
 <201411252154.GEF09368.QOLFSFJOFtOMVH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411252154.GEF09368.QOLFSFJOFtOMVH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, linux-mm@kvack.org

On Tue 25-11-14 21:54:23, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Let me clarify. The patch is sold as a security fix. In that context
> > vulnerability means a behavior which might be abused by a user. I was
> > merely interested whether there are some known scenarios which would
> > turn a potential OOM killer deadlock into an exploitable bug. The
> > changelog was rather unclear about it and rather strong in claims that
> > any user might trigger OOM deadlock.
> 
> Well, both of you are in the CC: list of my mail which includes a reproducer
> program which I sent on Thu, 26 Jun 2014 21:02:36 +0900.

OK, found the emails. There were more issues mentioned there. The below
one is from 24 Apr.
[   42.904325] Out of memory: Kill process 316 (firewalld) score 29 or sacrifice child
[   42.908797] Killed process 316 (firewalld) total-vm:327624kB, anon-rss:14900kB, file-rss:4kB
[   46.137191] SysRq : Changing Loglevel
[   46.138143] Loglevel set to 9
[   72.028990] SysRq : Show State
[...]
[   72.029945] systemd         R  running task        0     1      0 0x00000000
[   72.029945]  ffff88001efbb908 0000000000000086 ffff88001efbbfd8 0000000000014580
[   72.029945]  ffff88001efbbfd8 0000000000014580 ffff88001dc18000 ffff88001efba000
[   72.029945]  ffff88001efbba60 ffffffff8194eaa8 0000000000000034 0000000000000000
[   72.029945] Call Trace:
[   72.029945]  [<ffffffff81094ed6>] __cond_resched+0x26/0x30
[   72.029945]  [<ffffffff815f1cba>] _cond_resched+0x3a/0x50
[   72.029945]  [<ffffffff811538ec>] shrink_slab+0x1dc/0x300
[   72.029945]  [<ffffffff811a9721>] ? vmpressure+0x21/0x90
[   72.029945]  [<ffffffff81156982>] do_try_to_free_pages+0x3c2/0x4e0
[   72.029945]  [<ffffffff81156b9c>] try_to_free_pages+0xfc/0x180
[   72.029945]  [<ffffffff8114b2ce>] __alloc_pages_nodemask+0x75e/0xb10
[   72.029945]  [<ffffffff81188689>] alloc_pages_current+0xa9/0x170
[   72.029945]  [<ffffffff811419f7>] __page_cache_alloc+0x87/0xb0
[   72.029945]  [<ffffffff81143d48>] filemap_fault+0x188/0x430
[   72.029945]  [<ffffffff811682ce>] __do_fault+0x7e/0x520
[   72.029945]  [<ffffffff8116c615>] handle_mm_fault+0x3e5/0xd90
[   72.029945]  [<ffffffff810712d6>] ? dequeue_signal+0x86/0x180
[   72.029945]  [<ffffffff811f76e4>] ? ep_send_events_proc+0x174/0x1d0
[   72.029945]  [<ffffffff811f983c>] ? signalfd_copyinfo+0x1c/0x250
[   72.029945]  [<ffffffff815f7886>] __do_page_fault+0x156/0x540
[   72.029945]  [<ffffffff815f7c8a>] do_page_fault+0x1a/0x70
[   72.029945]  [<ffffffff811b03e8>] ? SyS_read+0x58/0xb0
[   72.029945]  [<ffffffff815f3ec8>] page_fault+0x28/0x30
[...]
[   72.029945] firewalld       x ffff88001fc14580     0   316      1 0x00100084
[   72.029945]  ffff88001cc1bcd0 0000000000000046 ffff88001cc1bfd8 0000000000014580
[   72.029945]  ffff88001cc1bfd8 0000000000014580 ffff88001b3cdb00 ffff88001b3ce300
[   72.029945]  ffff88001cc1b858 ffff88001cc1b858 ffff88001b3cdaf0 ffff88001b3cdb00
[   72.029945] Call Trace:
[   72.029945]  [<ffffffff815f18b9>] schedule+0x29/0x70
[   72.029945]  [<ffffffff81064207>] do_exit+0x6e7/0xa60
[   72.029945]  [<ffffffff811c3a40>] ? poll_select_copy_remaining+0x150/0x150
[   72.029945]  [<ffffffff810645ff>] do_group_exit+0x3f/0xa0
[   72.029945]  [<ffffffff81074000>] get_signal_to_deliver+0x1d0/0x6e0
[   72.029945]  [<ffffffff81012437>] do_signal+0x57/0x600
[   72.029945]  [<ffffffff811fb457>] ? eventfd_ctx_read+0x67/0x260
[   72.029945]  [<ffffffff81012a49>] do_notify_resume+0x69/0xb0
[   72.029945]  [<ffffffff815fcad2>] int_signal+0x12/0x17

So the task has been killed and it is waiting for parent to handle its
signal but that is blocked on memory allocation. The OOM victim is
TASK_DEAD so it has already passed exit_mm and should have released its
memory and it has dropped TIF_MEMDIE so it is ignored by OOM killer. It
is still holding some resources but those should be restricted and
shouldn't keep OOM condition normally.

The OOM report was not complete so it is hard to say why the OOM
condition wasn't resolved by the OOM killer but other OOM report you
have posted (26 Apr) in that thread suggested that the system doesn't
have any swap and the page cache is full of shmem. The process list
didn't contain any large memory consumer so killing somebody wouldn't
help much. But the OOM victim died normally in that case:
[  945.823514] kworker/u64:0 invoked oom-killer: gfp_mask=0x2000d0, order=2, oom_score_adj=0
[...]
[  945.907809] active_anon:1743 inactive_anon:24451 isolated_anon:0
[  945.907809]  active_file:49 inactive_file:215 isolated_file:0
[  945.907809]  unevictable:0 dirty:0 writeback:0 unstable:0
[  945.907809]  free:13233 slab_reclaimable:3264 slab_unreclaimable:6369
[  945.907809]  mapped:27 shmem:24795 pagetables:177 bounce:0
[  945.907809]  free_cma:0
[...]
[  945.959966] 25060 total pagecache pages
[  945.961567] 0 pages in swap cache
[  945.963053] Swap cache stats: add 0, delete 0, find 0/0
[  945.964930] Free swap  = 0kB
[  945.966324] Total swap = 0kB
[  945.967717] 524158 pages RAM
[  945.969103] 0 pages HighMem/MovableOnly
[  945.970692] 12583 pages reserved
[  945.972144] 0 pages hwpoisoned
[  945.973564] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  945.976012] [  464]     0   464    10364      248      22        0         -1000 systemd-udevd
[  945.978636] [  554]     0   554    12791      119      25        0         -1000 auditd
[  945.981118] [  661]    81   661     6850      276      19        0          -900 dbus-daemon
[  945.983689] [ 1409]     0  1409    20740      210      43        0         -1000 sshd
[  945.986124] [ 9393]     0  9393    27502       33      12        0             0 agetty
[  945.988611] [ 9641]  1000  9641     1042       21       7        0             0 a.out
[  945.991059] Out of memory: Kill process 9393 (agetty) score 0 or sacrifice child
[...]
[ 1048.924249] SysRq : Changing Loglevel
[ 1048.926059] Loglevel set to 9
[ 1050.892055] SysRq : Show State

Pid 9393 is not present in the following list.

So I really do not see any real issue here. Btw. it would be really
helpful if this was a in the changelog (without reproducer if you really
believe it could be abused).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
