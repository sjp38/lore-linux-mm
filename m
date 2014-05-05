Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 926606B00A2
	for <linux-mm@kvack.org>; Mon,  5 May 2014 11:35:48 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so1500973eek.32
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:35:47 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 43si10555847eer.297.2014.05.05.08.35.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 05 May 2014 08:35:47 -0700 (PDT)
Date: Mon, 5 May 2014 11:35:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
Message-ID: <20140505153541.GB19914@cmpxchg.org>
References: <bug-75101-27@https.bugzilla.kernel.org/>
 <20140429152437.7324080a75d6fee914eb8307@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140429152437.7324080a75d6fee914eb8307@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: oliverml1@oli1170.net, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Maxim Patlasov <mpatlasov@parallels.com>, Jan Kara <jack@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>

Hi,

On Tue, Apr 29, 2014 at 03:24:37PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 29 Apr 2014 20:13:44 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=75101
> > 
> >             Bug ID: 75101
> >            Summary: [bisected] s2disk / hibernate blocks on "Saving 506031
> >                     image data pages () ..."
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: v3.14
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: oliverml1@oli1170.net
> >         Regression: No
> > 
> > Created attachment 134271
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=134271&action=edit
> > Full console trace with various SysRq outputs
> > 
> > Since v3.14 under normal desktop usage my s2disk/hibernate often blocks on the
> > saving of the image data ("Saving 506031 image data pages () ...").
> 
> A means to reproduce as well as a bisection result.  Nice!  Thanks.
> 
> Johannes, could you please take a look?
> 
> > With following test I can reproduce the problem reliably:
> > ---
> > 0) Boot
> > 
> > 1) Fill ram with 2GiB (+50% in my case)
> > 
> > mount -t tmpfs tmpfs /media/test/
> > dd if=/dev/zero of=/media/test/test0.bin bs=1k count=$[1024*1024]
> > dd if=/dev/zero of=/media/test/test1.bin bs=1k count=$[1024*1024]
> > 
> > 2) Do s2disk 
> > 
> > s2disk
> > 
> > ---
> > s2disk: Unable to switch virtual terminals, using the current console.
> > s2disk: Snapshotting system
> > s2disk: System snapshot ready. Preparing to write
> > s2disk: Image size: 2024124 kilobytes
> > s2disk: Free swap: 3791208 kilobytes
> > s2disk: Saving 506031 image data pages (press backspace to abort) ...   0%
> > 
> > #Problem>: ... there is stays and blocks. SysRq still responds, so that I could
> > trigger various debug outputs.

According to your dmesg s2disk is stuck in balance_dirty_pages():

[  215.645240] s2disk          D ffff88011fd93100     0  3323   3261 0x00000000
[  215.645240]  ffff8801196d4110 0000000000000082 0000000000013100 ffff8801196d4110
[  215.645240]  ffff8800365cdfd8 ffff880119ed9190 00000000ffffc16c ffff8800365cdbe8
[  215.645240]  0000000000000032 0000000000000032 ffff8801196d4110 0000000000000000
[  215.645240] Call Trace:
[  215.645240]  [<ffffffff8162fdce>] ? schedule_timeout+0xde/0xff
[  215.645240]  [<ffffffff81041be1>] ? ftrace_raw_output_tick_stop+0x55/0x55
[  215.645240]  [<ffffffff81630987>] ? io_schedule_timeout+0x5d/0x7e
[  215.645240]  [<ffffffff810cb035>] ? balance_dirty_pages_ratelimited+0x588/0x747
[  215.645240]  [<ffffffff812d0795>] ? radix_tree_tag_set+0x69/0xc4
[  215.645240]  [<ffffffff810c244e>] ? generic_file_buffered_write+0x1a8/0x21c
[  215.645240]  [<ffffffff810c351e>] ? __generic_file_aio_write+0x1c7/0x1fe
[  215.645240]  [<ffffffff81134ab5>] ? blkdev_aio_write+0x44/0x79
[  215.645240]  [<ffffffff8110c02a>] ? do_sync_write+0x56/0x76
[  215.645240]  [<ffffffff8110c33c>] ? vfs_write+0xa1/0xfb
[  215.645240]  [<ffffffff8110ca08>] ? SyS_write+0x41/0x74
[  215.645240]  [<ffffffff81637622>] ? system_call_fastpath+0x16/0x1b

but I don't see a flusher thread anywhere.

What the bisected change does is allow the effective dirty threshold
to drop fairly low, because anonymous pages are no longer considered
dirtyable, and your usecase has particularly low free + cache pages:

[  196.375988] active_anon:328150 inactive_anon:118571 isolated_anon:0
[  196.375988]  active_file:1658 inactive_file:1823 isolated_file:0
[  196.375988]  unevictable:867 dirty:616 writeback:0 unstable:0
[  196.375988]  free:32320 slab_reclaimable:5129 slab_unreclaimable:5080
[  196.375988]  mapped:2684 shmem:424844 pagetables:1528 bounce:0
[  196.375988]  free_cma:0

Ignoring free pages due to dirty_balance_reserve, inactive+active file
yields 3481 dirtyable pages, which sets the global limits to 174 pages
background and 348 pages foreground with the default configuration.
It's low, but not 0.  So why is the dirtier throttled to starvation
when the background flusher is not even running?  Shouldn't they be
looking at the same numbers and behave inversely?

I'll dive into the writeback and throttling code, but also Ccing
Maxim, Jan, and Fengguang.  Maybe they have a faster answer.

Thanks for the report!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
