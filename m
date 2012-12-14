Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A27816B005D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 04:13:49 -0500 (EST)
Date: Fri, 14 Dec 2012 17:13:46 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: livelock in __writeback_inodes_wb ?
Message-ID: <20121214091346.GA8149@localhost>
References: <20121128145515.GA26564@redhat.com>
 <20121211082327.GA15706@localhost>
 <20121211134113.GA15801@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121211134113.GA15801@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org

On Tue, Dec 11, 2012 at 02:41:13PM +0100, Jan Kara wrote:
> On Tue 11-12-12 16:23:27, Wu Fengguang wrote:
> > On Wed, Nov 28, 2012 at 09:55:15AM -0500, Dave Jones wrote:
> > > We had a user report the soft lockup detector kicked after 22
> > > seconds of no progress, with this trace..
> > 
> > Where is the original report? The reporter may help provide some clues
> > on the workload that triggered the bug.
> > 
> > > :BUG: soft lockup - CPU#1 stuck for 22s! [flush-8:16:3137]
> > > :Pid: 3137, comm: flush-8:16 Not tainted 3.6.7-4.fc17.x86_64 #1
> > > :RIP: 0010:[<ffffffff812eeb8c>]  [<ffffffff812eeb8c>] __list_del_entry+0x2c/0xd0
> > > :Call Trace:
> > > : [<ffffffff811b783e>] redirty_tail+0x5e/0x80
> > > : [<ffffffff811b8212>] __writeback_inodes_wb+0x72/0xd0
> > > : [<ffffffff811b980b>] wb_writeback+0x23b/0x2d0
> > > : [<ffffffff811b9b5c>] wb_do_writeback+0xac/0x1f0
> > > : [<ffffffff8106c0e0>] ? __internal_add_timer+0x130/0x130
> > > : [<ffffffff811b9d2b>] bdi_writeback_thread+0x8b/0x230
> > > : [<ffffffff811b9ca0>] ? wb_do_writeback+0x1f0/0x1f0
> > > : [<ffffffff8107fde3>] kthread+0x93/0xa0
> > > : [<ffffffff81627e04>] kernel_thread_helper+0x4/0x10
> > > : [<ffffffff8107fd50>] ? kthread_freezable_should_stop+0x70/0x70
> > > : [<ffffffff81627e00>] ? gs_change+0x13/0x13
> > > 
> > > Looking over the code, is it possible that something could be
> > > dirtying pages faster than writeback can get them written out,
> > > keeping us in this loop indefitely ?
> > 
> > The bug reporter should know best whether there are heavy IO.
> > 
> > However I suspect it's not directly caused by heavy IO: we will
> > release &wb->list_lock before each __writeback_single_inode() call,
> > which starts writeback IO for each inode.
>   Umm, it's not about releasing wb->list_lock I think. Softlockup will
> trigger whenever we are looping in a kernel for more than given timeout
> (e.g. those 22 s) without sleeping.

Yes (and the spinlock is the typical reason to prevent it from sleeping).

> > > Should there be something in this loop periodically poking
> > > the watchdog perhaps ?
> > 
> > It seems we failed to release &wb->list_lock in wb_writeback() for
> > long time (dozens of seconds). That is, the inode_sleep_on_writeback()
> > is somehow not called. However it's not obvious to me how come this
> > can happen..
>   Maybe, progress is always non-zero but small and nr_pages is high (e.g.
> when writeback is triggered by wakeup_flusher_threads()). What filesystem
> is the guy using? I remember e.g. btrfs used to have always-dirty inodes
> which could confuse us.

Judging from the comm "flush-8:16", it's not btrfs. I cannot find the
reporter's email address in the original bug report. So we may at best
guess it's likely running the fedora's default filesystem. Also device
mapper is used judging from the boot param "rd.lvm.lv=vg_san-pc/lv_root".

> >From the backtrace it is clear there's some superblock which has s_umount
> locked and we cannot writeback inodes there. So if this superblock contains
> most of the dirty pages we need to write and there's another superblock
> with always dirty inode we would livelock like observed... So my question
> would be about what filesystems are there in the system (/proc/mounts),
> what load does trigger this, trigger sysrq-w when the lockup happens.

Yeah, it's likely related to some busy superblock.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
