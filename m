Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5B76B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 04:44:14 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id i57so455783yha.21
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 01:44:14 -0800 (PST)
Received: from peace.netnation.com (peace.netnation.com. [204.174.223.2])
        by mx.google.com with ESMTP id p66si766346ykd.75.2015.01.07.01.44.12
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 01:44:12 -0800 (PST)
Date: Wed, 7 Jan 2015 01:44:07 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Dirty pages underflow on 3.14.23
Message-ID: <20150107094407.GA3284@hostway.ca>
References: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Leon Romanovsky <leon@leon.nu>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 05, 2015 at 06:05:59PM -0500, Mikulas Patocka wrote:

> Hi
> 
> I would like to report a memory management bug where the dirty pages count 
> underflowed.

Hello!

I've been hitting this problem for a while now. I've seen it on:

3.12.9
3.14.4
3.16
3.16.6

When it occurs, /proc/vmstat shows nr_dirty values such as:

nr_dirty 4294967031 (3.12.9)
nr_dirty 4294967251 (3.16.6)

No other counters appear to be negative or have wrapped in 32 bits, and
/proc/meminfo is similar as with your report. See proc file copies and
.config here: http://0x.ca/sim/ref/3.16.6-blue/ (hosting box is this one)

> It happened after some time that the Dirty pages count underflowed, as can 
> be seen in /proc/meminfo. The underflow condition was persistent, 
> /proc/meminfo was showing the big value even when the system was 
> completely idle. The counter never returned to zero.
> 
> The system didn't crash, but it became very slow - because of the big 
> value in the "Dirty" field, lazy writing was not working anymore, any 
> process that created a dirty page triggered immediate writeback, which 
> slowed down the system very much. The only fix was to reboot the machine.

This is also the case with me, although each time it occurs it seems to
be when I'm running apt-get upgrade to apply updates. Today, it occurred
on 3.16.6 as I started an "apt-get update". It is still possible to dirty
new pages and make some progress, but it becomes unusably slow. It ends
up writing the same blocks forever (from blktrace | grep D);

 33,0    0     2776     1.220890482 20335  D   W 43765671 + 8 [kworker/u2:0]
 33,0    0     2783     1.221073198 20335  D   W 7439223 + 8 [kworker/u2:0]
 33,0    0     2791     1.224824452 20335  D   W 43765671 + 8 [kworker/u2:0]
 33,0    0     2800     1.232559686 20335  D   W 7439223 + 8 [kworker/u2:0]

> The kernel version where this happened is 3.14.23. The kernel is compiled 
> without SMP and with peemption. The system is single-core 32-bit x86.

Same. The only other oddity to note is that the IDE driver is still
enabled in my case; root is on /dev/md6 which is a RAID 1 of hde1, hdg1.

> I see that 3.14.24 containes some fix for underflow (commit 
> 6619741f17f541113a02c30f22a9ca22e32c9546, upstream commit 
> abe5f972912d086c080be4bde67750630b6fb38b), but it doesn't seem that that 
> commit fixes this condition. If you have a commit that could fix this, say 
> it.

That doesn't seem to have made it to 3.16.6, but it sounds like a
fairness thing more than a race fix. Vlastimil pointed at this as
possibly useful:

http://ozlabs.org/~akpm/mmots/broken-out/mm-protect-set_page_dirty-from-ongoing-truncation.patch

...but I can't reproduce this immediately. So far, I have to
forget about it for a while, then do an apt-get upgrade.

> MemTotal:         253504 kB

MemTotal:         639396 kB

640MB should be enough for anybody. :)

Hmm, just tried to shut it down as cleanly as possible with sysrq-s,
sysrq-u, and got:

SysRq : Emergency Sync
Emergency Sync complete
SysRq : Emergency Remount R/O
------------[ cut here ]------------
WARNING: CPU: 0 PID: 24535 at fs/ext3/inode.c:1590 ext3_ordered_writepage+0x7c/0x240()
Modules linked in: xt_recent ts_kmp xt_string nfnetlink_log e100 xt_hashlimit xt_state xt_REDIRECT nf_conntrack_ftp iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack [last unloaded: xt_recent]
CPU: 0 PID: 24535 Comm: kworker/u2:0 Not tainted 3.16.6-blue #51
Hardware name: MICRO-STAR INTERNATIONAL CO., LTD MS-6330/MS-6330, BIOS 6.00 PG 06/15/2001
Workqueue: writeback bdi_writeback_workfn (flush-9:6)
 00000000 00000000 dd3f5c70 c16091f1 dd3f5ca0 c103231b c17bf9ac 00000000
 00005fd7 c17e8a3b 00000636 c115db7c c115db7c e7c3d140 00000000 e4d673d0
 dd3f5cb0 c103235d 00000009 00000000 dd3f5cd8 c115db7c dd3f5cc8 c10fe13c
Call Trace:
 [<c16091f1>] dump_stack+0x16/0x18
 [<c103231b>] warn_slowpath_common+0x7b/0xa0
 [<c115db7c>] ? ext3_ordered_writepage+0x7c/0x240
 [<c115db7c>] ? ext3_ordered_writepage+0x7c/0x240
 [<c103235d>] warn_slowpath_null+0x1d/0x20
 [<c115db7c>] ext3_ordered_writepage+0x7c/0x240
 [<c10fe13c>] ? __set_page_dirty_buffers+0xc/0x90
 [<c10ad18b>] __writepage+0xb/0x30
 [<c10ad180>] ? mapping_tagged+0x10/0x10
 [<c10ad981>] write_cache_pages+0x161/0x3a0
 [<c12ef76d>] ? blk_finish_plug+0xd/0x30
 [<c10ad180>] ? mapping_tagged+0x10/0x10
 [<c10adbef>] generic_writepages+0x2f/0x60
 [<c10aef65>] do_writepages+0x35/0x40
 [<c10f7f6b>] __writeback_single_inode+0x3b/0x1e0
 [<c10f8860>] writeback_sb_inodes+0x160/0x2e0
 [<c10f8a4c>] __writeback_inodes_wb+0x6c/0xa0
 [<c10f8f22>] wb_writeback+0x1a2/0x240
 [<c10f93a9>] bdi_writeback_workfn+0x149/0x370
 [<c1045e1f>] process_one_work+0xef/0x310
 [<c1046718>] worker_thread+0xe8/0x410
 [<c1046630>] ? mod_delayed_work_on+0x60/0x60
 [<c1046630>] ? mod_delayed_work_on+0x60/0x60
 [<c104ab45>] kthread+0x95/0xb0
 [<c160cec0>] ret_from_kernel_thread+0x20/0x30
 [<c104aab0>] ? __kthread_parkme+0x60/0x60
---[ end trace ca1dc42be1a0b8e5 ]---
EXT4-fs (md7): re-mounted. Opts: (null)
EXT4-fs (md2): re-mounted. Opts: (null)
Emergency Remount complete
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs (md2): ext4_writepages: jbd2_start: 1024 pages, ino 9438915; err -30
EXT4-fs: 1219 callbacks suppressed

#define EROFS           30      /* Read-only file system */

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
