Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id D358C6B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 13:43:19 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so4512292wgg.22
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 10:43:19 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id kj1si8288860wjc.17.2014.11.26.10.43.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Nov 2014 10:43:18 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id k14so4470130wgh.38
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 10:43:18 -0800 (PST)
Date: Wed, 26 Nov 2014 19:43:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
Message-ID: <20141126184316.GA31930@dhcp22.suse.cz>
References: <20141124165032.GA11745@curandero.mameluci.net>
 <alpine.DEB.2.10.1411241417250.7986@chino.kir.corp.google.com>
 <20141125103820.GA4607@dhcp22.suse.cz>
 <201411252154.GEF09368.QOLFSFJOFtOMVH@I-love.SAKURA.ne.jp>
 <20141125134558.GA4415@dhcp22.suse.cz>
 <201411262058.GAJ81735.OHFMOLQOSFtVJF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411262058.GAJ81735.OHFMOLQOSFtVJF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, linux-mm@kvack.org

On Wed 26-11-14 20:58:52, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 25-11-14 21:54:23, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > Let me clarify. The patch is sold as a security fix. In that context
> > > > vulnerability means a behavior which might be abused by a user. I was
> > > > merely interested whether there are some known scenarios which would
> > > > turn a potential OOM killer deadlock into an exploitable bug. The
> > > > changelog was rather unclear about it and rather strong in claims that
> > > > any user might trigger OOM deadlock.
> > > 
> > > Well, both of you are in the CC: list of my mail which includes a reproducer
> > > program which I sent on Thu, 26 Jun 2014 21:02:36 +0900.
> > 
> > OK, found the emails. There were more issues mentioned there. The below
> > one is from 24 Apr.
> 
> I posted various traces in that thread.
> 
> > So the task has been killed and it is waiting for parent to handle its
> > signal but that is blocked on memory allocation. The OOM victim is
> > TASK_DEAD so it has already passed exit_mm and should have released its
> > memory and it has dropped TIF_MEMDIE so it is ignored by OOM killer. It
> > is still holding some resources but those should be restricted and
> > shouldn't keep OOM condition normally.
> 
> Here is an example trace of 3.10.0-121.el7-test. Two of OOM-killed processes
> are inside task_work_run() from do_exit() and got stuck at memory allocation.
> Processes past exit_mm() in do_exit() contribute OOM deadlock.

If the OOM victim passed exit_mm then it is usually not interesting for
the OOM killer as it has already unmapped and freed its memory (assuming
that mm_users is not elevated). It also doesn't have TIF_MEMDIE anymore
so it doesn't block OOM killer from killing other tasks.

> (Am I using wrong word? Should I say livelock rather than deadlock?)

This depends on the situation. If the OOM victim would be blocked on a
lock held by another task which cannot proceed in allocation then it
would be a deadlock. While permanent retries because of memory shortage
would be more towards a livelock.

> [  234.118200] in:imjournal    R  running task        0   672      1 0x0000008e
> [  234.120266]  0000000000009bf4 ffffffff81dc2ee0 ffffffffffffff10 ffffffff815dde57
> [  234.122488]  0000000000000010 0000000000000202 ffff8800346593a0 0000000000000000
> [  234.124712]  ffff8800346593b8 ffffffff811ae769 0000000000000000 ffff8800346593f0
> [  234.126956] Call Trace:
> [  234.128030]  [<ffffffff815dde57>] ? _raw_spin_lock+0x37/0x50
> [  234.129765]  [<ffffffff811ae769>] ? put_super+0x19/0x40
> [  234.131410]  [<ffffffff811af8d4>] ? prune_super+0x144/0x1a0
> [  234.133125]  [<ffffffff8115103b>] ? shrink_slab+0xab/0x300
> [  234.134838]  [<ffffffff811a5ae1>] ? vmpressure+0x21/0x90
> [  234.136502]  [<ffffffff81154192>] ? do_try_to_free_pages+0x3c2/0x4e0
> [  234.138370]  [<ffffffff811543ac>] ? try_to_free_pages+0xfc/0x180
> [  234.140178]  [<ffffffff81148b4e>] ? __alloc_pages_nodemask+0x75e/0xb10
> [  234.142090]  [<ffffffff811855a9>] ? alloc_pages_current+0xa9/0x170
> [  234.143972]  [<ffffffffa0211b11>] ? xfs_buf_allocate_memory+0x16d/0x24a [xfs]
> [  234.146068]  [<ffffffffa01a23b5>] ? xfs_buf_get_map+0x125/0x180 [xfs]
> [  234.148008]  [<ffffffffa01a2d4c>] ? xfs_buf_read_map+0x2c/0x140 [xfs]
> [  234.149933]  [<ffffffffa0206089>] ? xfs_trans_read_buf_map+0x2d9/0x4a0 [xfs]
> [  234.151977]  [<ffffffffa01d3698>] ? xfs_btree_read_buf_block.isra.18.constprop.29+0x78/0xc0 [xfs]
> [  234.154399]  [<ffffffffa01a2dfa>] ? xfs_buf_read_map+0xda/0x140 [xfs]
> [  234.156330]  [<ffffffffa01d3760>] ? xfs_btree_lookup_get_block+0x80/0x100 [xfs]
> [  234.158438]  [<ffffffffa01d78e7>] ? xfs_btree_lookup+0xd7/0x4b0 [xfs]
> [  234.160362]  [<ffffffffa01bba0b>] ? xfs_alloc_lookup_eq+0x1b/0x20 [xfs]
> [  234.162318]  [<ffffffffa01be52e>] ? xfs_free_ag_extent+0x30e/0x750 [xfs]
> [  234.164286]  [<ffffffffa01bfa65>] ? xfs_free_extent+0xe5/0x120 [xfs]
> [  234.166187]  [<ffffffffa019eb2f>] ? xfs_bmap_finish+0x15f/0x1b0 [xfs]
> [  234.168101]  [<ffffffffa01ef5ed>] ? xfs_itruncate_extents+0x17d/0x2b0 [xfs]
> [  234.170112]  [<ffffffffa019fa0e>] ? xfs_free_eofblocks+0x1ee/0x270 [xfs]
> [  234.172081]  [<ffffffffa01ef97b>] ? xfs_release+0x13b/0x1e0 [xfs]
> [  234.173915]  [<ffffffffa01a6425>] ? xfs_file_release+0x15/0x20 [xfs]
> [  234.175807]  [<ffffffff811ad7a9>] ? __fput+0xe9/0x270
> [  234.177413]  [<ffffffff811ada7e>] ? ____fput+0xe/0x10
> [  234.179017]  [<ffffffff81082404>] ? task_work_run+0xc4/0xe0
> [  234.180778]  [<ffffffff81063ddb>] ? do_exit+0x2cb/0xa60
> [  234.182433]  [<ffffffff81094ebd>] ? ttwu_do_activate.constprop.87+0x5d/0x70
> [  234.184438]  [<ffffffff81097506>] ? try_to_wake_up+0x1b6/0x280
> [  234.186196]  [<ffffffff810645ef>] ? do_group_exit+0x3f/0xa0
> [  234.187887]  [<ffffffff81073ff0>] ? get_signal_to_deliver+0x1d0/0x6e0
> [  234.189773]  [<ffffffff81012437>] ? do_signal+0x57/0x600
> [  234.191423]  [<ffffffff81086ae0>] ? wake_up_bit+0x30/0x30
> [  234.193085]  [<ffffffff81012a41>] ? do_notify_resume+0x61/0xb0
> [  234.194840]  [<ffffffff815e7152>] ? int_signal+0x12/0x17
> 
> [  234.221720] abrt-watch-log  D ffff88007fa54540     0   587      1 0x00100086
> [  234.223804]  ffff88007be65a98 0000000000000046 ffff88007be65fd8 0000000000014540
> [  234.226018]  ffff88007be65fd8 0000000000014540 ffff880076fa71c0 ffff88007acf71c0
> [  234.228229]  ffff88007acf71c0 ffff8800757ee090 fffffffeffffffff ffff8800757ee098
> [  234.230453] Call Trace:
> [  234.231509]  [<ffffffff815dbf29>] schedule+0x29/0x70
> [  234.233091]  [<ffffffff815dda45>] rwsem_down_read_failed+0xf5/0x165
> [  234.234964]  [<ffffffffa019f8d2>] ? xfs_free_eofblocks+0xb2/0x270 [xfs]
> [  234.236890]  [<ffffffff812c27b4>] call_rwsem_down_read_failed+0x14/0x30
> [  234.238824]  [<ffffffff815db300>] ? down_read+0x20/0x30
> [  234.240505]  [<ffffffffa01ecfcc>] xfs_ilock+0xbc/0xe0 [xfs]
> [  234.242221]  [<ffffffffa019f8d2>] xfs_free_eofblocks+0xb2/0x270 [xfs]
> [  234.244114]  [<ffffffff81190c22>] ? kmem_cache_free+0x1b2/0x1d0
> [  234.245891]  [<ffffffff811c1a1f>] ? __d_free+0x3f/0x60
> [  234.247519]  [<ffffffffa01ef97b>] xfs_release+0x13b/0x1e0 [xfs]
> [  234.249300]  [<ffffffffa01a6425>] xfs_file_release+0x15/0x20 [xfs]
> [  234.251141]  [<ffffffff811ad7a9>] __fput+0xe9/0x270
> [  234.252699]  [<ffffffff811ada7e>] ____fput+0xe/0x10
> [  234.254254]  [<ffffffff81082404>] task_work_run+0xc4/0xe0
> [  234.255958]  [<ffffffff81063ddb>] do_exit+0x2cb/0xa60
> [  234.257552]  [<ffffffff811656ee>] ? __do_fault+0x7e/0x520
> [  234.259213]  [<ffffffff810645ef>] do_group_exit+0x3f/0xa0
> [  234.260877]  [<ffffffff81073ff0>] get_signal_to_deliver+0x1d0/0x6e0
> [  234.262723]  [<ffffffff81012437>] do_signal+0x57/0x600
> [  234.264398]  [<ffffffff8108a7ed>] ? hrtimer_nanosleep+0xad/0x170
> [  234.266199]  [<ffffffff81089780>] ? hrtimer_get_res+0x50/0x50
> [  234.267935]  [<ffffffff81012a41>] do_notify_resume+0x61/0xb0
> [  234.269665]  [<ffffffff815de33c>] retint_signal+0x48/0x8c

Without OOM report these traces are not useful very much. They are both
somewhere in exit_files and deferred fput. I am not sure how much memory
the process might hold at that time. I would be quite surprised if this
was the majority of the OOM victim's memory.

> > The OOM report was not complete so it is hard to say why the OOM
> > condition wasn't resolved by the OOM killer but other OOM report you
> > have posted (26 Apr) in that thread suggested that the system doesn't
> > have any swap and the page cache is full of shmem. The process list
> > didn't contain any large memory consumer so killing somebody wouldn't
> > help much. But the OOM victim died normally in that case:
> 
> The problem is that a.out invoked by a local unprivileged user is the only
> and the biggest memory consumer which the OOM killer thinks the least memory
> consumer.

Yes, because a.out doesn't consume to much of per-process accounted
memory. It's rss, ptes and swapped out memory is negligible to
the memory allocated on behalf of processes for in-kernel data
structures. This is quite unfortunate but this is basically "an
untrusted user on your computer has to be contained" scenario. Ulimits
should help to a certain degree and kmem accounting from memory cgroup
controller should help for dentries, inodes and fork bombs but there
might be other resources that might be unrestricted. If this is the case
then the OOM killer should be taught to consider them or added a
restriction for them. Later is preferable IMO. But adding a timeout to
OOM killer and hope that the next attempt will be more successful is
definitely not the right approach.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
