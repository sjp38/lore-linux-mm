From: Karl Vogel <karl.vogel@seagha.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Date: Tue, 31 Aug 2004 00:59:26 +0200
References: <20040828151349.00f742f4.akpm@osdl.org> <41336B6F.6050806@pandora.be> <20040830171604.GA2103@logos.cnet>
In-Reply-To: <20040830171604.GA2103@logos.cnet>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200408310059.26621.karl.vogel@seagha.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Karl Vogel <karl.vogel@pandora.be>, Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 30 August 2004 19:16, Marcelo Tosatti wrote:
> Karl,
>
> Please apply the attached patch and rerun your tests. With it applied,
> the OOM killer output will print the number of available swap pages at
> the time of killing.

[kvo@localhost sources]$ cat /proc/meminfo
MemTotal:       515728 kB
MemFree:        495772 kB
Buffers:           556 kB
Cached:           3384 kB
SwapCached:          0 kB
Active:           7736 kB
Inactive:         1948 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       515728 kB
LowFree:        495772 kB
SwapTotal:     1044216 kB
SwapFree:      1044216 kB
Dirty:              40 kB
Writeback:           0 kB
Mapped:           7044 kB
Slab:             5412 kB
Committed_AS:     9544 kB
PageTables:        548 kB
VmallocTotal:   516020 kB
VmallocUsed:      2372 kB
VmallocChunk:   512624 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     4096 kB
[kvo@localhost sources]$ date;time ./expunge 1024;date;time 
cat /proc/meminfo;date
Tue Aug 31 00:45:25 CEST 2004
Killed

real	0m8.662s
user	0m0.636s
sys	0m1.015s
Tue Aug 31 00:45:42 CEST 2004
MemTotal:       515728 kB
MemFree:         10364 kB
Buffers:           140 kB
Cached:           2696 kB
SwapCached:     482928 kB
Active:           2308 kB
Inactive:       484124 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       515728 kB
LowFree:         10364 kB
SwapTotal:     1044216 kB
SwapFree:       556868 kB
Dirty:               0 kB
Writeback:      219084 kB
Mapped:           1784 kB
Slab:            13948 kB
Committed_AS:     9544 kB
PageTables:        548 kB
VmallocTotal:   516020 kB
VmallocUsed:      2372 kB
VmallocChunk:   512624 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     4096 kB

real	0m0.655s
user	0m0.000s
sys	0m0.001s
Tue Aug 31 00:45:43 CEST 2004


dmesg output:

kswapd0: page allocation failure. order:0, mode:0x20
 [<c013e9a8>] __alloc_pages+0x1c8/0x390
 [<c013eb8f>] __get_free_pages+0x1f/0x40
 [<c014205d>] kmem_getpages+0x1d/0xb0
 [<c0142d16>] cache_grow+0xb6/0x170
 [<c0142f36>] cache_alloc_refill+0x166/0x210
 [<c015d579>] bio_alloc+0xd9/0x1b0
 [<c01431d6>] kmem_cache_alloc+0x56/0x70
 [<c01b2d5f>] radix_tree_node_alloc+0x1f/0x60
 [<c01b3002>] radix_tree_insert+0xe2/0x100
 [<c0152c42>] __add_to_swap_cache+0x72/0xf0
 [<c0152e1b>] add_to_swap+0x5b/0xb0
 [<c014599c>] shrink_list+0x43c/0x470
 [<c014e319>] page_referenced_anon+0x49/0x90
 [<c0144718>] __pagevec_release+0x28/0x40
 [<c0145b1d>] shrink_cache+0x14d/0x340
 [<c014525f>] shrink_slab+0x7f/0x180
 [<c014627a>] shrink_zone+0x9a/0xc0
 [<c014665b>] balance_pgdat+0x1cb/0x230
 [<c0146787>] kswapd+0xc7/0xe0
 [<c011cbb0>] autoremove_wake_function+0x0/0x60
 [<c010605e>] ret_from_fork+0x6/0x14
 [<c011cbb0>] autoremove_wake_function+0x0/0x60
 [<c01466c0>] kswapd+0x0/0xe0
 [<c0104291>] kernel_thread_helper+0x5/0x14

>>> lots of these cut from mail

oom-killer: gfp_mask=0xd2
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
HighMem per-cpu: empty

Free pages:         660kB (0kB HighMem)
Active:596 inactive:120914 dirty:0 writeback:120868 unstable:0 free:165 
slab:5896 mapped:598 pagetables:278
DMA free:20kB min:20kB low:40kB high:60kB active:32kB inactive:11040kB 
present:16384kB pages_scanned:8928 all_unreclaimable? yes
protections[]: 0 0 0
Normal free:640kB min:696kB low:1392kB high:2088kB active:2352kB 
inactive:472616kB present:507328kB pages_scanned:276672 all_unreclaimable? 
yes
protections[]: 0 0 0
HighMem free:0kB min:128kB low:256kB high:384kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
protections[]: 0 0 0
DMA: 1*4kB 0*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 
0*2048kB 0*4096kB = 20kB
Normal: 0*4kB 0*8kB 0*16kB 0*32kB 10*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 
0*2048kB 0*4096kB = 640kB
HighMem: empty
nr_free_swap_pages: 116933
Swap cache: add 925862, delete 804994, find 990/1254, race 0+0
Out of Memory: Killed process 2513 (expunge).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
