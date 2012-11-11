Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 585E96B002B
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 04:13:22 -0500 (EST)
Message-ID: <509F6C2A.9060502@redhat.com>
Date: Sun, 11 Nov 2012 10:13:14 +0100
From: Zdenek Kabelac <zkabelac@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <5077434D.7080008@suse.cz> <50780F26.7070007@suse.cz> <20121012135726.GY29125@suse.de> <507BDD45.1070705@suse.cz> <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz> <509C84ED.8090605@linux.vnet.ibm.com> <509CB9D1.6060704@redhat.com> <20121109090635.GG8218@suse.de>
In-Reply-To: <20121109090635.GG8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

Dne 9.11.2012 10:06, Mel Gorman napsal(a):
> On Fri, Nov 09, 2012 at 09:07:45AM +0100, Zdenek Kabelac wrote:
>>> fe2c2a106663130a5ab45cb0e3414b52df2fff0c is the first bad commit
>>> commit fe2c2a106663130a5ab45cb0e3414b52df2fff0c
>>> Author: Rik van Riel <riel@redhat.com>
>>> Date:   Wed Mar 21 16:33:51 2012 -0700
>>>
>>>      vmscan: reclaim at order 0 when compaction is enabled
>>> ...
>>>
>>> This is plausible since the issue seems to be in the kswapd + compaction
>>> realm.  I've yet to figure out exactly what about this commit results in
>>> kswapd spinning.
>>>
>>> I would be interested if someone can confirm this finding.
>>>
>>> --
>>> Seth
>>>
>>
>>
>> On my system 3.7-rc4 the problem seems to be effectively solved by
>> revert patch: https://lkml.org/lkml/2012/11/5/308
>>
>
> Ok, while there is still a question on whether it's enough I think it's
> sensible to at least start with the obvious one.
>


Hmm,  so it's just took longer to hit the problem and observe kswapd0
spinning on my CPU again - it's not as endless like before - but still it 
easily eats minutes - it helps to  turn off  Firefox or TB  (memory hungry 
apps) so kswapd0 stops soon - and restart those apps again.
(And I still have like >1GB of cached memory)

kswapd0         R  running task        0    30      2 0x00000000
  ffff8801331efae8 0000000000000082 0000000000000018 0000000000000246
  ffff880135b9a340 ffff8801331effd8 ffff8801331effd8 ffff8801331effd8
  ffff880055dfa340 ffff880135b9a340 00000000331efad8 ffff8801331ee000
Call Trace:
  [<ffffffff81555bf2>] preempt_schedule+0x42/0x60
  [<ffffffff81557a95>] _raw_spin_unlock+0x55/0x60
  [<ffffffff81192971>] put_super+0x31/0x40
  [<ffffffff81192a42>] drop_super+0x22/0x30
  [<ffffffff81193b89>] prune_super+0x149/0x1b0
  [<ffffffff81141e2a>] shrink_slab+0xba/0x510
  [<ffffffff81185b4a>] ? mem_cgroup_iter+0x17a/0x2e0
  [<ffffffff81185a9a>] ? mem_cgroup_iter+0xca/0x2e0
  [<ffffffff81145099>] balance_pgdat+0x629/0x7f0
  [<ffffffff811453d4>] kswapd+0x174/0x620
  [<ffffffff8106fd20>] ? __init_waitqueue_head+0x60/0x60
  [<ffffffff81145260>] ? balance_pgdat+0x7f0/0x7f0
  [<ffffffff8106f50b>] kthread+0xdb/0xe0
  [<ffffffff8106f430>] ? kthread_create_on_node+0x140/0x140
  [<ffffffff8155fa1c>] ret_from_fork+0x7c/0xb0
  [<ffffffff8106f430>] ? kthread_create_on_node+0x140/0x140


runnable tasks:
             task   PID         tree-key  switches  prio     exec-runtime 
     sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
          kswapd0    30   8689943.729790     36266   120   8689943.729790 
201495.640629  56609485.489414 /
      kworker/0:1 14790   8689937.729790     16969   120   8689937.729790 
   374.385996    150405.181652 /
R           bash 14855       821.749268        50   120       821.749268 
   24.027535      5252.291128 /autogroup-304




Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 146
CPU    1: hi:  186, btch:  31 usd: 135
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 131
CPU    1: hi:  186, btch:  31 usd: 132
active_anon:726521 inactive_anon:26442 isolated_anon:0
  active_file:77765 inactive_file:76890 isolated_file:0
  unevictable:12 dirty:4 writeback:0 unstable:0
  free:40261 slab_reclaimable:12414 slab_unreclaimable:9694
  mapped:26382 shmem:162712 pagetables:6618 bounce:0
  free_cma:0
DMA free:15676kB min:272kB low:340kB high:408kB active_anon:208kB 
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:15900kB mlocked:0kB dirty:0kB 
writeback:0kB mapped:0kB shmem:208kB slab_reclaimable:8kB 
slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB 
free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 2951 3836 3836
DMA32 free:126072kB min:51776kB low:64720kB high:77664kB active_anon:2175104kB 
inactive_anon:98976kB active_file:296252kB inactive_file:297648kB 
unevictable:48kB isolated(anon):0kB isolated(file):0kB present:3021960kB 
mlocked:48kB dirty:12kB writeback:0kB mapped:77664kB shmem:620388kB 
slab_reclaimable:19128kB slab_unreclaimable:6292kB kernel_stack:624kB 
pagetables:8900kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 885 885
Normal free:19296kB min:15532kB low:19412kB high:23296kB active_anon:730772kB 
inactive_anon:6792kB active_file:14808kB inactive_file:9912kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:906664kB mlocked:0kB dirty:4kB 
writeback:0kB mapped:27864kB shmem:30252kB slab_reclaimable:30520kB 
slab_unreclaimable:32476kB kernel_stack:2496kB pagetables:17572kB unstable:0kB 
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 1*8kB 3*16kB 2*32kB 3*64kB 2*128kB 3*256kB 2*512kB 3*1024kB 
3*2048kB 1*4096kB = 15676kB
DMA32: 730*4kB 328*8kB 223*16kB 123*32kB 182*64kB 96*128kB 172*256kB 56*512kB 
12*1024kB 1*2048kB 1*4096kB = 128120kB
Normal: 600*4kB 384*8kB 164*16kB 122*32kB 40*64kB 7*128kB 1*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 19296kB
317367 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
1032176 pages RAM
42789 pages reserved
642501 pages shared
869271 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
