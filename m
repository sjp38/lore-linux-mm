Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 130946B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 10:38:52 -0400 (EDT)
Date: Mon, 22 Apr 2013 15:38:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130422143846.GA2675@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412045042.GA30622@dastard>
 <20130412151952.GA4944@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130412151952.GA4944@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

(Adding Jeff Moyer to the cc as I'm told he is interested in the blktrace)

On Fri, Apr 12, 2013 at 11:19:52AM -0400, Theodore Ts'o wrote:
> On Fri, Apr 12, 2013 at 02:50:42PM +1000, Dave Chinner wrote:
> > > If that is the case, one possible solution that comes to mind would be
> > > to mark buffer_heads that contain metadata with a flag, so that the
> > > flusher thread can write them back at the same priority as reads.
> > 
> > Ext4 is already using REQ_META for this purpose.
> 
> We're using REQ_META | REQ_PRIO for reads, not writes.
> 
> > I'm surprised that no-one has suggested "change the IO elevator"
> > yet.....
> 
> Well, testing to see if the stalls go away with the noop schedule is a
> good thing to try just to validate the theory.
> 

I still haven't tested with a different elevator. While this bug is
relatively high priority for me, there are still are other issues in the way.

TLDR: Flusher writes pages very quickly after processes dirty a buffer. Reads
starve flusher writes.

Now the ugliness and being a windbag.

I collected blktrace and some other logs and they are available at
http://www.csn.ul.ie/~mel/postings/stalls-20130419/log.tar.gz  and there
is a lot of stuff in there.  The unix time the test started is in the
first line of the file tests-timestamp-bisect . This can help figure out
how far into the test some of the other timestamped logs are

The kernel log with information from the lock_buffer debugging patch is
in dmesg-bisect-gitcheckout . The information in it is race-prone and
cannot be 100% trusted but it's still useful.

iostat is in iostat-bisect-gitcheckout 

Here are a few observations I got from the data.

1. flushers appear to acquire buffer locks *very* quickly after an
   application writes. Look for lines that look like

   "foo failed trylock without holder released 0 ms ago acquired 0 ms ago by bar"

   There are a lot of entries like this

	jbd2 239 flush-8:0 failed trylock without holder released 0 ms ago acquired 0 ms ago by 2124 tar
	jbd2 239 flush-8:0 failed trylock without holder released 0 ms ago acquired 0 ms ago by 2124 tar
	jbd2 2124 tar failed trylock without holder released 0 ms ago acquired 0 ms ago by 239 flush-8:0
	jbd2 239 flush-8:0 failed trylock without holder released 0 ms ago acquired 0 ms ago by 2124 tar
	jbd2 239 flush-8:0 failed trylock without holder released 0 ms ago acquired 0 ms ago by 2124 tar
	jbd2 239 flush-8:0 failed trylock without holder released 0 ms ago acquired 0 ms ago by 2124 tar
	jbd2 239 flush-8:0 failed trylock without holder released 0 ms ago acquired 0 ms ago by 2124 tar

   I expected flushers to be writing back the buffers just released in about
   5 seconds time, not immediately.  It may indicate that when flushers
   wake to clean expired inodes that it keeps cleaning inodes as they are
   being dirtied.

2. The flush thread can prevent a process making forward progress for
   a long time. Take this as an example

         jbd2 stalled dev 8,8 for 8168 ms lock holdtime 20692 ms
         Last Owner 239 flush-8:0 Acquired Stack
          [<ffffffff8100fd8a>] save_stack_trace+0x2a/0x50
          [<ffffffff811a3ad6>] set_lock_buffer_owner+0x86/0x90
          [<ffffffff811a72ee>] __block_write_full_page+0x16e/0x360
          [<ffffffff811a75b3>] block_write_full_page_endio+0xd3/0x110
          [<ffffffff811a7600>] block_write_full_page+0x10/0x20
          [<ffffffff811aa7f3>] blkdev_writepage+0x13/0x20
          [<ffffffff81119352>] __writepage+0x12/0x40
          [<ffffffff81119b56>] write_cache_pages+0x206/0x460
          [<ffffffff81119df5>] generic_writepages+0x45/0x70
          [<ffffffff8111accb>] do_writepages+0x1b/0x30
          [<ffffffff81199d60>] __writeback_single_inode+0x40/0x1b0
          [<ffffffff8119c40a>] writeback_sb_inodes+0x19a/0x350
          [<ffffffff8119c656>] __writeback_inodes_wb+0x96/0xc0
          [<ffffffff8119c8fb>] wb_writeback+0x27b/0x330
          [<ffffffff8119e300>] wb_do_writeback+0x190/0x1d0
          [<ffffffff8119e3c3>] bdi_writeback_thread+0x83/0x280
          [<ffffffff8106901b>] kthread+0xbb/0xc0
          [<ffffffff8159e1fc>] ret_from_fork+0x7c/0xb0
          [<ffffffffffffffff>] 0xffffffffffffffff

   This part is saying that we locked the buffer due to blkdev_writepage
   which I assume must be a metadata update. Based on where we lock the
   buffer, the only reason we would leave the buffer unlocked if this
   was an asynchronous write request leaving the buffer to be unlocked by
   end_buffer_async_write at some time in the future

         Last Owner Activity Stack: 239 flush-8:0
          [<ffffffff812aee61>] __blkdev_issue_zeroout+0x191/0x1a0
          [<ffffffff812aef51>] blkdev_issue_zeroout+0xe1/0xf0
          [<ffffffff8121abe9>] ext4_ext_zeroout.isra.30+0x49/0x60
          [<ffffffff8121ee47>] ext4_ext_convert_to_initialized+0x227/0x5f0
          [<ffffffff8121f8a3>] ext4_ext_handle_uninitialized_extents+0x2f3/0x3a0
          [<ffffffff8121ff57>] ext4_ext_map_blocks+0x5d7/0xa00
          [<ffffffff811f0715>] ext4_map_blocks+0x2d5/0x470
          [<ffffffff811f47da>] mpage_da_map_and_submit+0xba/0x2f0
          [<ffffffff811f52e0>] ext4_da_writepages+0x380/0x620
          [<ffffffff8111accb>] do_writepages+0x1b/0x30
          [<ffffffff81199d60>] __writeback_single_inode+0x40/0x1b0
          [<ffffffff8119c40a>] writeback_sb_inodes+0x19a/0x350
          [<ffffffff8119c656>] __writeback_inodes_wb+0x96/0xc0
          [<ffffffff8119c8fb>] wb_writeback+0x27b/0x330

   This part is indicating that at the time a process tried to acquire
   the buffer lock that flusher was off doing something else entirely.
   That points again to the metadata write being asynchronous.

         Current Owner 1829 stap
          [<ffffffff8100fd8a>] save_stack_trace+0x2a/0x50
          [<ffffffff811a3ad6>] set_lock_buffer_owner+0x86/0x90
          [<ffffffff8123a5b2>] do_get_write_access+0xd2/0x800
          [<ffffffff8123ae2b>] jbd2_journal_get_write_access+0x2b/0x50
          [<ffffffff81221249>] __ext4_journal_get_write_access+0x39/0x80
          [<ffffffff81229bca>] ext4_free_blocks+0x36a/0xbe0
          [<ffffffff8121c686>] ext4_remove_blocks+0x256/0x2d0
          [<ffffffff8121c905>] ext4_ext_rm_leaf+0x205/0x520
          [<ffffffff8121e64c>] ext4_ext_remove_space+0x4dc/0x750
          [<ffffffff8122051b>] ext4_ext_truncate+0x19b/0x1e0
          [<ffffffff811efde5>] ext4_truncate.part.61+0xd5/0xf0
          [<ffffffff811f0ee4>] ext4_truncate+0x34/0x90
          [<ffffffff811f382d>] ext4_setattr+0x18d/0x640
          [<ffffffff8118d3e2>] notify_change+0x1f2/0x3c0
          [<ffffffff811716f9>] do_truncate+0x59/0xa0
          [<ffffffff8117d3f6>] handle_truncate+0x66/0xa0
          [<ffffffff81181576>] do_last+0x626/0x820
          [<ffffffff81181823>] path_openat+0xb3/0x4a0
          [<ffffffff8118237d>] do_filp_open+0x3d/0xa0
          [<ffffffff81172869>] do_sys_open+0xf9/0x1e0
          [<ffffffff8117296c>] sys_open+0x1c/0x20
          [<ffffffff8159e2ad>] system_call_fastpath+0x1a/0x1f
          [<ffffffffffffffff>] 0xffffffffffffffff

   This is just showing where stap was trying to acquire the buffer lock
   truncating data.

3. The blktrace indicates that reads can starve writes from flusher

   While there are people that can look at a blktrace and find problems
   like they are rain man, I'm more like an ADHD squirrel when looking at
   a trace.  I wrote a script to look for what unrelated requests completed
   while an request got stalled for over a second. It seemed like something
   that a tool shoudl already exist for but I didn't find one unless btt
   can give the information somehow.

   Each delayed request is quite long but here is the first example
   discovered by the script

Request 4174 took 1.060828037 to complete
  239    W    260608696  [flush-8:0]
Request started time index 4.731862902
Inflight while queued
  239    W    260608696  [flush-8:0]
    239    W    260608072  [flush-8:0]
    239    W    260607872  [flush-8:0]
    239    W    260608488  [flush-8:0]
    239    W    260608472  [flush-8:0]
    239    W    260608568  [flush-8:0]
    239    W    260608008  [flush-8:0]
    239    W    260607728  [flush-8:0]
    239    W    260607112  [flush-8:0]
    239    W    260608544  [flush-8:0]
    239    W    260622168  [flush-8:0]
    239    W    271863816  [flush-8:0]
    239    W    260608672  [flush-8:0]
    239    W    260607944  [flush-8:0]
    239    W    203833687  [flush-8:0]
   1676    R    541999743 [watch-inbox-ope]
    239    W    260608240  [flush-8:0]
    239    W    203851359  [flush-8:0]
    239    W    272019768  [flush-8:0]
    239    W    260607272  [flush-8:0]
    239    W    260607992  [flush-8:0]
    239    W    483478791  [flush-8:0]
    239    W    260608528  [flush-8:0]
    239    W    260607456  [flush-8:0]
    239    W    261310704  [flush-8:0]
    239    W    260608200  [flush-8:0]
    239    W    260607744  [flush-8:0]
    239    W    204729015  [flush-8:0]
    239    W    204728927  [flush-8:0]
    239    W    260608584  [flush-8:0]
    239    W    260608352  [flush-8:0]
    239    W    270532504  [flush-8:0]
    239    W    260608600  [flush-8:0]
    239    W    260607152  [flush-8:0]
    239    W    260607888  [flush-8:0]
    239    W    260607192  [flush-8:0]
    239    W    260607568  [flush-8:0]
    239    W    260607632  [flush-8:0]
    239    W    271831080  [flush-8:0]
    239    W    260608312  [flush-8:0]
    239    W    260607440  [flush-8:0]
    239    W    204729023  [flush-8:0]
    239    W    260608056  [flush-8:0]
    239    W    272019776  [flush-8:0]
    239    W    260608632  [flush-8:0]
    239    W    260607704  [flush-8:0]
    239    W    271827168  [flush-8:0]
    239    W    260607208  [flush-8:0]
    239    W    260607384  [flush-8:0]
    239    W    260607856  [flush-8:0]
    239    W    260607320  [flush-8:0]
    239    W    271827160  [flush-8:0]
    239    W    260608152  [flush-8:0]
    239    W    261271552  [flush-8:0]
    239    W    260607168  [flush-8:0]
    239    W    260608088  [flush-8:0]
    239    W    260607480  [flush-8:0]
    239    W    260608424  [flush-8:0]
    239    W    260608040  [flush-8:0]
    239    W    260608400  [flush-8:0]
    239    W    260608224  [flush-8:0]
    239    W    260607680  [flush-8:0]
    239    W    260607808  [flush-8:0]
    239    W    266347440  [flush-8:0]
    239    W    260607776  [flush-8:0]
    239    W    260607512  [flush-8:0]
    239    W    266347280  [flush-8:0]
    239    W    260607424  [flush-8:0]
    239    W    260607656  [flush-8:0]
    239    W    260607976  [flush-8:0]
    239    W    260608440  [flush-8:0]
    239    W    260608272  [flush-8:0]
    239    W    260607536  [flush-8:0]
    239    W    260607920  [flush-8:0]
    239    W    260608456  [flush-8:0]
Complete since queueing
 1676    R    541999743 [watch-inbox-ope]
  239    W    203833687  [flush-8:0]
 1676    R    541999759 [watch-inbox-ope]
 1676    R    541999791 [watch-inbox-ope]
 1676    R    541999807 [watch-inbox-ope]
 1676    R    541999839 [watch-inbox-ope]
 1676    R    541999855 [watch-inbox-ope]
 1676    R    542210351 [watch-inbox-ope]
 1676    R    542210367 [watch-inbox-ope]
 1676    R    541999887 [watch-inbox-ope]
 1676    R    541999911 [watch-inbox-ope]
 1676    R    541999935 [watch-inbox-ope]
 1676    R    541999967 [watch-inbox-ope]
 1676   RM    540448791 [watch-inbox-ope]
 1676    R    541999983 [watch-inbox-ope]
 1676    R    542051791 [watch-inbox-ope]
 1676    R    541999999 [watch-inbox-ope]
 1676    R    541949839 [watch-inbox-ope]
 1676    R    541949871 [watch-inbox-ope]
 1676    R    541949903 [watch-inbox-ope]
 1676    R    541949935 [watch-inbox-ope]
 1676    R    541949887 [watch-inbox-ope]
 1676    R    542051823 [watch-inbox-ope]
 1676    R    541949967 [watch-inbox-ope]
 1676    R    542051839 [watch-inbox-ope]
 1676    R    541949999 [watch-inbox-ope]
 1676    R    541950015 [watch-inbox-ope]
 1676    R    541950031 [watch-inbox-ope]
 1676    R    541950047 [watch-inbox-ope]
 1676    R    541950063 [watch-inbox-ope]
 1676    R    542112079 [watch-inbox-ope]
 1676    R    542112095 [watch-inbox-ope]
 1676    R    542112111 [watch-inbox-ope]
 1676    R    542112127 [watch-inbox-ope]
 1676    R    542112847 [watch-inbox-ope]
 1676    R    542112863 [watch-inbox-ope]
 1676   RM    540461311 [watch-inbox-ope]
 1676   RM    540448799 [watch-inbox-ope]
 1676    R    542112879 [watch-inbox-ope]
 1676    R    541950087 [watch-inbox-ope]
 1676    R    541950111 [watch-inbox-ope]
 1676    R    542112895 [watch-inbox-ope]
 1676    R    541950127 [watch-inbox-ope]
 1676    R    541950159 [watch-inbox-ope]
 1676    R    541950175 [watch-inbox-ope]
 1676    R    541950191 [watch-inbox-ope]
 1676    R    541950207 [watch-inbox-ope]
 1676    R    541950239 [watch-inbox-ope]
 1676    R    541950255 [watch-inbox-ope]
 1676    R    541950287 [watch-inbox-ope]
 1676    R    541950303 [watch-inbox-ope]
 1676    R    541950319 [watch-inbox-ope]
 1676    R    542113103 [watch-inbox-ope]
 1676    R    541950343 [watch-inbox-ope]
 1676    R    541950367 [watch-inbox-ope]
 1676    R    541950399 [watch-inbox-ope]
 1676    R    542113119 [watch-inbox-ope]
 1676    R    542113135 [watch-inbox-ope]
 1676    R    541950415 [watch-inbox-ope]
 1676   RM    540448815 [watch-inbox-ope]
 1676    R    542113151 [watch-inbox-ope]
 1676    R    541950447 [watch-inbox-ope]
 1676    R    541950463 [watch-inbox-ope]
 1676    R    542113743 [watch-inbox-ope]
 1676    R    542113759 [watch-inbox-ope]
 1676    R    542113775 [watch-inbox-ope]
 1676    R    542113791 [watch-inbox-ope]
  239    W    203851359  [flush-8:0]
  239    W    204729015  [flush-8:0]
  239    W    204728927  [flush-8:0]
  239    W    204729023  [flush-8:0]
  239    W    260569008  [flush-8:0]
 1676    R    542145871 [watch-inbox-ope]
 1676    R    542145903 [watch-inbox-ope]
 1676    R    542145887 [watch-inbox-ope]
 1676    R    542154639 [watch-inbox-ope]
 1676    R    542154655 [watch-inbox-ope]
 1676    R    542154671 [watch-inbox-ope]
 1676    R    542154687 [watch-inbox-ope]
 1676    R    542154831 [watch-inbox-ope]
 1676    R    542154863 [watch-inbox-ope]
 1676    R    542157647 [watch-inbox-ope]
 1676    R    542157663 [watch-inbox-ope]
 1676    R    541950479 [watch-inbox-ope]
 1676    R    541950503 [watch-inbox-ope]
 1676    R    541950535 [watch-inbox-ope]
 1676    R    541950599 [watch-inbox-ope]
 1676    R    541950727 [watch-inbox-ope]
 1676    R    541950751 [watch-inbox-ope]
 1676    R    541950767 [watch-inbox-ope]
 1676   RM    540448823 [watch-inbox-ope]
 1676    R    541950783 [watch-inbox-ope]
 1676    R    541950807 [watch-inbox-ope]
 1676    R    541950839 [watch-inbox-ope]
 1676    R    541950855 [watch-inbox-ope]
 1676    R    541950879 [watch-inbox-ope]
 1676    R    541950895 [watch-inbox-ope]
 1676    R    541950919 [watch-inbox-ope]
 1676    R    541950951 [watch-inbox-ope]
 1676    R    541950959 [watch-inbox-ope]
 1676    R    541950975 [watch-inbox-ope]
 1676    R    541951007 [watch-inbox-ope]
 1676    R    541951023 [watch-inbox-ope]
 1676    R    541951055 [watch-inbox-ope]
 1676    R    541951087 [watch-inbox-ope]
 1676    R    541951103 [watch-inbox-ope]
 1676    R    541951119 [watch-inbox-ope]
 1676    R    541951143 [watch-inbox-ope]
 1676    R    541951167 [watch-inbox-ope]
 1676    R    542157679 [watch-inbox-ope]
 1676    R    542157695 [watch-inbox-ope]
 1676    R    541951183 [watch-inbox-ope]
 1676    R    541951215 [watch-inbox-ope]
 1676    R    541951231 [watch-inbox-ope]
 1676    R    542158223 [watch-inbox-ope]
 1676   RM    540448831 [watch-inbox-ope]
 1676    R    541951247 [watch-inbox-ope]
 1676    R    541951271 [watch-inbox-ope]
 1676    R    541951295 [watch-inbox-ope]
 1676    R    542158239 [watch-inbox-ope]
 1676    R    542158255 [watch-inbox-ope]
 1676    R    541951311 [watch-inbox-ope]
 1676    R    542158271 [watch-inbox-ope]
 1676    R    541951343 [watch-inbox-ope]
 1676    R    541951359 [watch-inbox-ope]
 1676    R    541951391 [watch-inbox-ope]
 1676    R    541951407 [watch-inbox-ope]
 1676    R    541951423 [watch-inbox-ope]
 1676    R    541951439 [watch-inbox-ope]
 1676    R    541951471 [watch-inbox-ope]
 1676    R    542158607 [watch-inbox-ope]
 1676    R    541951487 [watch-inbox-ope]
 1676    R    542158639 [watch-inbox-ope]
 1676    R    542158655 [watch-inbox-ope]
 1676    R    542187215 [watch-inbox-ope]
 1676    R    542187231 [watch-inbox-ope]
 1676    R    542187247 [watch-inbox-ope]
 1676    R    541951503 [watch-inbox-ope]
 1676   RM    540448839 [watch-inbox-ope]
 1676    R    542187263 [watch-inbox-ope]
 1676    R    541951535 [watch-inbox-ope]
 1676    R    541951551 [watch-inbox-ope]
 1676    R    541951599 [watch-inbox-ope]
 1676    R    541951575 [watch-inbox-ope]
 1676    R    542190607 [watch-inbox-ope]
  239    W    261310704  [flush-8:0]
  239    W    266347280  [flush-8:0]
  239    W    266347440  [flush-8:0]
 1676    R    542190623 [watch-inbox-ope]
 1676    R    542190639 [watch-inbox-ope]
 1676    R    542190655 [watch-inbox-ope]
 1676    R    542193999 [watch-inbox-ope]
 1676    R    542194015 [watch-inbox-ope]
 1676    R    541951631 [watch-inbox-ope]
 1676    R    541951663 [watch-inbox-ope]
 1676    R    541951679 [watch-inbox-ope]
 1676    R    541951711 [watch-inbox-ope]
 1676    R    541951727 [watch-inbox-ope]
 1676    R    541951743 [watch-inbox-ope]
 1676    R    542194031 [watch-inbox-ope]
 1676    R    542194047 [watch-inbox-ope]
 1676    R    542197711 [watch-inbox-ope]
 1676   RM    540448847 [watch-inbox-ope]
 1676    R    541951759 [watch-inbox-ope]
 1676    R    541951783 [watch-inbox-ope]
 1676    R    541951807 [watch-inbox-ope]
 1676    R    542197727 [watch-inbox-ope]
 1676    R    542197743 [watch-inbox-ope]
 1676    R    542197759 [watch-inbox-ope]
 1676    R    541951823 [watch-inbox-ope]
 1676    R    541951855 [watch-inbox-ope]
 1676    R    541951871 [watch-inbox-ope]
 1676    R    541951895 [watch-inbox-ope]
 1676    R    541951919 [watch-inbox-ope]
 1676    R    541951935 [watch-inbox-ope]
 1676    R    541951951 [watch-inbox-ope]
 1676    R    541951967 [watch-inbox-ope]
 1676    R    541951983 [watch-inbox-ope]
 1676    R    542207567 [watch-inbox-ope]
 1676    R    542207599 [watch-inbox-ope]
 1676    R    542210383 [watch-inbox-ope]
 1676    R    542210399 [watch-inbox-ope]
 1676    R    542210415 [watch-inbox-ope]
 1676    R    542210431 [watch-inbox-ope]
 1676   RM    540448855 [watch-inbox-ope]
 1676    R    541952015 [watch-inbox-ope]
 1676    R    541952047 [watch-inbox-ope]
 1676    R    541952063 [watch-inbox-ope]
 1676    R    541952079 [watch-inbox-ope]
 1676    R    541952103 [watch-inbox-ope]
 1676    R    541952127 [watch-inbox-ope]
 1676    R    541952159 [watch-inbox-ope]
 1676    R    541952175 [watch-inbox-ope]
 1676    R    541952207 [watch-inbox-ope]
 1676    R    541952223 [watch-inbox-ope]
 1676    R    541952255 [watch-inbox-ope]
 1676    R    541952303 [watch-inbox-ope]
 1676    R    541952319 [watch-inbox-ope]
 1676    R    541952335 [watch-inbox-ope]
 1676    R    541952351 [watch-inbox-ope]
 1676    R    541952383 [watch-inbox-ope]
 1676    R    542051855 [watch-inbox-ope]
 1676    R    542051871 [watch-inbox-ope]
 1676    R    542051887 [watch-inbox-ope]
 1676    R    542051903 [watch-inbox-ope]
 1676    R    542051919 [watch-inbox-ope]
 1676    R    541952391 [watch-inbox-ope]
 1676    R    541952415 [watch-inbox-ope]
 1676   RM    540448863 [watch-inbox-ope]
 1676    R    542051935 [watch-inbox-ope]
 1676    R    541952431 [watch-inbox-ope]
 1676    R    541952447 [watch-inbox-ope]
 1676    R    541952463 [watch-inbox-ope]
 1676    R    541952487 [watch-inbox-ope]
 1676    R    541952511 [watch-inbox-ope]
 1676    R    541952527 [watch-inbox-ope]
 1676    R    541952559 [watch-inbox-ope]
 1676    R    541952607 [watch-inbox-ope]
 1676    R    541952623 [watch-inbox-ope]
 1676    R    542051951 [watch-inbox-ope]
 1676    R    541952639 [watch-inbox-ope]
 1676    R    542112271 [watch-inbox-ope]
  239    W    261271552  [flush-8:0]
  239    W    270532504  [flush-8:0]
  239    W    271827168  [flush-8:0]
  239    W    271827160  [flush-8:0]
  239    W    271831080  [flush-8:0]
 1676    R    542112287 [watch-inbox-ope]
 1676    R    542112303 [watch-inbox-ope]
 1676    R    542112319 [watch-inbox-ope]
 1676    R    542112335 [watch-inbox-ope]
 1676    R    542112351 [watch-inbox-ope]
 1676    R    542112367 [watch-inbox-ope]
 1676    R    542112383 [watch-inbox-ope]
 1676    R    542112655 [watch-inbox-ope]
 1676   RM    540448871 [watch-inbox-ope]
 1676    R    542112671 [watch-inbox-ope]
 1676    R    542112687 [watch-inbox-ope]
 1676    R    542112703 [watch-inbox-ope]
 1676    R    542112719 [watch-inbox-ope]
 1676    R    542112735 [watch-inbox-ope]
 1676    R    541952655 [watch-inbox-ope]
 1676    R    541952687 [watch-inbox-ope]
 1676    R    541952703 [watch-inbox-ope]
 1676    R    541952735 [watch-inbox-ope]
 1676    R    541952751 [watch-inbox-ope]
 1676    R    542112751 [watch-inbox-ope]
 1676    R    541952767 [watch-inbox-ope]
 1676    R    541952783 [watch-inbox-ope]
 1676    R    541952799 [watch-inbox-ope]
 1676    R    541952815 [watch-inbox-ope]
 1676    R    541952831 [watch-inbox-ope]
 1676    R    541952863 [watch-inbox-ope]
 1676    R    541952879 [watch-inbox-ope]
 1676    R    542113807 [watch-inbox-ope]
 1676    R    541952903 [watch-inbox-ope]
 1676    R    541952935 [watch-inbox-ope]
 1676   RM    540448879 [watch-inbox-ope]
 1676    R    541952959 [watch-inbox-ope]
 1676    R    542113823 [watch-inbox-ope]
 1676    R    542113839 [watch-inbox-ope]
 1676    R    542113855 [watch-inbox-ope]
 1676    R    541952975 [watch-inbox-ope]
 1676    R    541952991 [watch-inbox-ope]
 1676    R    541953007 [watch-inbox-ope]
 1676    R    541953023 [watch-inbox-ope]
 1676    R    541953055 [watch-inbox-ope]
 1676    R    541953071 [watch-inbox-ope]
 1676    R    541953103 [watch-inbox-ope]
 1676    R    541953119 [watch-inbox-ope]
 1676    R    541953135 [watch-inbox-ope]
 1676    R    542113871 [watch-inbox-ope]
 1676    R    542113887 [watch-inbox-ope]
 1676    R    541953167 [watch-inbox-ope]
 1676    R    541953191 [watch-inbox-ope]
 1676    R    541953223 [watch-inbox-ope]
 1676    R    541953247 [watch-inbox-ope]
 1676    R    541953263 [watch-inbox-ope]
 1676    R    541953279 [watch-inbox-ope]
 1676   RM    540448887 [watch-inbox-ope]
 1676    R    541953303 [watch-inbox-ope]
 1676    R    541953327 [watch-inbox-ope]
 1676    R    542113903 [watch-inbox-ope]
 1676    R    542113919 [watch-inbox-ope]
 1676    R    541953359 [watch-inbox-ope]
 1676    R    541953375 [watch-inbox-ope]
 1676    R    541953391 [watch-inbox-ope]
 1676    R    541953407 [watch-inbox-ope]
 1676    R    542145679 [watch-inbox-ope]
 1676    R    542145695 [watch-inbox-ope]
 1676    R    542145711 [watch-inbox-ope]
 1676    R    542145727 [watch-inbox-ope]
 1676    R    542145743 [watch-inbox-ope]
 1676    R    541953423 [watch-inbox-ope]
 1676    R    542145759 [watch-inbox-ope]
 1676    R    541953455 [watch-inbox-ope]
 1676    R    541953471 [watch-inbox-ope]
 1676    R    542145775 [watch-inbox-ope]
 1676    R    542145791 [watch-inbox-ope]
 1676    R    541953487 [watch-inbox-ope]
 1676    R    541953519 [watch-inbox-ope]
 1676   RM    540448895 [watch-inbox-ope]
 1676    R    541953535 [watch-inbox-ope]
 1676    R    541953551 [watch-inbox-ope]
 1676    R    541953567 [watch-inbox-ope]
 1676    R    541953599 [watch-inbox-ope]
 1676    R    541953615 [watch-inbox-ope]
 1676    R    541953631 [watch-inbox-ope]
 1676    R    541953647 [watch-inbox-ope]
 1676    R    542157455 [watch-inbox-ope]
 1676    R    542157471 [watch-inbox-ope]
 1676    R    542157487 [watch-inbox-ope]
 1676    R    541953671 [watch-inbox-ope]
 1676   RA    540386719 [watch-inbox-ope]
 1676   RA    540386727 [watch-inbox-ope]
 1676   RA    540386735 [watch-inbox-ope]
 1676   RA    540386743 [watch-inbox-ope]
 1676   RA    540386751 [watch-inbox-ope]
 1676   RA    540386759 [watch-inbox-ope]
 1676   RA    540386767 [watch-inbox-ope]
 1676   RA    540386775 [watch-inbox-ope]
 1676   RA    540386783 [watch-inbox-ope]
 1676   RA    540386791 [watch-inbox-ope]
 1676   RA    540386799 [watch-inbox-ope]
 1676   RA    540386807 [watch-inbox-ope]
 1676   RA    540386815 [watch-inbox-ope]
 1676   RA    540386823 [watch-inbox-ope]
 1676   RA    540386831 [watch-inbox-ope]
 1676   RA    540386839 [watch-inbox-ope]
 1676   RA    540386847 [watch-inbox-ope]
 1676   RA    540386855 [watch-inbox-ope]
 1676   RA    540386863 [watch-inbox-ope]
 1676   RA    540386871 [watch-inbox-ope]
 1676   RA    540386879 [watch-inbox-ope]
 1676   RA    540386887 [watch-inbox-ope]
 1676   RA    540386895 [watch-inbox-ope]
 1676   RA    540386903 [watch-inbox-ope]
 1676   RA    540386911 [watch-inbox-ope]
 1676   RA    540386919 [watch-inbox-ope]
 1676   RA    540386927 [watch-inbox-ope]
 1676   RA    540386935 [watch-inbox-ope]
 1676   RA    540386943 [watch-inbox-ope]
 1676   RA    540386951 [watch-inbox-ope]
 1676   RA    540386959 [watch-inbox-ope]
 1676   RM    540386711 [watch-inbox-ope]
  239    W    271863816  [flush-8:0]
  239    W    272019768  [flush-8:0]
  239    W    272019776  [flush-8:0]
  239    W    483478791  [flush-8:0]
  239    W    260578312  [flush-8:0]
  239    W    260578400  [flush-8:0]
 1676    R    541953695 [watch-inbox-ope]
 1676    R    541953711 [watch-inbox-ope]
 1676    R    542157503 [watch-inbox-ope]
 1676    R    541953743 [watch-inbox-ope]
 1676    R    541953759 [watch-inbox-ope]
 1676    R    541953775 [watch-inbox-ope]
 1676    R    542157519 [watch-inbox-ope]
 1676    R    541953791 [watch-inbox-ope]
 1676    R    542157551 [watch-inbox-ope]
 1676    R    541953807 [watch-inbox-ope]
 1676    R    541953831 [watch-inbox-ope]
 1676    R    541953863 [watch-inbox-ope]
 1676    R    541953927 [watch-inbox-ope]
 1676    R    541954055 [watch-inbox-ope]
 1676   RM    540448903 [watch-inbox-ope]
 1676    R    542157567 [watch-inbox-ope]
 1676    R    541954127 [watch-inbox-ope]
 1676    R    541954143 [watch-inbox-ope]
 1676    R    541954159 [watch-inbox-ope]
 1676    R    541954183 [watch-inbox-ope]
 1676    R    541954207 [watch-inbox-ope]
 1676    R    541954223 [watch-inbox-ope]
 1676    R    541954239 [watch-inbox-ope]
 1676    R    541954255 [watch-inbox-ope]
 1676    R    541954271 [watch-inbox-ope]
 1676    R    541954287 [watch-inbox-ope]
 1676    R    541954319 [watch-inbox-ope]
 1676    R    541954335 [watch-inbox-ope]
 1676    R    541954351 [watch-inbox-ope]
 1676    R    541954367 [watch-inbox-ope]
 1676    R    541954391 [watch-inbox-ope]
 1676    R    541954415 [watch-inbox-ope]
 1676    R    541954431 [watch-inbox-ope]
 1676    R    541954455 [watch-inbox-ope]
 1676    R    541954479 [watch-inbox-ope]
 1676    R    541954495 [watch-inbox-ope]
 1676   RM    540456719 [watch-inbox-ope]
  239    W    260622168  [flush-8:0]
  239    W    260625528  [flush-8:0]
  239    W    260625608  [flush-8:0]
  239    W    260614368  [flush-8:0]
  239    W    260614336  [flush-8:0]
  239    W    260614304  [flush-8:0]
  239    W    260614280  [flush-8:0]
 1676    R    541954511 [watch-inbox-ope]
 1676    R    541954527 [watch-inbox-ope]
 1676    R    541954543 [watch-inbox-ope]
 1676    R    541954567 [watch-inbox-ope]
 1676    R    541954599 [watch-inbox-ope]
 1676    R    541954607 [watch-inbox-ope]
 1676    R    541954623 [watch-inbox-ope]
 1676    R    541954655 [watch-inbox-ope]
 1676    R    541954671 [watch-inbox-ope]
 1676    R    541954687 [watch-inbox-ope]
 1676    R    542158351 [watch-inbox-ope]
 1676    R    542158367 [watch-inbox-ope]
 1676    R    542158383 [watch-inbox-ope]
 1676    R    542158399 [watch-inbox-ope]
 1676    R    542158415 [watch-inbox-ope]
 1676    R    541954703 [watch-inbox-ope]
 1676    R    541954727 [watch-inbox-ope]
 1676    R    541954751 [watch-inbox-ope]
 1676    R    542158431 [watch-inbox-ope]
 1676    R    542158447 [watch-inbox-ope]
 1676    R    542158463 [watch-inbox-ope]
 1676    R    541954767 [watch-inbox-ope]
 1676   RM    540456727 [watch-inbox-ope]
 1676    R    541954831 [watch-inbox-ope]
 1676    R    541954863 [watch-inbox-ope]
 1676    R    541954783 [watch-inbox-ope]
 1676    R    541954799 [watch-inbox-ope]
 1676    R    541954895 [watch-inbox-ope]
 1676    R    541954911 [watch-inbox-ope]
 1676    R    541954927 [watch-inbox-ope]
 1676    R    541954943 [watch-inbox-ope]
 1676    R    542158479 [watch-inbox-ope]
 1676    R    541954959 [watch-inbox-ope]
 1676    R    542158495 [watch-inbox-ope]
 1676    R    541954983 [watch-inbox-ope]
 1676    R    541955007 [watch-inbox-ope]
 1676    R    541955023 [watch-inbox-ope]
 1676    R    541955047 [watch-inbox-ope]
 1676    R    541955071 [watch-inbox-ope]
 1676    R    541955087 [watch-inbox-ope]
 1676    R    541955119 [watch-inbox-ope]
 1676    R    541955183 [watch-inbox-ope]
  239    W    260607112  [flush-8:0]
  239    W    260607152  [flush-8:0]
  239    W    260607168  [flush-8:0]
  239    W    260607192  [flush-8:0]
  239    W    260607208  [flush-8:0]
  239    W    260607272  [flush-8:0]
  239    W    260607320  [flush-8:0]
  239    W    260607384  [flush-8:0]
  239    W    260607424  [flush-8:0]
  239    W    260607440  [flush-8:0]
  239    W    260607456  [flush-8:0]
  239    W    260607480  [flush-8:0]
  239    W    260607512  [flush-8:0]
  239    W    260607536  [flush-8:0]
  239    W    260607568  [flush-8:0]
  239    W    260607632  [flush-8:0]
  239    W    260607656  [flush-8:0]
  239    W    260607680  [flush-8:0]
  239    W    260607704  [flush-8:0]
  239    W    260607728  [flush-8:0]
  239    W    260607744  [flush-8:0]
  239    W    260607776  [flush-8:0]
  239    W    260607808  [flush-8:0]
  239    W    260607856  [flush-8:0]
  239    W    260607872  [flush-8:0]
  239    W    260607888  [flush-8:0]
  239    W    260607920  [flush-8:0]
  239    W    260607944  [flush-8:0]
  239    W    260607976  [flush-8:0]
  239    W    260607992  [flush-8:0]
  239    W    260608008  [flush-8:0]
  239    W    260608040  [flush-8:0]
  239    W    260608056  [flush-8:0]
  239    W    260608072  [flush-8:0]
  239    W    260608088  [flush-8:0]
  239    W    260608152  [flush-8:0]
  239    W    260608200  [flush-8:0]
  239    W    260608224  [flush-8:0]
  239    W    260608240  [flush-8:0]
  239    W    260608272  [flush-8:0]
  239    W    260608312  [flush-8:0]
  239    W    260608352  [flush-8:0]
  239    W    260608400  [flush-8:0]
  239    W    260608424  [flush-8:0]
  239    W    260608440  [flush-8:0]
 1676    R    541955311 [watch-inbox-ope]
 1676    R    541955327 [watch-inbox-ope]
 1676    R    542158511 [watch-inbox-ope]
 1676    R    542158543 [watch-inbox-ope]
 1676    R    542158559 [watch-inbox-ope]
 1676   RM    540456735 [watch-inbox-ope]
 1676    R    542158575 [watch-inbox-ope]
 1676    R    542158591 [watch-inbox-ope]
 1676    R    541955343 [watch-inbox-ope]
 1676    R    541955359 [watch-inbox-ope]
 1676    R    541955375 [watch-inbox-ope]
 1676    R    541955391 [watch-inbox-ope]
 1676    R    541955423 [watch-inbox-ope]
 1676    R    541955439 [watch-inbox-ope]
 1676    R    542187279 [watch-inbox-ope]
  239    W    260608456  [flush-8:0]
  239    W    260608472  [flush-8:0]
  239    W    260608488  [flush-8:0]
  239    W    260608528  [flush-8:0]
  239    W    260608544  [flush-8:0]
  239    W    260608568  [flush-8:0]
  239    W    260608584  [flush-8:0]
  239    W    260608600  [flush-8:0]
  239    W    260608632  [flush-8:0]
  239    W    260608672  [flush-8:0]
 1676    R    542187295 [watch-inbox-ope]
 1676    R    542187311 [watch-inbox-ope]
 1676    R    541955463 [watch-inbox-ope]
 1676    R    541955503 [watch-inbox-ope]
 1676    R    541955487 [watch-inbox-ope]
 1676    R    542187327 [watch-inbox-ope]
 1676    R    541955535 [watch-inbox-ope]
 1676    R    541955551 [watch-inbox-ope]
 1676    R    541955567 [watch-inbox-ope]
 1676    R    541955583 [watch-inbox-ope]
 1676    R    541955615 [watch-inbox-ope]
 1676    R    541955655 [watch-inbox-ope]
 1676   RM    540456743 [watch-inbox-ope]
 1676    R    541955679 [watch-inbox-ope]
 1676    R    541955695 [watch-inbox-ope]
 1676    R    541955711 [watch-inbox-ope]
 1676    R    542187343 [watch-inbox-ope]
 1676    R    542187359 [watch-inbox-ope]
 1676    R    542187375 [watch-inbox-ope]
 1676    R    542187391 [watch-inbox-ope]
 1676    R    542190479 [watch-inbox-ope]
 1676    R    541955727 [watch-inbox-ope]
 1676    R    541955751 [watch-inbox-ope]
 1676    R    541955775 [watch-inbox-ope]
 1676    R    542190495 [watch-inbox-ope]
 1676    R    542190511 [watch-inbox-ope]
 1676    R    542190527 [watch-inbox-ope]
 1676    R    541955791 [watch-inbox-ope]
 1676    R    541955823 [watch-inbox-ope]
 1676    R    541955839 [watch-inbox-ope]
 1676    R    541955855 [watch-inbox-ope]
 1676    R    541955879 [watch-inbox-ope]
 1676    R    541955903 [watch-inbox-ope]
 1676    R    541955919 [watch-inbox-ope]
 1676   RM    540456751 [watch-inbox-ope]
 1676    R    541955943 [watch-inbox-ope]
 1676    R    541955967 [watch-inbox-ope]
 1676    R    542190543 [watch-inbox-ope]
 1676    R    542190559 [watch-inbox-ope]
 1676    R    542190575 [watch-inbox-ope]
 1676    R    542190591 [watch-inbox-ope]
 1676    R    542193807 [watch-inbox-ope]
 1676    R    541955983 [watch-inbox-ope]
 1676    R    541956015 [watch-inbox-ope]
 1676    R    541956031 [watch-inbox-ope]
 1676    R    541956047 [watch-inbox-ope]
 1676    R    541956079 [watch-inbox-ope]
 1676    R    541956095 [watch-inbox-ope]
 1676    R    542193839 [watch-inbox-ope]
 1676    R    542193855 [watch-inbox-ope]
 1676    R    542193871 [watch-inbox-ope]
 1676    R    541956111 [watch-inbox-ope]
 1676    R    541956143 [watch-inbox-ope]
 1676    R    541956207 [watch-inbox-ope]
 1676    R    541956255 [watch-inbox-ope]
 1676    R    542193887 [watch-inbox-ope]
 1676    R    541956271 [watch-inbox-ope]
 1676    R    541956287 [watch-inbox-ope]
 1676    R    541956335 [watch-inbox-ope]
 1676   RM    540456759 [watch-inbox-ope]
 1676    R    542193903 [watch-inbox-ope]
 1676    R    541956319 [watch-inbox-ope]
 1676    R    541956367 [watch-inbox-ope]
 1676    R    541956399 [watch-inbox-ope]
 1676    R    541956415 [watch-inbox-ope]
 1676    R    541956431 [watch-inbox-ope]
 1676    R    541956447 [watch-inbox-ope]
 1676    R    541956479 [watch-inbox-ope]
 1676    R    542197775 [watch-inbox-ope]
 1676    R    542197791 [watch-inbox-ope]
 1676    R    542197807 [watch-inbox-ope]
 1676    R    542197823 [watch-inbox-ope]
 1676    R    542197839 [watch-inbox-ope]

I recognise that the output will have a WTF reaction but the key
observations to me are

a) a single write request from flusher took over a second to complete
b) at the time it was queued, it was mostly other writes that were in
   the queue at the same time
c) The write request and the parallel writes were all asynchronous write
   requests
D) at the time the request completed, there were a LARGE number of
   other requested queued and completed at the same time.

Of the requests queued and completed in the meantime the breakdown was

     22 RM
     31 RA
     82 W
    445 R

If I'm reading this correctly, it is saying that 22 reads were merged (RM),
31 reads were remapped to another device (RA) which is probably reads from
the dm-crypt partition, 82 were writes (W) which is not far off the number
of writes that were in the queue and 445 were other reads. The delay was
dominated by reads that were queued after the write request and completed
before it.

There are lots of other example but here is part of one from much later
that starts with.

Request 27128 took 7.536721619 to complete
  239    W    188973663  [flush-8:0]

That's saying that the 27128th request in the trace took over 7 seconds
to complete and was an asynchronous write from flusher. The contents of
the queue are displayed at that time and the breakdown of requests is

     23 WS
     86 RM
    124 RA
    442 W
   1931 R

7 seconds later when it was completed the breakdown of completed
requests was

     25 WS
    114 RM
    155 RA
    408 W
   2457 R

In combination, that confirms for me that asynchronous writes from flush
are being starved by reads. When a process requires a buffer that is locked
by that asynchronous write from flusher, it stalls.

> The thing is, we do want to make ext4 work well with cfq, and
> prioritizing non-readahead read requests ahead of data writeback does
> make sense.  The issue is with is that metadata writes going through
> the block device could in some cases effectively cause a priority
> inversion when what had previously been an asynchronous writeback
> starts blocking a foreground, user-visible process.
> 
> At least, that's the theory;

I *think* the data more or less confirms the theory but it'd be nice if
someone else double checked in case I'm seeing what I want to see
instead of what is actually there.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
