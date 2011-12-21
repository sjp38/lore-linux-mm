Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 841F26B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 17:55:15 -0500 (EST)
Date: Thu, 22 Dec 2011 09:55:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-ID: <20111221225512.GG23662@dastard>
References: <1324437036.4677.5.camel@hakkenden.homenet>
 <20111221095249.GA28474@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111221095249.GA28474@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Nikolay S." <nowhere@hakkenden.ath.cx>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 21, 2011 at 10:52:49AM +0100, Michal Hocko wrote:
> [Let's CC linux-mm]
> 
> On Wed 21-12-11 07:10:36, Nikolay S. wrote:
> > Hello,
> > 
> > I'm using 3.2-rc5 on a machine, which atm does almost nothing except
> > file system operations and network i/o (i.e. file server). And there is
> > a problem with kswapd.
> 
> What kind of filesystem do you use?
> 
> > 
> > I'm playing with dd:
> > dd if=/some/big/file of=/dev/null bs=8M
> > 
> > I.e. I'm filling page cache.
> > 
> > So when the machine is just rebooted, kswapd during this operation is
> > almost idle, just 5-8 percent according to top.
> > 
> > After ~5 days of uptime (5 days,  2:10), the same operation demands ~70%
> > for kswapd:
> > 
> >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> >   420 root      R   70  0.0  22:09.60    0 kswapd0
> > 17717 nowhere   D   27  0.2   0:01.81  10m dd
> > 
> > In fact, kswapd cpu usage on this operation steadily increases over
> > time.
> > 
> > Also read performance degrades over time. After reboot:
> > dd if=/some/big/file of=/dev/null bs=8M
> > 1019+1 records in
> > 1019+1 records out
> > 8553494018 bytes (8.6 GB) copied, 16.211 s, 528 MB/s
> > 
> > After ~5 days uptime:
> > dd if=/some/big/file of=/dev/null bs=8M
> > 1019+1 records in
> > 1019+1 records out
> > 8553494018 bytes (8.6 GB) copied, 29.0507 s, 294 MB/s
> > 
> > Whereas raw disk sequential read performance stays the same:
> > dd if=/some/big/file of=/dev/null bs=8M iflag=direct
> > 1019+1 records in
> > 1019+1 records out
> > 8553494018 bytes (8.6 GB) copied, 14.7286 s, 581 MB/s
> > 
> > Also after dropping caches, situation somehow improves, but not to the
> > state of freshly restarted system:
> >   PID USER      S %CPU %MEM    TIME+  SWAP COMMAND
> >   420 root      S   39  0.0  23:31.17    0 kswapd0
> > 19829 nowhere   D   24  0.2   0:02.72 7764 dd
> > 
> > perf shows:
> > 
> >     31.24%  kswapd0  [kernel.kallsyms]  [k] _raw_spin_lock
> >     26.19%  kswapd0  [kernel.kallsyms]  [k] shrink_slab
> >     16.28%  kswapd0  [kernel.kallsyms]  [k] prune_super
> >      6.55%  kswapd0  [kernel.kallsyms]  [k] grab_super_passive
> >      5.35%  kswapd0  [kernel.kallsyms]  [k] down_read_trylock
> >      4.03%  kswapd0  [kernel.kallsyms]  [k] up_read
> >      2.31%  kswapd0  [kernel.kallsyms]  [k] put_super
> >      1.81%  kswapd0  [kernel.kallsyms]  [k] drop_super
> >      0.99%  kswapd0  [kernel.kallsyms]  [k] __put_super
> >      0.25%  kswapd0  [kernel.kallsyms]  [k] __isolate_lru_page
> >      0.23%  kswapd0  [kernel.kallsyms]  [k] free_pcppages_bulk
> >      0.19%  kswapd0  [r8169]            [k] rtl8169_interrupt
> >      0.15%  kswapd0  [kernel.kallsyms]  [k] twa_interrupt
> 
> Quite a lot of time spent shrinking slab (dcache I guess) and a lot of
> spin lock contention.

That's just scanning superblocks, not apparently doing anything
useful like shrinking dentries or inodes attached to each sb. i.e.
the shrinkers are being called an awful lot and basically have
nothing to do. I'd be suspecting a problem higher up in the stack to
do with how shrink_slab is operating or being called.

I'd suggest gathering event traces for mm_shrink_slab_start/
mm_shrink_slab_end to try to see how the shrinkers are being
driven...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
