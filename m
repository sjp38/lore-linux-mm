Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id DE8946B0036
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 03:50:11 -0400 (EDT)
Date: Mon, 1 Jul 2013 09:50:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130701075005.GA28765@dhcp22.suse.cz>
References: <20130618082414.GC13677@dhcp22.suse.cz>
 <20130618104443.GH13677@dhcp22.suse.cz>
 <20130618135025.GK13677@dhcp22.suse.cz>
 <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
 <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130701012558.GB27780@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 01-07-13 11:25:58, Dave Chinner wrote:
> On Sun, Jun 30, 2013 at 08:33:49PM +0200, Michal Hocko wrote:
> > On Sat 29-06-13 12:55:09, Dave Chinner wrote:
> > > On Thu, Jun 27, 2013 at 04:54:11PM +0200, Michal Hocko wrote:
> > > > On Thu 27-06-13 09:24:26, Dave Chinner wrote:
> > > > > On Wed, Jun 26, 2013 at 10:15:09AM +0200, Michal Hocko wrote:
> > > > > > On Tue 25-06-13 12:27:54, Dave Chinner wrote:
> > > > > > > On Tue, Jun 18, 2013 at 03:50:25PM +0200, Michal Hocko wrote:
> > > > > > > > And again, another hang. It looks like the inode deletion never
> > > > > > > > finishes. The good thing is that I do not see any LRU related BUG_ONs
> > > > > > > > anymore. I am going to test with the other patch in the thread.
> > > > > > > > 
> > > > > > > > 2476 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0	<<< waiting for an inode to go away
> > > > > > > > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > > > > > > > [<ffffffff8118525f>] iget_locked+0x4f/0x180
> > > > > > > > [<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
> > > > > > > > [<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
> > > > > > > > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > > > > > > > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > > > > > > > [<ffffffff8117815e>] do_last+0x2de/0x780			<<< holds i_mutex
> > > > > > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > > > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > > > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > > > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > > > > > [<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
> > > > > > > > [<ffffffffffffffff>] 0xffffffffffffffff
> 
> .....
> > Do you mean sysrq+t? It is attached. 
> > 
> > Btw. I was able to reproduce this again. The stuck processes were
> > sitting in the same traces for more than 28 hours without any change so
> > I do not think this is a temporal condition.
> > 
> > Traces of all processes in the D state:
> > 7561 [<ffffffffa029c03e>] xfs_iget+0xbe/0x190 [xfs]
> > [<ffffffffa02a8e98>] xfs_lookup+0xe8/0x110 [xfs]
> > [<ffffffffa029fad9>] xfs_vn_lookup+0x49/0x90 [xfs]
> > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > [<ffffffff8117815e>] do_last+0x2de/0x780
> > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> 
> This looks like it may be equivalent to the ext4 trace above, though
> I'm not totally sure on that yet. Can you get me the line of code
> where the above code is sleeping - 'gdb> l *(xfs_iget+0xbe)' output
> is sufficient.

OK, this is a bit tricky because I have xfs built as a module so objdump
on xfs.ko shows nonsense
   19039:       e8 00 00 00 00          callq  1903e <xfs_iget+0xbe>
   1903e:       48 8b 75 c0             mov    -0x40(%rbp),%rsi

crash was more clever though and it says:
0xffffffffa029c034 <xfs_iget+180>:      mov    $0x1,%edi
0xffffffffa029c039 <xfs_iget+185>:      callq  0xffffffff815776d0
<schedule_timeout_uninterruptible>
/dev/shm/mhocko-build/BUILD/kernel-3.9.0mmotm+/fs/xfs/xfs_icache.c: 423
0xffffffffa029c03e <xfs_iget+190>:      mov    -0x40(%rbp),%rsi

which maps to:
out_error_or_again:
        if (error == EAGAIN) {
                delay(1);
                goto again;
        }

So this looks like this path loops in goto again and out_error_or_again.

> If it's where I suspect it is, we are hitting a VFS inode that
> igrab() is failing on because I_FREEING is set and that is returning
> EAGAIN. Hence xfs_iget() sleeps for a short period and retries the
> lookup. If you've still got a system in this state, can you dump the
> xfs stats a few times about 5s apart i.e.
> 
> $ for i in `seq 0 1 5`; do echo ; date; cat /proc/fs/xfs/stat ; sleep 5 ; done
> 
> Depending on what stat is changing (i'm looking for skip vs recycle
> in the inode cache stats), that will tell us why the lookup is
> failing...

$ for i in `seq 0 1 5`; do echo ; date; cat /proc/fs/xfs/stat ; sleep 5 ; done

Mon Jul  1 09:29:57 CEST 2013
extent_alloc 1484333 2038118 1678 13182
abt 0 0 0 0
blk_map 21004635 3433178 1450438 1461372 1450017 25888309 0
bmbt 0 0 0 0
dir 1482235 1466711 7281 2529
trans 7676 6231535 1444850
ig 0 8534 299 1463749 0 1256778 262381
log 37039 2082072 414 8808 16395
push_ail 7684106 0 519016 449446 0 12401 64613 2970751 0 1036
xstrat 1441551 0
rw 1744884 1351499
attr 84933 0 0 0
icluster 130532 102985 2389817
vnodes 4293706604 0 0 0 1260692 1260692 1260692 0
buf 24539551 79603 24464366 2126 8792 75185 0 129859 9654
abtb2 1520647 1551239 12314 12331 0 0 0 0 0 0 0 0 0 0 15613
abtc2 2972473 1641548 1486215 1486232 0 0 0 0 0 0 0 0 0 0 258694
bmbt2 16968 199868 14855 0 3 0 89 0 6414 89 58 0 61 0 1800151
ibt2 4289847 39122572 22887 1 4 0 644 59 10700 0 88 0 92 0 2732985
qm 0 0 0 0 0 0 0 0
xpc 7892422656 3364392442 7942370166
debug 0

Mon Jul  1 09:30:02 CEST 2013
extent_alloc 1484362 2038147 1678 13182
abt 0 0 0 0
blk_map 21005075 3433237 1450468 1461401 1450047 25888838 0
bmbt 0 0 0 0
dir 1482265 1466741 7281 2529
trans 7676 6231652 1444880
ig 0 8534 299 1463779 0 1256778 262381
log 37039 2082072 414 8808 16395
push_ail 7684253 0 519016 449446 0 12401 64613 2970751 0 1036
xstrat 1441579 0
rw 1744914 1351499
attr 84933 0 0 0
icluster 130532 102985 2389817
vnodes 4293706604 0 0 0 1260692 1260692 1260692 0
buf 24540112 79607 24464923 2126 8792 75189 0 129863 9657
abtb2 1520676 1551268 12314 12331 0 0 0 0 0 0 0 0 0 0 15613
abtc2 2972531 1641578 1486244 1486261 0 0 0 0 0 0 0 0 0 0 258696
bmbt2 16969 199882 14856 0 3 0 89 0 6415 89 58 0 61 0 1800406
ibt2 4289937 39123472 22887 1 4 0 644 59 10700 0 88 0 92 0 2732985
qm 0 0 0 0 0 0 0 0
xpc 7892537344 3364415667 7942370166
debug 0

Mon Jul  1 09:30:07 CEST 2013
extent_alloc 1484393 2038181 1678 13182
abt 0 0 0 0
blk_map 21005515 3433297 1450498 1461431 1450077 25889368 0
bmbt 0 0 0 0
dir 1482295 1466771 7281 2529
trans 7676 6231774 1444910
ig 0 8534 299 1463809 0 1256778 262381
log 37039 2082072 414 8808 16395
push_ail 7684405 0 519016 449446 0 12401 64613 2970751 0 1036
xstrat 1441609 0
rw 1744944 1351499
attr 84933 0 0 0
icluster 130532 102985 2389817
vnodes 4293706604 0 0 0 1260692 1260692 1260692 0
buf 24540682 79609 24465491 2126 8792 75191 0 129867 9657
abtb2 1520708 1551300 12314 12331 0 0 0 0 0 0 0 0 0 0 15613
abtc2 2972593 1641609 1486275 1486292 0 0 0 0 0 0 0 0 0 0 258696
bmbt2 16969 199882 14856 0 3 0 89 0 6415 89 58 0 61 0 1800406
ibt2 4290028 39124384 22888 1 4 0 644 59 10700 0 88 0 92 0 2732985
qm 0 0 0 0 0 0 0 0
xpc 7892660224 3364438892 7942370166
debug 0

Mon Jul  1 09:30:12 CEST 2013
extent_alloc 1484424 2038215 1678 13182
abt 0 0 0 0
blk_map 21005901 3433353 1450524 1461461 1450103 25889836 0
bmbt 0 0 0 0
dir 1482321 1466797 7281 2529
trans 7677 6231889 1444936
ig 0 8534 299 1463835 0 1256778 262381
log 37045 2082361 414 8810 16398
push_ail 7684547 0 519079 449508 0 12408 64613 2971092 0 1037
xstrat 1441639 0
rw 1744970 1351499
attr 84933 0 0 0
icluster 130548 102999 2390155
vnodes 4293706604 0 0 0 1260692 1260692 1260692 0
buf 24541210 79611 24466017 2126 8792 75193 0 129871 9657
abtb2 1520740 1551332 12314 12331 0 0 0 0 0 0 0 0 0 0 15613
abtc2 2972655 1641640 1486306 1486323 0 0 0 0 0 0 0 0 0 0 258696
bmbt2 16969 199882 14856 0 3 0 89 0 6415 89 58 0 61 0 1800406
ibt2 4290107 39125176 22889 1 4 0 644 59 10700 0 88 0 92 0 2732985
qm 0 0 0 0 0 0 0 0
xpc 7892783104 3364458016 7942370166
debug 0

Mon Jul  1 09:30:17 CEST 2013
extent_alloc 1484454 2038245 1678 13182
abt 0 0 0 0
blk_map 21006341 3433413 1450554 1461491 1450133 25890366 0
bmbt 0 0 0 0
dir 1482351 1466827 7281 2529
trans 7677 6232011 1444966
ig 0 8534 299 1463865 0 1256778 262381
log 37045 2082361 414 8810 16398
push_ail 7684699 0 519175 449508 0 12408 64613 2971092 0 1037
xstrat 1441669 0
rw 1745000 1351499
attr 84933 0 0 0
icluster 130548 102999 2390155
vnodes 4293706604 0 0 0 1260692 1260692 1260692 0
buf 24541770 79611 24466577 2126 8792 75193 0 129871 9657
abtb2 1520770 1551362 12314 12331 0 0 0 0 0 0 0 0 0 0 15613
abtc2 2972715 1641670 1486336 1486353 0 0 0 0 0 0 0 0 0 0 258696
bmbt2 16969 199882 14856 0 3 0 89 0 6415 89 58 0 61 0 1800406
ibt2 4290197 39126076 22889 1 4 0 644 59 10700 0 88 0 92 0 2732985
qm 0 0 0 0 0 0 0 0
xpc 7892905984 3364481241 7942370166
debug 0

Mon Jul  1 09:30:22 CEST 2013
extent_alloc 1484486 2038280 1678 13182
abt 0 0 0 0
blk_map 21006782 3433474 1450584 1461522 1450163 25890898 0
bmbt 0 0 0 0
dir 1482381 1466857 7281 2529
trans 7677 6232134 1444996
ig 0 8534 299 1463895 0 1256778 262381
log 37045 2082361 414 8810 16398
push_ail 7684852 0 519272 449508 0 12408 64613 2971092 0 1037
xstrat 1441699 0
rw 1745030 1351499
attr 84933 0 0 0
icluster 130548 102999 2390155
vnodes 4293706604 0 0 0 1260692 1260692 1260692 0
buf 24542347 79614 24467151 2126 8792 75196 0 129876 9657
abtb2 1520803 1551395 12314 12331 0 0 0 0 0 0 0 0 0 0 15613
abtc2 2972779 1641702 1486368 1486385 0 0 0 0 0 0 0 0 0 0 258696
bmbt2 16970 199896 14857 0 3 0 89 0 6415 89 58 0 61 0 1800407
ibt2 4290288 39126988 22890 1 4 0 644 59 10700 0 88 0 92 0 2732985
qm 0 0 0 0 0 0 0 0
xpc 7893028864 3364504466 7942370166
debug 0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
