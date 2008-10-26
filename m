Date: Sun, 26 Oct 2008 15:20:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: deadlock with latest xfs
Message-ID: <20081026042026.GM18495@disturbed>
References: <4900412A.2050802@sgi.com> <20081023205727.GA28490@infradead.org> <49013C47.4090601@sgi.com> <20081024052418.GO25906@disturbed> <20081024064804.GQ25906@disturbed> <20081026005351.GK18495@disturbed> <20081026025013.GL18495@disturbed>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081026025013.GL18495@disturbed>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lachlan McIlroy <lachlan@sgi.com>, Christoph Hellwig <hch@infradead.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 26, 2008 at 01:50:13PM +1100, Dave Chinner wrote:
> On Sun, Oct 26, 2008 at 11:53:51AM +1100, Dave Chinner wrote:
> > On Fri, Oct 24, 2008 at 05:48:04PM +1100, Dave Chinner wrote:
> > > OK, I just hung a single-threaded rm -rf after this completed:
> > > 
> > > # fsstress -p 1024 -n 100 -d /mnt/xfs2/fsstress
> > > 
> > > It has hung with this trace:
> > > 
> > > # echo w > /proc/sysrq-trigger
> > ....
> > > [42954211.590000] 794877f8:  [<6002e40a>] update_curr+0x3a/0x50
> > > [42954211.590000] 79487818:  [<60014f0d>] _switch_to+0x6d/0xe0
> > > [42954211.590000] 79487858:  [<60324b21>] schedule+0x171/0x2c0
> > > [42954211.590000] 794878a8:  [<60324e6d>] schedule_timeout+0xad/0xf0
> > > [42954211.590000] 794878c8:  [<60326e98>] _spin_unlock_irqrestore+0x18/0x20
> > > [42954211.590000] 79487908:  [<60195455>] xlog_grant_log_space+0x245/0x470
> > > [42954211.590000] 79487920:  [<60030ba0>] default_wake_function+0x0/0x10
> > > [42954211.590000] 79487978:  [<601957a2>] xfs_log_reserve+0x122/0x140
> > > [42954211.590000] 794879c8:  [<601a36e7>] xfs_trans_reserve+0x147/0x2e0
> > > [42954211.590000] 794879f8:  [<60087374>] kmem_cache_alloc+0x84/0x100
> > > [42954211.590000] 79487a38:  [<601ab01f>] xfs_inactive_symlink_rmt+0x9f/0x450
> > > [42954211.590000] 79487a88:  [<601ada94>] kmem_zone_zalloc+0x34/0x50
> > > [42954211.590000] 79487aa8:  [<601a3a6d>] _xfs_trans_alloc+0x2d/0x70
> > ....
> > 
> > I came back to the system, and found that the hang had gone away - the
> > rm -rf had finished sometime in the ~36 hours between triggering the
> > problem and coming back to look at the corpse....
> > 
> > So nothing to report yet.
> 
> Got it now. I can reproduce this in a couple of minutes now that both
> the test fs and the fs hosting the UML fs images are using lazy-count=1
> (and the frequent 10s long host system freezes have gone away, too).
> 
> Looks like *another* new memory allocation problem [1]:

[snip]

And having fixed that, I'm now seeing the log reservation hang:

[42950307.350000] xfsdatad/0    D 00000000407219f0     0    51      2
[42950307.350000] 7bd1acd8 7bd1a838 60498c40 81074000 81077b40 60014f0d 81044780 81074000
[42950307.350000]        81074000 7e15f808 7bd1a800 81044780 81077b90 60324bc1 81074000 00000250
[42950307.350000]        81074000 81074000 7fffffffffffffff 6646a168 80b6dd28 80b6ddf8 81077bf0 60324f0d <6>Call Trace:
[42950307.350000] 81077b08:  [<60014f0d>] _switch_to+0x6d/0xe0
[42950307.350000] 81077b48:  [<60324bc1>] schedule+0x171/0x2c0
[42950307.350000] 81077b98:  [<60324f0d>] schedule_timeout+0xad/0xf0
[42950307.350000] 81077bb8:  [<60326f38>] _spin_unlock_irqrestore+0x18/0x20
[42950307.350000] 81077bf8:  [<601953e9>] xlog_grant_log_space+0x169/0x470
[42950307.350000] 81077c10:  [<60030ba0>] default_wake_function+0x0/0x10
[42950307.350000] 81077c68:  [<60195812>] xfs_log_reserve+0x122/0x140
[42950307.350000] 81077cb8:  [<601a3757>] xfs_trans_reserve+0x147/0x2e0
[42950307.350000] 81077ce8:  [<601adb14>] kmem_zone_zalloc+0x34/0x50
[42950307.350000] 81077d28:  [<6018f985>] xfs_iomap_write_unwritten+0xa5/0x2d0
[42950307.350000] 81077d38:  [<60326f38>] _spin_unlock_irqrestore+0x18/0x20
[42950307.350000] 81077d48:  [<60085750>] cache_free_debugcheck+0x150/0x2e0
[42950307.350000] 81077d50:  [<60063d12>] mempool_free_slab+0x12/0x20
[42950307.350000] 81077d88:  [<60085e02>] kmem_cache_free+0x72/0xb0
[42950307.350000] 81077dc8:  [<60063dbf>] mempool_free+0x4f/0x90
[42950307.350000] 81077e08:  [<601af66d>] xfs_end_bio_unwritten+0x6d/0xa0
[42950307.350000] 81077e38:  [<60048574>] run_workqueue+0xa4/0x180
[42950307.350000] 81077e50:  [<601af600>] xfs_end_bio_unwritten+0x0/0xa0
[42950307.350000] 81077e58:  [<6004c791>] prepare_to_wait+0x51/0x80
[42950307.350000] 81077e98:  [<600488e0>] worker_thread+0x70/0xd0
[42950307.350000] 81077eb0:  [<6004c5b0>] autoremove_wake_function+0x0/0x40
[42950307.350000] 81077ee8:  [<60048870>] worker_thread+0x0/0xd0
[42950307.350000] 81077f08:  [<6004c204>] kthread+0x64/0xb0
[42950307.350000] 81077f48:  [<60026285>] run_kernel_thread+0x35/0x60
[42950307.350000] 81077f58:  [<6004c1a0>] kthread+0x0/0xb0
[42950307.350000] 81077f98:  [<60026278>] run_kernel_thread+0x28/0x60
[42950307.350000] 81077fc8:  [<60014e71>] new_thread_handler+0x71/0xa0

Basically, the log is too small to fit the number of transaction reservations
that are currently being attempted (roughly 1000 parallel transactions), and so
xlog_grant_log_space() is sleeping.  Because it is sleeping in I/O completion,
the log tail can't move forward because I/O completion is not occurring.

I think that at this point, we need a separate workqueue for unwritten extent
conversion to prevent it from blocking normal data and metadata I/O completion.
that way we can allow it to recurse on allocation and transaction reservation
without introducing I/O completion deadlocks....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
