Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 327C66B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 06:04:21 -0500 (EST)
Message-ID: <1324638242.562.15.camel@rybalov.eng.ttk.net>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
From: nowhere <nowhere@hakkenden.ath.cx>
Date: Fri, 23 Dec 2011 15:04:02 +0400
In-Reply-To: <20111223102027.GB12731@dastard>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	 <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard>
	 <1324630880.562.6.camel@rybalov.eng.ttk.net>
	 <20111223102027.GB12731@dastard>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

=D0=92 =D0=9F=D1=82., 23/12/2011 =D0=B2 21:20 +1100, Dave Chinner =D0=BF=D0=
=B8=D1=88=D0=B5=D1=82:
> On Fri, Dec 23, 2011 at 01:01:20PM +0400, nowhere wrote:
> > =D0=92 =D0=A7=D1=82., 22/12/2011 =D0=B2 09:55 +1100, Dave Chinner =D0=
=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > On Wed, Dec 21, 2011 at 10:52:49AM +0100, Michal Hocko wrote:
> > > > [Let's CC linux-mm]
> > > >=20
> > > > On Wed 21-12-11 07:10:36, Nikolay S. wrote:
> > > > > Hello,
> > > > >=20
> > > > > I'm using 3.2-rc5 on a machine, which atm does almost nothing exc=
ept
> > > > > file system operations and network i/o (i.e. file server). And th=
ere is
> > > > > a problem with kswapd.
> > > >=20
> > > > What kind of filesystem do you use?
> > > >=20
> > > > >=20
> > > > > I'm playing with dd:
> > > > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M
> > > > >=20
> > > > > I.e. I'm filling page cache.
> > > > >=20
> > > > > So when the machine is just rebooted, kswapd during this operatio=
n is
> > > > > almost idle, just 5-8 percent according to top.
> > > > >=20
> > > > > After ~5 days of uptime (5 days,  2:10), the same operation deman=
ds ~70%
> > > > > for kswapd:
> > > > >=20
> > > > >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> > > > >   420 root      R   70  0.0  22:09.60    0 kswapd0
> > > > > 17717 nowhere   D   27  0.2   0:01.81  10m dd
> > > > >=20
> > > > > In fact, kswapd cpu usage on this operation steadily increases ov=
er
> > > > > time.
> > > > >=20
> > > > > Also read performance degrades over time. After reboot:
> > > > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M
> > > > > 1019+1 records in
> > > > > 1019+1 records out
> > > > > 8553494018 bytes (8.6 GB) copied, 16.211 s, 528 MB/s
> > > > >=20
> > > > > After ~5 days uptime:
> > > > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M
> > > > > 1019+1 records in
> > > > > 1019+1 records out
> > > > > 8553494018 bytes (8.6 GB) copied, 29.0507 s, 294 MB/s
> > > > >=20
> > > > > Whereas raw disk sequential read performance stays the same:
> > > > > dd if=3D/some/big/file of=3D/dev/null bs=3D8M iflag=3Ddirect
> > > > > 1019+1 records in
> > > > > 1019+1 records out
> > > > > 8553494018 bytes (8.6 GB) copied, 14.7286 s, 581 MB/s
> > > > >=20
> > > > > Also after dropping caches, situation somehow improves, but not t=
o the
> > > > > state of freshly restarted system:
> > > > >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> > > > >   420 root      S   39  0.0  23:31.17    0 kswapd0
> > > > > 19829 nowhere   D   24  0.2   0:02.72 7764 dd
> > > > >=20
> > > > > perf shows:
> > > > >=20
> > > > >     31.24%  kswapd0  [kernel.kallsyms]  [k] _raw_spin_lock
> > > > >     26.19%  kswapd0  [kernel.kallsyms]  [k] shrink_slab
> > > > >     16.28%  kswapd0  [kernel.kallsyms]  [k] prune_super
> > > > >      6.55%  kswapd0  [kernel.kallsyms]  [k] grab_super_passive
> > > > >      5.35%  kswapd0  [kernel.kallsyms]  [k] down_read_trylock
> > > > >      4.03%  kswapd0  [kernel.kallsyms]  [k] up_read
> > > > >      2.31%  kswapd0  [kernel.kallsyms]  [k] put_super
> > > > >      1.81%  kswapd0  [kernel.kallsyms]  [k] drop_super
> > > > >      0.99%  kswapd0  [kernel.kallsyms]  [k] __put_super
> > > > >      0.25%  kswapd0  [kernel.kallsyms]  [k] __isolate_lru_page
> > > > >      0.23%  kswapd0  [kernel.kallsyms]  [k] free_pcppages_bulk
> > > > >      0.19%  kswapd0  [r8169]            [k] rtl8169_interrupt
> > > > >      0.15%  kswapd0  [kernel.kallsyms]  [k] twa_interrupt
> > > >=20
> > > > Quite a lot of time spent shrinking slab (dcache I guess) and a lot=
 of
> > > > spin lock contention.
> > >=20
> > > That's just scanning superblocks, not apparently doing anything
> > > useful like shrinking dentries or inodes attached to each sb. i.e.
> > > the shrinkers are being called an awful lot and basically have
> > > nothing to do. I'd be suspecting a problem higher up in the stack to
> > > do with how shrink_slab is operating or being called.
> > >=20
> > > I'd suggest gathering event traces for mm_shrink_slab_start/
> > > mm_shrink_slab_end to try to see how the shrinkers are being
> > > driven...
> > >=20
> > > Cheers,
> > >=20
> > > Dave.
> >=20
> > I have recompiled kernel with tracers, and today the problem is visible
> > again. So here is the trace for mm_shrink_slab_start (it is HUGE):
> >=20
> >          kswapd0   421 [000] 103976.627873: mm_shrink_slab_start: prune=
_super+0x0 0xffff88011b00d300: objects to shrink 12 gfp_flags GFP_KERNELGFP=
_NOTRACK pgs_scanned 32 lru_pgs 942483 cache items 1500 delt
> >          kswapd0   421 [000] 103976.627882: mm_shrink_slab_start: prune=
_super+0x0 0xffff88011a20ab00: objects to shrink 267 gfp_flags GFP_KERNELGF=
P_NOTRACK pgs_scanned 32 lru_pgs 942483 cache items 5300 del
>=20
> And possibly useless in this form. I need to see the
> mm_shrink_slab_start/mm_shrink_slab_end events interleaved so I can
> see exactly how much work each shrinker call is doing, and the start
> events are truncated so not all the info I need is present.
>=20
> Perhaps you should install trace-cmd.
>=20
> $ trace-cmd record -e mm_shrink_slab*
> (wait 30s, then ^C)
> $ trace-cmd report > shrink.trace
>=20
> And then compress and attach the trace file or put up on the web
> somewhere for me ot download if it's too large for email...
>=20
> As it is, there's ~940k pages in the LRU, and shrink_slab is being
> called after 32, 95, 8, 8, 32 and 32 pages on the LRU have been
> scanned. That seems like the shrinkers are being called rather too
> often.
>=20
> The end traces indicate the shrinker caches aren't able to free
> anything. So it looks like the vmscan code has got itself in a
> situation where it is not scanning many pages between shrinker
> callouts, and the shrinkers scan but can't make any progress. Looks
> like a vmscan balancing problem right now, not anything to do with
> the shrinker code. A better trace will confirm that.
>=20
> FWIW, if you use trace-cmd, it might be worthwhile collecting all the
> vmscan trace events too, as that might help the VM folk understand
> the problem without needing to ask you for more info.

./trace-cmd record -e vmscan/*

Here is the report of trace-cmd while dd'ing
https://80.237.6.56/report-dd.xz


And one more during normal operation
https://80.237.6.56/report-normal.xz

>=20
> Cheers,
>=20
> Dave.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
