Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E911F6B0109
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 04:26:22 -0400 (EDT)
Date: Wed, 13 Oct 2010 16:26:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/17] [RFC] soft and dynamic dirty throttling limits
Message-ID: <20101013082611.GA6733@localhost>
References: <20100912154945.758129106@intel.com>
 <20101012141716.GA26702@infradead.org>
 <20101013030733.GV4681@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101013030733.GV4681@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 11:07:33AM +0800, Dave Chinner wrote:
> On Tue, Oct 12, 2010 at 10:17:16AM -0400, Christoph Hellwig wrote:
> > Wu, what's the state of this series?  It looks like we'll need it
> > rather sooner than later - try to get at least the preparations in
> > ASAP would be really helpful.
> 
> Not ready in it's current form. This load (creating millions of 1
> byte files in parallel):
> 
> $ /usr/bin/time ./fs_mark -D 10000 -S0 -n 100000 -s 1 -L 63 \
> > -d /mnt/scratch/0 -d /mnt/scratch/1 \
> > -d /mnt/scratch/2 -d /mnt/scratch/3 \
> > -d /mnt/scratch/4 -d /mnt/scratch/5 \
> > -d /mnt/scratch/6 -d /mnt/scratch/7
> 
> Locks up all the fs_mark processes spinning in traces like the
> following and no further progress is made when the inode cache
> fills memory.

I reproduced the problem on a 6G/8p 2-socket 11-disk box.

The root cause is, pageout() is somehow called with low scan priority,
which deserves more investigation.

The direct cause is, balance_dirty_pages() then keeps nr_dirty too low,
which can be improved easily by not pushing down the soft dirty limit
to less than 1-second worth of dirty pages.

My test box has two nodes, and their memory usage are rather unbalanced:
(Dave, maybe you have NUMA setup too?)

root@wfg-ne02 ~# cat /sys/devices/system/node/node0/meminfo
root@wfg-ne02 ~# cat /sys/devices/system/node/node1/meminfo

                          Node 0         Node 1
        ------------------------------------------
        MemTotal:        3133760 kB     3145728 kB
==>     MemFree:          453016 kB     2283884 kB
==>     MemUsed:         2680744 kB      861844 kB
        Active:           436436 kB        9744 kB
        Inactive:         846400 kB       37196 kB
        Active(anon):     113304 kB        1588 kB
        Inactive(anon):      412 kB           0 kB
        Active(file):     323132 kB        8156 kB
        Inactive(file):   845988 kB       37196 kB
        Unevictable:           0 kB           0 kB
        Mlocked:               0 kB           0 kB
        Dirty:               244 kB           0 kB
        Writeback:             0 kB           0 kB
        FilePages:       1169832 kB       45352 kB
        Mapped:             9088 kB           0 kB
        AnonPages:        113596 kB        1588 kB
        Shmem:               416 kB           0 kB
        KernelStack:        1472 kB           8 kB
        PageTables:         2600 kB           0 kB
        NFS_Unstable:          0 kB           0 kB
        Bounce:                0 kB           0 kB
        WritebackTmp:          0 kB           0 kB
        Slab:            1133616 kB      701972 kB
        SReclaimable:     902552 kB      693048 kB
        SUnreclaim:       231064 kB        8924 kB
        HugePages_Total:     0              0
        HugePages_Free:      0              0
        HugePages_Surp:      0              0

And somehow pageout() is called with very low scan priority, hence
the vm_dirty_pressure introduced in patch "mm: lower soft dirty limits on
memory pressure" goes all the way down to 0, which makes balance_dirty_pages()
start aggressive dirty throttling.

root@wfg-ne02 ~# cat /debug/vm/dirty_pressure              
0
root@wfg-ne02 ~# echo 1024 > /debug/vm/dirty_pressure

After restoring vm_dirty_pressure the performance immediately restores:

# vmmon nr_free_pages nr_anon_pages nr_file_pages nr_dirty nr_writeback nr_slab_reclaimable slabs_scanned

    nr_free_pages    nr_anon_pages    nr_file_pages         nr_dirty     nr_writeback nr_slab_reclaimable    slabs_scanned          
           870915            13165           337210             1602             8394           221271          2910208
           869924            13206           338116             1532             8293           221414          2910208
           868889            13245           338977             1403             7764           221515          2910208
           867892            13359           339669             1327             8071           221579          2910208
--- vm_dirty_pressure restores from here on ---------------------------------------------------------------------------
           866354            13358           341162             2290             8290           221665          2910208
           863627            13419           343259             4014             8332           221833          2910208
           861008            13662           344968             5854             8333           222092          2910208
           858513            13601           347019             7622             8333           222371          2910208
           855272            13693           348987             9449             8333           223301          2910208
           851959            13789           350898            11287             8333           224273          2910208
           848641            13878           352812            13060             8333           225223          2910208
           845398            13967           354822            14854             8333           226193          2910208
           842216            14062           356749            16684             8333           227148          2910208
           838844            14152           358862            18500             8333           228129          2910208
           835447            14245           360678            20313             8333           229084          2910208
           832265            14338           362561            22117             8333           230058          2910208
           829098            14429           364710            23906             8333           231005          2910208
           825609            14520           366530            25726             8333           231971          2910208

# dstat
        ----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
        usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw 
          0   6  82   0   0  12|   0  2240k| 766B 8066B|   0     0 |1435  1649 
          0   4  85   0   0  11|   0  2266k| 262B  436B|   0     0 |1141  1055 
          0   5  83   0   0  12|   0  2196k| 630B 7132B|   0     0 |1144  1053 
          0   6  81   0   0  13|   0  2424k|1134B   20k|   0     0 |1284  1282 
          0   7  81   0   0  12|   0  2152k| 628B 4660B|   0     0 |1634  1944 
          0   4  84   0   0  12|   0  2184k| 192B  580B|   0     0 |1133  1037 
          0   4  84   0   0  12|   0  2440k| 192B  564B|   0     0 |1197  1124 
--- vm_dirty_pressure restores from here on -----------------------------------
          0  51  35   0   0  14| 112k 6718k|  20k   17k|   0     0 |2539  1478 
          1  83   0   0   0  17|   0    13M| 252B  564B|   0     0 |3221  1270 
          0  78   6   0   0  16|   0    15M|1434B   12k|   0     0 |3596  1590 
          0  83   1   0   0  16|   0    13M| 324B 4154B|   0     0 |3318  1374 
          0  80   4   1   0  16|   0    14M|1706B 9824B|   0     0 |3469  1632 
          0  76   5   1   0  18|   0    15M| 636B 4558B|   0     0 |3777  1940 
          0  71   9   1   0  19|   0    17M| 510B 3068B|   0     0 |4018  2277 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
