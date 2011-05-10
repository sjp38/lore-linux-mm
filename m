Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9315390010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 11:30:02 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110510143509.GD4146@suse.de>
References: <1304025145.2598.24.camel@mulgrave.site>
	 <1304030629.2598.42.camel@mulgrave.site> <20110503091320.GA4542@novell.com>
	 <1304431982.2576.5.camel@mulgrave.site>
	 <1304432553.2576.10.camel@mulgrave.site> <20110506074224.GB6591@suse.de>
	 <20110506080728.GC6591@suse.de> <1304964980.4865.53.camel@mulgrave.site>
	 <20110510102141.GA4149@novell.com> <1305036064.6737.8.camel@mulgrave.site>
	 <20110510143509.GD4146@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 10:29:57 -0500
Message-ID: <1305041397.6737.12.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, 2011-05-10 at 15:35 +0100, Mel Gorman wrote:
> On Tue, May 10, 2011 at 09:01:04AM -0500, James Bottomley wrote:
> > On Tue, 2011-05-10 at 11:21 +0100, Mel Gorman wrote:
> > > I really would like to hear if the fix makes a big difference or
> > > if we need to consider forcing SLUB high-order allocations bailing
> > > at the first sign of trouble (e.g. by masking out __GFP_WAIT in
> > > allocate_slab). Even with the fix applied, kswapd might be waking up
> > > less but processes will still be getting stalled in direct compaction
> > > and direct reclaim so it would still be jittery.
> > 
> > "the fix" being this
> > 
> > https://lkml.org/lkml/2011/3/5/121
> > 
> 
> Drop this for the moment. It was a long shot at best and there is little
> evidence the problem is in this area.
> 
> I'm attaching two patches. The first is the NO_KSWAPD one to stop
> kswapd being woken up by SLUB using speculative high-orders. The second
> one is more drastic and prevents slub entering direct reclaim or
> compaction. It applies on top of patch 1. These are both untested and
> afraid are a bit rushed as well :(

Preliminary results with both patches applied still show kswapd
periodically going up to 99% but it doesn't stay there, it comes back
down again (and, obviously, the system doesn't hang).

This is sysrq-M from a couple of times when it went up there:

[  426.736958] SysRq : Show Memory
[  426.736974] Mem-Info:
[  426.736977] Node 0 DMA per-cpu:
[  426.736983] CPU    0: hi:    0, btch:   1 usd:   0
[  426.736986] CPU    1: hi:    0, btch:   1 usd:   0
[  426.736989] CPU    2: hi:    0, btch:   1 usd:   0
[  426.736993] CPU    3: hi:    0, btch:   1 usd:   0
[  426.736996] Node 0 DMA32 per-cpu:
[  426.737002] CPU    0: hi:  186, btch:  31 usd: 169
[  426.737005] CPU    1: hi:  186, btch:  31 usd:  40
[  426.737009] CPU    2: hi:  186, btch:  31 usd: 166
[  426.737012] CPU    3: hi:  186, btch:  31 usd: 168
[  426.737015] Node 0 Normal per-cpu:
[  426.737020] CPU    0: hi:    0, btch:   1 usd:   0
[  426.737024] CPU    1: hi:    0, btch:   1 usd:   0
[  426.737027] CPU    2: hi:    0, btch:   1 usd:   0
[  426.737030] CPU    3: hi:    0, btch:   1 usd:   0
[  426.737036] active_anon:108658 inactive_anon:37031 isolated_anon:0
[  426.737037]  active_file:32006 inactive_file:41051 isolated_file:32
[  426.737038]  unevictable:8 dirty:41202 writeback:204 unstable:0
[  426.737039]  free:191520 slab_reclaimable:8490 slab_unreclaimable:27477
[  426.737039]  mapped:9176 shmem:26412 pagetables:5427 bounce:0
[  426.737051] Node 0 DMA free:8140kB min:548kB low:684kB high:820kB active_anon:0kB inactive_anon:12kB active_file:240kB inactive_file:7280kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:180kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  426.737064] lowmem_reserve[]: 0 1856 1862 1862
[  426.737078] Node 0 DMA32 free:757892kB min:66820kB low:83524kB high:100228kB active_anon:434632kB inactive_anon:148112kB active_file:127784kB inactive_file:156924kB unevictable:32kB isolated(anon):0kB isolated(file):0kB present:1901408kB mlocked:32kB dirty:164808kB writeback:816kB mapped:36704kB shmem:105648kB slab_reclaimable:33676kB slab_unreclaimable:108372kB kernel_stack:2304kB pagetables:21708kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:160 all_unreclaimable? no
[  426.737092] lowmem_reserve[]: 0 0 5 5
[  426.737106] Node 0 Normal free:48kB min:212kB low:264kB high:316kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:6060kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:104kB slab_unreclaimable:1520kB kernel_stack:176kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  426.737119] lowmem_reserve[]: 0 0 0 0
[  426.737132] Node 0 DMA: 3*4kB 2*8kB 1*16kB 1*32kB 2*64kB 2*128kB 2*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 8140kB
[  426.737174] Node 0 DMA32: 945*4kB 585*8kB 6469*16kB 4871*32kB 3189*64kB 1338*128kB 228*256kB 58*512kB 24*1024kB 1*2048kB 0*4096kB = 757884kB
[  426.737227] Node 0 Normal: 2*4kB 5*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 48kB
[  426.737257] 99595 total pagecache pages
[  426.737260] 0 pages in swap cache
[  426.737263] Swap cache stats: add 0, delete 0, find 0/0
[  426.737266] Free swap  = 3768316kB
[  426.737268] Total swap = 3768316kB
[  426.744603] 525808 pages RAM
[  426.744612] 57618 pages reserved
[  426.744614] 141551 pages shared
[  426.744617] 186065 pages non-shared
[  472.301810] SysRq : Show Memory
[  472.301826] Mem-Info:
[  472.301829] Node 0 DMA per-cpu:
[  472.301835] CPU    0: hi:    0, btch:   1 usd:   0
[  472.301839] CPU    1: hi:    0, btch:   1 usd:   0
[  472.301842] CPU    2: hi:    0, btch:   1 usd:   0
[  472.301845] CPU    3: hi:    0, btch:   1 usd:   0
[  472.301848] Node 0 DMA32 per-cpu:
[  472.301854] CPU    0: hi:  186, btch:  31 usd: 184
[  472.301857] CPU    1: hi:  186, btch:  31 usd:  46
[  472.301860] CPU    2: hi:  186, btch:  31 usd: 158
[  472.301863] CPU    3: hi:  186, btch:  31 usd: 163
[  472.301866] Node 0 Normal per-cpu:
[  472.301871] CPU    0: hi:    0, btch:   1 usd:   0
[  472.301874] CPU    1: hi:    0, btch:   1 usd:   0
[  472.301878] CPU    2: hi:    0, btch:   1 usd:   0
[  472.301881] CPU    3: hi:    0, btch:   1 usd:   0
[  472.301886] active_anon:107673 inactive_anon:37031 isolated_anon:0
[  472.301887]  active_file:31533 inactive_file:33323 isolated_file:32
[  472.301888]  unevictable:8 dirty:26256 writeback:6475 unstable:0
[  472.301889]  free:198742 slab_reclaimable:9347 slab_unreclaimable:28647
[  472.301889]  mapped:8307 shmem:26412 pagetables:5427 bounce:0
[  472.301901] Node 0 DMA free:8140kB min:548kB low:684kB high:820kB active_anon:0kB inactive_anon:12kB active_file:240kB inactive_file:7280kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:180kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  472.301915] lowmem_reserve[]: 0 1856 1862 1862
[  472.301928] Node 0 DMA32 free:786780kB min:66820kB low:83524kB high:100228kB active_anon:430692kB inactive_anon:148112kB active_file:125892kB inactive_file:126012kB unevictable:32kB isolated(anon):0kB isolated(file):128kB present:1901408kB mlocked:32kB dirty:105024kB writeback:25900kB mapped:33228kB shmem:105648kB slab_reclaimable:37104kB slab_unreclaimable:113052kB kernel_stack:2288kB pagetables:21708kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:3196 all_unreclaimable? no
[  472.301943] lowmem_reserve[]: 0 0 5 5
[  472.301956] Node 0 Normal free:48kB min:212kB low:264kB high:316kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:6060kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:104kB slab_unreclaimable:1520kB kernel_stack:176kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  472.301968] lowmem_reserve[]: 0 0 0 0
[  472.301982] Node 0 DMA: 3*4kB 2*8kB 1*16kB 1*32kB 2*64kB 2*128kB 2*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 8140kB
[  472.302015] Node 0 DMA32: 6121*4kB 1912*8kB 5094*16kB 4920*32kB 3168*64kB 1381*128kB 262*256kB 68*512kB 24*1024kB 1*2048kB 0*4096kB = 786756kB
[  472.302048] Node 0 Normal: 2*4kB 5*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 48kB
[  472.302090] 91312 total pagecache pages
[  472.302093] 0 pages in swap cache
[  472.302096] Swap cache stats: add 0, delete 0, find 0/0
[  472.302099] Free swap  = 3768316kB
[  472.302102] Total swap = 3768316kB
[  472.309521] 525808 pages RAM
[  472.309529] 57618 pages reserved
[  472.309548] 142496 pages shared
[  472.309551] 177182 pages non-shared

I'll finish off this verification, and then re-run with the watch-highorder script running.

James



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
