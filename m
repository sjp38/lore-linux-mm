Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0D66B0266
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 10:27:45 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gt1so78839409wjc.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 07:27:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p25si21601519wmi.109.2017.02.01.07.27.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Feb 2017 07:27:43 -0800 (PST)
Date: Wed, 1 Feb 2017 16:27:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 192981] New: page allocation stalls
Message-ID: <20170201152742.GA3728@dhcp22.suse.cz>
References: <bug-192981-27@https.bugzilla.kernel.org/>
 <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, apolyakov@beget.ru

[Sorry for a late reply]

On Mon 23-01-17 13:51:11, Andrew Morton wrote:
[...]
> > We have been experiencing page allocation stalls regularly on our machines used
> > as backup servers (many disks, mostly running rsync and rm).
> > 
> > A notable one (2102516ms):
> > 
> > 2017-01-17T11:08:33.754562+03:00 storage8 [335170.452601] rsync: 
> > 2017-01-17T11:08:33.754574+03:00 page allocation stalls for 2102516ms, order:0
> > 2017-01-17T11:08:33.754825+03:00 storage8 ,
> > mode:0x26040d0(GFP_TEMPORARY|__GFP_COMP|__GFP_NOTRACK)

I have checked the log https://bugzilla.kernel.org/attachment.cgi?id=252621
and there are more problems than just this allocation stall.
2017-01-18T02:01:17.613811+03:00 storage8 [24768.850743] INFO: task mcpu:8505 blocked for more than 30 seconds.
2017-01-18T02:01:17.619823+03:00 storage8 [24768.856784] INFO: task mcpu:8506 blocked for more than 30 seconds.
2017-01-18T02:01:17.623022+03:00 storage8 [24768.859983] INFO: task mcpu:8507 blocked for more than 30 seconds.
2017-01-18T02:01:17.626262+03:00 storage8 [24768.863212] INFO: task mcpu:8508 blocked for more than 30 seconds.
2017-01-18T04:24:39.204636+03:00 storage8 [33370.536543] INFO: task atop:18760 blocked for more than 30 seconds.
2017-01-18T04:25:09.924667+03:00 storage8 [33401.256617] INFO: task kswapd0:136 blocked for more than 30 seconds.
2017-01-18T04:25:09.928503+03:00 storage8 [33401.260427] INFO: task kswapd1:137 blocked for more than 30 seconds.
2017-01-18T04:25:09.935268+03:00 storage8 [33401.267236] INFO: task atop:18760 blocked for more than 30 seconds.
2017-01-18T04:25:09.938539+03:00 storage8 [33401.270503] INFO: task rsync:29177 blocked for more than 30 seconds.
2017-01-18T11:40:44.709603+03:00 storage8 [  743.887448] INFO: task rsync:18111 blocked for more than 30 seconds.
2017-01-18T11:40:44.720724+03:00 storage8 [  743.898581] INFO: task rsync:19378 blocked for more than 30 seconds.
2017-01-18T11:42:47.589968+03:00 storage8 [  866.767027] INFO: task kswapd1:139 blocked for more than 30 seconds.
2017-01-18T11:42:47.594015+03:00 storage8 [  866.771109] INFO: task rsync:6909 blocked for more than 30 seconds.
2017-01-18T11:42:47.604005+03:00 storage8 [  866.781098] INFO: task rsync:17582 blocked for more than 30 seconds.
2017-01-18T11:42:47.611063+03:00 storage8 [  866.788159] INFO: task rsync:18111 blocked for more than 30 seconds.
2017-01-18T11:42:47.619089+03:00 storage8 [  866.796183] INFO: task rsync:18776 blocked for more than 30 seconds.
2017-01-18T11:42:47.631557+03:00 storage8 [  866.808652] INFO: task rsync:18777 blocked for more than 30 seconds.
2017-01-18T11:42:47.641018+03:00 storage8 [  866.818099] INFO: task rsync:19281 blocked for more than 30 seconds.
2017-01-18T11:42:47.647701+03:00 storage8 [  866.824797] INFO: task rsync:19740 blocked for more than 30 seconds.

Most of them are waiting for mmap_sem for read but there are cases where
the direct reclaim is waiting for a FS lock (in xfs_reclaim_inodes_ag).
I do not see the 2102516ms stall in the attached log and the information
given here doesn't contain the memory counters. When checking few random
stalls the picture seems to be pretty much consistent

[slightly edited to fix the broken new lines in the output]

2017-01-18T13:28:41.783833+03:00 page allocation stalls for 10380ms, order:0, mode:0x2604050(GFP_NOFS|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK)
[...]
7221.937932]  free:1142851 free_pcp:20 free_cma:2942
2017-01-18T13:28:42.743176+03:00 storage8 [ 7221.938674] Node 0 active_anon:3352112kB inactive_anon:2120kB active_file:87308kB inactive_file:85252kB unevictable:3532kB isolated(anon):0kB iso
lated(file):2852kB mapped:5492kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2128kB writeback_tmp:0kB unstable:0kB pages_scanned:592392 all_unreclaimable?
 yes
2017-01-18T13:28:42.743780+03:00 storage8 [ 7221.939273] Node 1 active_anon:3472092kB inactive_anon:292kB active_file:73592kB inactive_file:72548kB unevictable:61700kB isolated(anon):0kB isolated(file):6640kB mapped:3268kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 292kB writeback_tmp:0kB unstable:0kB pages_scanned:1064 all_unreclaimable? no
[...]
2017-01-18T13:28:42.744551+03:00 storage8 [ 7221.940642] Node 0 DMA32 free: 491744kB min:129476kB low:161844kB high:194212kB active_anon:59952kB inactive_anon:0kB active_file:148kB inactive_file:108kB unevictable:0kB writepending:0kB present:3120640kB managed:3055072kB mlocked:0kB slab_reclaimable:2317296kB slab_unreclaimable:96572kB kernel_stack:32kB pagetables:136kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
2017-01-18T13:28:42.892456+03:00 storage8 [ 7222.088527] lowmem_reserve[]: 90576 90576 0 0
2017-01-18T13:28:42.892592+03:00 storage8 [ 7222.088696] Node 0 Normal free: 1965392kB min:1965456kB low:2456820kB high:2948184kB active_anon:3292160kB inactive_anon:2120kB active_file:87560kB inactive_file:85192kB unevictable:3532kB writepending:0kB present:47185920kB managed:46375368kB mlocked:3532kB slab_reclaimable:24725412kB slab_unreclaimable:2591604kB kernel_stack:15944kB pagetables:98056kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
2017-01-18T13:28:42.893512+03:00 storage8 [ 7222.089602] Node 1 Normal free: 2099044kB min:2098692kB low:2623364kB high:3148036kB active_anon:3472092kB inactive_anon:292kB active_file:71624kB inactive_file:71456kB unevictable:61700kB writepending:0kB present:50331648kB managed:49519168kB mlocked:61700kB slab_reclaimable:28674160kB slab_unreclaimable:2597592kB kernel_stack:8472kB pagetables:51836kB bounce:0kB free_pcp:296kB local_pcp:0kB free_cma:11768kB

All the eligible zones are low on memoyr (DMA32 with the lowmem
protection). Anon memory is not reclaimable because you do not have
any swap. The file LRU seems to contain quite some memory. Dirty
and writeback counters would suggest that the page cache should be
reclaimable but maybe something is pinning those pages. I suspect the
reclaim blocked waiting for IO for metadata. I am not an expert on the
fs side of this but this smells like the IO cannot keep pace with the
load.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
