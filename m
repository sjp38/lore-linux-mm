Date: Mon, 4 Feb 2008 16:22:36 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [git pull] SLUB updates for 2.6.25
In-Reply-To: <200802051105.12194.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0802041614580.4926@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com>
 <200802051010.49372.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0802041542570.4774@schroedinger.engr.sgi.com>
 <200802051105.12194.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Nick Piggin wrote:

> I'm sure it could have an effect. But why is the common case in SLUB
> for the cacheline to be bouncing? What's the benchmark? What does SLAB
> do in that benchmark, is it faster than SLUB there? What does the
> non-atomic bit unlock do to Willy's database workload?

I saw this in tbench and the test was done on a recent quad core Intel 
cpu. SLAB is 1 - 4% faster than SLUB on the 2 x Quad setup that I am using 
here to test. Not sure if what I think it is is really the issue. I added 
some statistics to SLUB to figure out what exactly is going on and it 
seems that the remote handoff may not be the issue:

Name                   Objects    Alloc     Free   %Fast
skbuff_fclone_cache         33 111953835 111953835  99  99
:0000192                  2666  5283688  5281047  99  99
:0001024                   849  5247230  5246389  83  83
vm_area_struct            1349   119642   118355  91  22
:0004096                    15    66753    66751  98  98
:0000064                  2067    25297    23383  98  78
dentry                   10259    28635    18464  91  45
:0000080                 11004    18950     8089  98  98
:0000096                  1703    12358    10784  99  98
:0000128                   762    10582     9875  94  18
:0000512                   184     9807     9647  95  81
:0002048                   479     9669     9195  83  65
anon_vma                   777     9461     9002  99  71
kmalloc-8                 6492     9981     5624  99  97
:0000768                   258     7174     6931  58  15

slabinfo -a | grep 000192
:0000192     <- xfs_btree_cur filp kmalloc-192 uid_cache tw_sock_TCP 
request_sock_TCPv6 tw_sock_TCPv6 skbuff_head_cache xfs_ili

Likely skbuff_head_cache.

slabinfo skbuff_fclone_cache

Slab Perf Counter       Alloc     Free %Al %Fr
--------------------------------------------------
Fastpath             111953360 111946981  99  99
Slowpath                 1044     7423   0   0
Page Alloc                272      264   0   0
Add partial                25      325   0   0
Remove partial             86      264   0   0
RemoteObj/SlabFrozen      350     4832   0   0
Total                111954404 111954404

Flushes       49 Refill        0
Deactivate Full=325(92%) Empty=0(0%) ToHead=24(6%) ToTail=1(0%)

There is only minimal handoff here.

skbuff_head_cache:

Slab Perf Counter       Alloc     Free %Al %Fr
--------------------------------------------------
Fastpath              5297262  5259882  99  99
Slowpath                 4477    39586   0   0
Page Alloc                937      824   0   0
Add partial                 0     2515   0   0
Remove partial           1691      824   0   0
RemoteObj/SlabFrozen     2621     9684   0   0
Total                 5301739  5299468

Deactivate Full=2620(100%) Empty=0(0%) ToHead=0(0%) ToTail=0(0%)

Some more handoff but still basically the same.

Need to dig into this some more.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
