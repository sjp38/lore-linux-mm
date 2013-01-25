Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5E69A6B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 19:55:39 -0500 (EST)
Date: Fri, 25 Jan 2013 08:55:29 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] Negative (setpoint-dirty) in bdi_position_ratio()
Message-ID: <20130125005529.GA21668@localhost>
References: <20130124145707.GB12745@localhost>
 <201301242343.r0ONhjXR024947@como.maths.usyd.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301242343.r0ONhjXR024947@como.maths.usyd.edu.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, akpm@linux-foundation.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 25, 2013 at 10:43:45AM +1100, paul.szabo@sydney.edu.au wrote:
> Dear Fengguang,
> 
> > Or more simple, you may show us the OOM dmesg which will contain the
> > number of dirty pages. ...
> 
> Do you mean kern.log lines like:

Yes.

> [  744.754199] bash invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0, oom_score_adj=0

It's an 2-page allocation in the Normal zone.

> [  744.754202] bash cpuset=/ mems_allowed=0
> [  744.754204] Pid: 3836, comm: bash Not tainted 3.2.0-4-686-pae #1 Debian 3.2.32-1
> ...
> [  744.754354] active_anon:13497 inactive_anon:129 isolated_anon:0
> [  744.754354]  active_file:2664 inactive_file:4144756 isolated_file:0
> [  744.754355]  unevictable:0 dirty:510 writeback:0 unstable:0

Almost no dirty/writeback pages.

> [  744.754356]  free:11867217 slab_reclaimable:68289 slab_unreclaimable:7204
> [  744.754356]  mapped:8066 shmem:250 pagetables:519 bounce:0
> [  744.754361] DMA free:4260kB min:784kB low:980kB high:1176kB active_anon:0kB inactive_anon:0kB active_file:4kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15784kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:11628kB slab_unreclaimable:4kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:499 all_unreclaimable? yes
> [  744.754364] lowmem_reserve[]: 0 867 62932 62932
> [  744.754369] Normal free:43788kB min:44112kB low:55140kB high:66168kB active_anon:0kB inactive_anon:0kB active_file:912kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:887976kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:261528kB slab_unreclaimable:28812kB kernel_stack:3096kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:16060 all_unreclaimable? yes

There are 260MB reclaimable slab pages in the normal zone, however we
somehow failed to reclaim them. What's your filesystem and the content
of /proc/slabinfo?

> [  744.754372] lowmem_reserve[]: 0 0 496525 496525
> [  744.754377] HighMem free:47420820kB min:512kB low:789888kB high:1579264kB active_anon:53988kB inactive_anon:516kB active_file:9740kB inactive_file:16579320kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:63555300kB mlocked:0kB dirty:2040kB writeback:0kB mapped:32260kB shmem:1000kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:2076kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no

There are plenty of free and inactive file pages in the HighMem zone.

Thanks,
Fengguang

> [  744.754380] lowmem_reserve[]: 0 0 0 0
> [  744.754381] DMA: 445*4kB 36*8kB 3*16kB 1*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 4260kB
> [  744.754386] Normal: 1132*4kB 620*8kB 237*16kB 70*32kB 38*64kB 26*128kB 20*256kB 14*512kB 4*1024kB 3*2048kB 0*4096kB = 43808kB
> [  744.754390] HighMem: 226*4kB 242*8kB 155*16kB 66*32kB 10*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 2*2048kB 11574*4096kB = 47420680kB
> [  744.754395] 4148173 total pagecache pages
> [  744.754396] 0 pages in swap cache
> [  744.754397] Swap cache stats: add 0, delete 0, find 0/0
> [  744.754397] Free swap  = 0kB
> [  744.754398] Total swap = 0kB
> [  744.900649] 16777200 pages RAM
> [  744.900650] 16549378 pages HighMem
> [  744.900651] 664304 pages reserved
> [  744.900652] 4162276 pages shared
> [  744.900653] 104263 pages non-shared
> 
> ? (The above and similar were reported to http://bugs.debian.org/695182 .)
> Do you want me to log and report something else?
> 
> I believe the above crash may be provoked simply by running:
>   n=0; while [ $n -lt 99 ]; do dd bs=1M count=1024 if=/dev/zero of=x$n; (( n = $n + 1 )); done &
> on any PAE machine with over 32GB RAM. Oddly the problem does not seem
> to occur when using mem=32g or lower on the kernel boot line (or on
> machines with less than 32GB RAM).
> 
> Cheers, Paul
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
