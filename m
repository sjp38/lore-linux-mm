Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E94486B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 04:01:42 -0500 (EST)
Message-ID: <1324630880.562.6.camel@rybalov.eng.ttk.net>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
From: nowhere <nowhere@hakkenden.ath.cx>
Date: Fri, 23 Dec 2011 13:01:20 +0400
In-Reply-To: <20111221225512.GG23662@dastard>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	 <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

=D0=92 =D0=A7=D1=82., 22/12/2011 =D0=B2 09:55 +1100, Dave Chinner =D0=BF=D0=
=B8=D1=88=D0=B5=D1=82:
> On Wed, Dec 21, 2011 at 10:52:49AM +0100, Michal Hocko wrote:
> > [Let's CC linux-mm]
> >=20
> > On Wed 21-12-11 07:10:36, Nikolay S. wrote:
> > > Hello,
> > >=20
> > > I'm using 3.2-rc5 on a machine, which atm does almost nothing except
> > > file system operations and network i/o (i.e. file server). And there =
is
> > > a problem with kswapd.
> >=20
> > What kind of filesystem do you use?
> >=20
> > >=20
> > > I'm playing with dd:
> > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M
> > >=20
> > > I.e. I'm filling page cache.
> > >=20
> > > So when the machine is just rebooted, kswapd during this operation is
> > > almost idle, just 5-8 percent according to top.
> > >=20
> > > After ~5 days of uptime (5 days,  2:10), the same operation demands ~=
70%
> > > for kswapd:
> > >=20
> > >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> > >   420 root      R   70  0.0  22:09.60    0 kswapd0
> > > 17717 nowhere   D   27  0.2   0:01.81  10m dd
> > >=20
> > > In fact, kswapd cpu usage on this operation steadily increases over
> > > time.
> > >=20
> > > Also read performance degrades over time. After reboot:
> > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M
> > > 1019+1 records in
> > > 1019+1 records out
> > > 8553494018 bytes (8.6 GB) copied, 16.211 s, 528 MB/s
> > >=20
> > > After ~5 days uptime:
> > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M
> > > 1019+1 records in
> > > 1019+1 records out
> > > 8553494018 bytes (8.6 GB) copied, 29.0507 s, 294 MB/s
> > >=20
> > > Whereas raw disk sequential read performance stays the same:
> > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M iflag=3Ddirect
> > > 1019+1 records in
> > > 1019+1 records out
> > > 8553494018 bytes (8.6 GB) copied, 14.7286 s, 581 MB/s
> > >=20
> > > Also after dropping caches, situation somehow improves, but not to th=
e
> > > state of freshly restarted system:
> > >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> > >   420 root      S   39  0.0  23:31.17    0 kswapd0
> > > 19829 nowhere   D   24  0.2   0:02.72 7764 dd
> > >=20
> > > perf shows:
> > >=20
> > >     31.24%  kswapd0  [kernel.kallsyms]  [k] _raw_spin_lock
> > >     26.19%  kswapd0  [kernel.kallsyms]  [k] shrink_slab
> > >     16.28%  kswapd0  [kernel.kallsyms]  [k] prune_super
> > >      6.55%  kswapd0  [kernel.kallsyms]  [k] grab_super_passive
> > >      5.35%  kswapd0  [kernel.kallsyms]  [k] down_read_trylock
> > >      4.03%  kswapd0  [kernel.kallsyms]  [k] up_read
> > >      2.31%  kswapd0  [kernel.kallsyms]  [k] put_super
> > >      1.81%  kswapd0  [kernel.kallsyms]  [k] drop_super
> > >      0.99%  kswapd0  [kernel.kallsyms]  [k] __put_super
> > >      0.25%  kswapd0  [kernel.kallsyms]  [k] __isolate_lru_page
> > >      0.23%  kswapd0  [kernel.kallsyms]  [k] free_pcppages_bulk
> > >      0.19%  kswapd0  [r8169]            [k] rtl8169_interrupt
> > >      0.15%  kswapd0  [kernel.kallsyms]  [k] twa_interrupt
> >=20
> > Quite a lot of time spent shrinking slab (dcache I guess) and a lot of
> > spin lock contention.
>=20
> That's just scanning superblocks, not apparently doing anything
> useful like shrinking dentries or inodes attached to each sb. i.e.
> the shrinkers are being called an awful lot and basically have
> nothing to do. I'd be suspecting a problem higher up in the stack to
> do with how shrink_slab is operating or being called.
>=20
> I'd suggest gathering event traces for mm_shrink_slab_start/
> mm_shrink_slab_end to try to see how the shrinkers are being
> driven...
>=20
> Cheers,
>=20
> Dave.

I have recompiled kernel with tracers, and today the problem is visible
again. So here is the trace for mm_shrink_slab_start (it is HUGE):

         kswapd0   421 [000] 103976.627873: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011b00d300: objects to shrink 12 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 32 lru_pgs 942483 cache items 1500 delt
         kswapd0   421 [000] 103976.627882: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a20ab00: objects to shrink 267 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 32 lru_pgs 942483 cache items 5300 del
         kswapd0   421 [000] 103976.627884: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a892300: objects to shrink 110 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 32 lru_pgs 942483 cache items 2000 del
         kswapd0   421 [000] 103976.627887: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a893700: objects to shrink 31 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 32 lru_pgs 942483 cache items 4900 delt
         kswapd0   421 [000] 103976.627888: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a386700: objects to shrink 0 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 32 lru_pgs 942483 cache items 300 delta=20
         kswapd0   421 [000] 103976.627889: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381700: objects to shrink 6 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 32 lru_pgs 942483 cache items 4700 delta
         kswapd0   421 [000] 103976.627890: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381300: objects to shrink 3 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 32 lru_pgs 942483 cache items 600 delta=20
         kswapd0   421 [000] 103976.627893: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a171058: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 32 lru_pgs 942483 cache items 1 d
         kswapd0   421 [000] 103976.627895: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a29e658: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 32 lru_pgs 942483 cache items 1 d
         kswapd0   421 [000] 103976.627897: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011ab17300: objects to shrink 311 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 32 lru_pgs 942483 cache items 4900 del
         kswapd0   421 [000] 103976.627897: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011b3c4d18: objects to shrink 27 gfp_flags GFP_KERNEL=
GFP_NOTRACK pgs_scanned 32 lru_pgs 942483 cache items 49
         kswapd0   421 [000] 103976.628108: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011b00d300: objects to shrink 12 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 95 lru_pgs 942483 cache items 1500 delt
         kswapd0   421 [000] 103976.628110: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a20ab00: objects to shrink 267 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 95 lru_pgs 942483 cache items 5300 del
         kswapd0   421 [000] 103976.628111: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a892300: objects to shrink 110 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 95 lru_pgs 942483 cache items 2000 del
         kswapd0   421 [000] 103976.628112: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a893700: objects to shrink 31 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 95 lru_pgs 942483 cache items 4900 delt
         kswapd0   421 [000] 103976.628113: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a386700: objects to shrink 0 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 95 lru_pgs 942483 cache items 300 delta=20
         kswapd0   421 [000] 103976.628113: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381700: objects to shrink 6 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 95 lru_pgs 942483 cache items 4700 delta
         kswapd0   421 [000] 103976.628114: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381300: objects to shrink 3 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 95 lru_pgs 942483 cache items 600 delta=20
         kswapd0   421 [000] 103976.628115: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a171058: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 95 lru_pgs 942483 cache items 1 d
         kswapd0   421 [000] 103976.628116: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a29e658: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 95 lru_pgs 942483 cache items 1 d
         kswapd0   421 [000] 103976.628116: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011ab17300: objects to shrink 311 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 95 lru_pgs 942483 cache items 4900 del
         kswapd0   421 [000] 103976.628117: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011b3c4d18: objects to shrink 27 gfp_flags GFP_KERNEL=
GFP_NOTRACK pgs_scanned 95 lru_pgs 942483 cache items 49
         kswapd0   421 [000] 103976.628161: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011b00d300: objects to shrink 12 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 8 lru_pgs 942483 cache items 1500 delta
         kswapd0   421 [000] 103976.628163: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a20ab00: objects to shrink 268 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 8 lru_pgs 942483 cache items 5300 delt
         kswapd0   421 [000] 103976.628163: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a892300: objects to shrink 110 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 8 lru_pgs 942483 cache items 2000 delt
         kswapd0   421 [000] 103976.628165: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a893700: objects to shrink 31 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 8 lru_pgs 942483 cache items 4900 delta
         kswapd0   421 [000] 103976.628165: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a386700: objects to shrink 0 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 8 lru_pgs 942483 cache items 300 delta 0
         kswapd0   421 [000] 103976.628166: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381700: objects to shrink 6 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 8 lru_pgs 942483 cache items 4700 delta=20
         kswapd0   421 [000] 103976.628167: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381300: objects to shrink 3 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 8 lru_pgs 942483 cache items 600 delta 0
         kswapd0   421 [000] 103976.628167: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a171058: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 8 lru_pgs 942483 cache items 1 de
         kswapd0   421 [000] 103976.628168: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a29e658: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 8 lru_pgs 942483 cache items 1 de
         kswapd0   421 [000] 103976.628169: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011ab17300: objects to shrink 311 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 8 lru_pgs 942483 cache items 4900 delt
         kswapd0   421 [000] 103976.628169: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011b3c4d18: objects to shrink 27 gfp_flags GFP_KERNEL=
GFP_NOTRACK pgs_scanned 8 lru_pgs 942483 cache items 493
         kswapd0   421 [000] 103976.628208: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011b00d300: objects to shrink 12 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 32 lru_pgs 942462 cache items 1500 delt
         kswapd0   421 [000] 103976.628210: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a20ab00: objects to shrink 268 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 32 lru_pgs 942462 cache items 5300 del
         kswapd0   421 [000] 103976.628210: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a892300: objects to shrink 110 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 32 lru_pgs 942462 cache items 2000 del
         kswapd0   421 [000] 103976.628212: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a893700: objects to shrink 31 gfp_flags GFP_KERNELGFP_NOT=
RACK pgs_scanned 32 lru_pgs 942462 cache items 4900 delt
         kswapd0   421 [000] 103976.628212: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a386700: objects to shrink 0 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 32 lru_pgs 942462 cache items 300 delta=20
         kswapd0   421 [000] 103976.628213: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381700: objects to shrink 6 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 32 lru_pgs 942462 cache items 4700 delta
         kswapd0   421 [000] 103976.628214: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011a381300: objects to shrink 3 gfp_flags GFP_KERNELGFP_NOTR=
ACK pgs_scanned 32 lru_pgs 942462 cache items 600 delta=20
         kswapd0   421 [000] 103976.628214: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a171058: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 32 lru_pgs 942462 cache items 1 d
         kswapd0   421 [000] 103976.628215: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011a29e658: objects to shrink 0 gfp_flags GFP_KERNELG=
FP_NOTRACK pgs_scanned 32 lru_pgs 942462 cache items 1 d
         kswapd0   421 [000] 103976.628216: mm_shrink_slab_start: prune_sup=
er+0x0 0xffff88011ab17300: objects to shrink 311 gfp_flags GFP_KERNELGFP_NO=
TRACK pgs_scanned 32 lru_pgs 942462 cache items 4900 del
         kswapd0   421 [000] 103976.628216: mm_shrink_slab_start: xfs_bufta=
rg_shrink+0x0 0xffff88011b3c4d18: objects to shrink 27 gfp_flags GFP_KERNEL=
GFP_NOTRACK pgs_scanned 32 lru_pgs 942462 cache items 49

And mm_shrink_slab_end:

         kswapd0   421 [000] 104433.026125: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011b00d300: unused scan count 85 new scan count 85 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026133: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a20ab00: unused scan count 265 new scan count 265 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026134: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a892300: unused scan count 217 new scan count 217 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026137: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a893700: unused scan count 421 new scan count 421 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026138: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a386700: unused scan count 0 new scan count 0 total_scan 0 =
last shrinker return val 0
         kswapd0   421 [000] 104433.026139: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381700: unused scan count 361 new scan count 361 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026140: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381300: unused scan count 20 new scan count 20 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026143: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a171058: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026144: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a29e658: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026146: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011ab17300: unused scan count 711 new scan count 725 total_sca=
n 14 last shrinker return val 0
         kswapd0   421 [000] 104433.026146: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011b3c4d18: unused scan count 50 new scan count 51 tota=
l_scan 1 last shrinker return val 0
         kswapd0   421 [000] 104433.026280: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011b00d300: unused scan count 85 new scan count 85 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026282: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a20ab00: unused scan count 265 new scan count 265 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026282: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a892300: unused scan count 217 new scan count 217 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026284: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a893700: unused scan count 421 new scan count 421 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026285: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a386700: unused scan count 0 new scan count 0 total_scan 0 =
last shrinker return val 0
         kswapd0   421 [000] 104433.026285: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381700: unused scan count 361 new scan count 361 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026286: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381300: unused scan count 20 new scan count 20 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026287: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a171058: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026287: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a29e658: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026288: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011ab17300: unused scan count 725 new scan count 759 total_sca=
n 34 last shrinker return val 0
         kswapd0   421 [000] 104433.026289: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011b3c4d18: unused scan count 51 new scan count 54 tota=
l_scan 3 last shrinker return val 0
         kswapd0   421 [000] 104433.026329: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011b00d300: unused scan count 85 new scan count 85 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026331: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a20ab00: unused scan count 265 new scan count 265 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026331: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a892300: unused scan count 217 new scan count 217 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026333: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a893700: unused scan count 421 new scan count 421 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026333: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a386700: unused scan count 0 new scan count 0 total_scan 0 =
last shrinker return val 0
         kswapd0   421 [000] 104433.026334: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381700: unused scan count 361 new scan count 361 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026335: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381300: unused scan count 20 new scan count 20 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026335: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a171058: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026336: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a29e658: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026337: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011ab17300: unused scan count 759 new scan count 760 total_sca=
n 1 last shrinker return val 0
         kswapd0   421 [000] 104433.026337: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011b3c4d18: unused scan count 54 new scan count 54 tota=
l_scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026376: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011b00d300: unused scan count 85 new scan count 85 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026378: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a20ab00: unused scan count 265 new scan count 265 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026378: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a892300: unused scan count 217 new scan count 217 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026380: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a893700: unused scan count 421 new scan count 421 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026380: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a386700: unused scan count 0 new scan count 0 total_scan 0 =
last shrinker return val 0
         kswapd0   421 [000] 104433.026381: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381700: unused scan count 361 new scan count 361 total_sca=
n 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026382: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011a381300: unused scan count 20 new scan count 20 total_scan =
0 last shrinker return val 0
         kswapd0   421 [000] 104433.026382: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a171058: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026383: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011a29e658: unused scan count 0 new scan count 0 total_=
scan 0 last shrinker return val 0
         kswapd0   421 [000] 104433.026384: mm_shrink_slab_end: prune_super=
+0x0 0xffff88011ab17300: unused scan count 760 new scan count 774 total_sca=
n 14 last shrinker return val 0
         kswapd0   421 [000] 104433.026384: mm_shrink_slab_end: xfs_buftarg=
_shrink+0x0 0xffff88011b3c4d18: unused scan count 54 new scan count 55 tota=
l_scan 1 last shrinker return val 0

  PID USER      S %CPU %MEM    TIME+  COMMAND
 4438 nowhere   D   27  0.2   0:02.54 dd
  421 root      S   17  0.0   1:45.79 kswapd0

Uptime is 1 day,  5:02

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
