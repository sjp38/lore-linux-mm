Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 814D86B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:07:07 -0400 (EDT)
Date: Wed, 10 Apr 2013 11:56:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130410105608.GC1910@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130402150651.GB31577@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, Apr 02, 2013 at 11:06:51AM -0400, Theodore Ts'o wrote:
> On Tue, Apr 02, 2013 at 03:27:17PM +0100, Mel Gorman wrote:
> > I'm testing a page-reclaim-related series on my laptop that is partially
> > aimed at fixing long stalls when doing metadata-intensive operations on
> > low memory such as a git checkout. I've been running 3.9-rc2 with the
> > series applied but found that the interactive performance was awful even
> > when there was plenty of free memory.
> 
> Can you try 3.9-rc4 or later and see if the problem still persists?
> There were a number of ext4 issues especially around low memory
> performance which weren't resolved until -rc4.
> 

I experimented with this for a while. -rc6 "feels" much better where
-rc2 felt it would stall for prolonged periods of time but it could be
my imagination too. It does appear that queue depth and await times are
slowly increasing for various reasons.

It's always been the case for me that metadata intensive and write activities
in the background (opening maildir + cache cold git checkout) would stall
the machine for periods of time. This time around, I timed how long it
takes gnome-terminal to open, run find on a directory and exit again while
a cache cold git checkout and a maildir folder were running
	
v3.0.66
  count	time
    471 5
     23 10
     11 15
     14 20
      4 25
      8 30
      3 35

v3.7
    636 5
     20 10
     13 15
     11 20
      7 25
      1 30
      3 35
      1 40
      1 45

v3.8
  count time
    394 5
     10 10
     12 15
      8 20
      9 25
      6 30
      2 35
      3 40

v3.9-rc6
  count time
    481 5
     14 10
      9 15
     12 20
      8 25
      4 30
      2 35
      3 40
      1 45
      1 50
      1 140

This shows that kernel 3.7 was able to open the terminal in 5 seconds or
less 636 times during the test. Very broadly speaking, v3.0.66 is snappier
and generally able to open the terminal and do some work faster. v3.9-rc6 is
sometimes much slower such as when it took 140 seconds to open the terminal
but not consistently slow enough to allow it to be reliably bisected.

Further, whatever my perceptions are telling me, the fact is that git
checkouts are not obviously worse. However, queue depth and IO wait
times are higher but it's gradual and would not obviously make a very bad
impression. See here;

 v3.0.66  checkout:278 depth:387.36 await: 878.97 launch:29.39 max_launch:34.20
 v3.7     checkout:268 depth:439.96 await: 971.39 launch:29.46 max_launch:40.42
 v3.8     checkout:275 depth:598.12 await:1280.62 launch:31.95 max_launch:38.50
 v3.9-rc6 checkout:266 depth:540.74 await:1182.10 launch:45.39 max_launch:138.14

Cache cold git checkout times are roughly comparable but average queue depth
has been increasing and average wait times in v3.8 and v3.9-rc6 are higher
in comparison to v3.0.66. The average time it takes to launch a terminal
and do something with it is also increasing. Unfortunately, these results
are not always perfectly reproducible and it cannot be reliably bisected.

That said, the worst IO wait times (in milliseconds) are getting higher
       
               await      r_await      w_await
 v3.0.66     5811.24        39.19     28309.72 
    v3.7     7508.79        46.36     36318.96 
    v3.8     7083.35        47.55     35305.46 
v3.9-rc2     9211.14        35.25     34560.08 
v3.9-rc6     7499.53        95.21    122780.43 

Worst-case small read times have almost doubled. A worst case write
delay was 122 seconds in v3.9-rc6!

The average wait times are also not painting a pretty picture

               await      r_await      w_await
 v3.0.66      878.97         7.79      6975.51 
    v3.7      971.39         7.84      7745.57 
    v3.8     1280.63         7.75     10306.62 
v3.9-rc2     1280.37         7.55      7687.20 
v3.9-rc6     1182.11         8.11     13869.67 

That is indicating that average wait times have almost doubled since
v3.7. Even though -rc2 felt bad, it's not obviously reflected in the await
figures which is partially what makes bisecting this difficult. At least
you can get an impression of the wait times from this smoothened graph
showing await times from iostat

http://www.csn.ul.ie/~mel/postings/interactivity-20130410/await-times-smooth.png

Again, while one can see the wait times are worse, it's not generally
worse enough to pinpoint it to a single change.

Other observations

On my laptop, pm-utils was setting dirty_background_ratio to 5% and
dirty_ratio to 10% away from the expected defaults of 10% and 20%. Any
of the changes related to dirty balancing could have affected how often
processes get dirty rate-limited.

During major activity there is likely to be "good" behaviour
with stalls roughly every 30 seconds roughly corresponding to
dirty_expire_centiseconds. As you'd expect, the flusher thread is stuck
when this happens.

  237 ?        00:00:00 flush-8:0
[<ffffffff811a35b9>] sleep_on_buffer+0x9/0x10
[<ffffffff811a35ee>] __lock_buffer+0x2e/0x30
[<ffffffff8123a21f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a3db>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220b89>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812278a4>] ext4_mb_mark_diskspace_used+0x74/0x4d0
[<ffffffff81228fbf>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f7c1>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811f0065>] ext4_map_blocks+0x2d5/0x470
[<ffffffff811f412a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4c30>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac3b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff8106901b>] kthread+0xbb/0xc0
[<ffffffff8159d47c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

For other stalls it looks like journal collisions like this;

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
mel       9593  4.9  0.2 583212 20576 pts/2    Dl+  11:49   0:00 gnome-terminal --disable-
[<ffffffff81238693>] start_this_handle+0x2c3/0x3e0
[<ffffffff81238970>] jbd2__journal_start.part.8+0x90/0x190
[<ffffffff81238ab5>] jbd2__journal_start+0x45/0x50
[<ffffffff81220921>] __ext4_journal_start_sb+0x81/0x170
[<ffffffff811f53cb>] ext4_dirty_inode+0x2b/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff811f335c>] ext4_setattr+0x36c/0x640
[<ffffffff8118cf72>] notify_change+0x1f2/0x3c0
[<ffffffff81170f7d>] chown_common+0xbd/0xd0
[<ffffffff811720d7>] sys_fchown+0xb7/0xd0
[<ffffffff8159d52d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root       758  0.0  0.0      0     0 ?        D    11:16   0:00
[jbd2/sda6-8]
[<ffffffff8123b28a>] jbd2_journal_commit_transaction+0x1ea/0x13c0
[<ffffffff81240943>] kjournald2+0xb3/0x240
[<ffffffff8106901b>] kthread+0xbb/0xc0
[<ffffffff8159d47c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

So for myself I can increase the dirty limits, the writeback expire times
and maybe up the journal commit interval from the default of 5 seconds and
see what that "feels" like over the next few days but it still leaves the
fact that worst-case IO wait times in default configurations appear to be
getting worse over time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
