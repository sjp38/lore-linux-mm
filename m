Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 633306B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 05:45:55 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so1764268dad.14
        for <linux-mm@kvack.org>; Fri, 09 Nov 2012 02:45:54 -0800 (PST)
Message-ID: <509CDEE6.9080600@gmail.com>
Date: Fri, 09 Nov 2012 18:45:58 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3] memcg, oom: provide more precise dump info while memcg
 oom happening
References: <1352389967-23270-1-git-send-email-handai.szj@taobao.com> <509CBB07.9050709@jp.fujitsu.com>
In-Reply-To: <509CBB07.9050709@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 11/09/2012 04:12 PM, Kamezawa Hiroyuki wrote:
> (2012/11/09 0:52), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Current when a memcg oom is happening the oom dump messages is still global
>> state and provides few useful info for users. This patch prints more pointed
>> memcg page statistics for memcg-oom.
>>
>>
>> We set up a simple cgroup hierarchy for test:
>> 	root_memcg
>> 	    |
>> 	    1 (use_hierachy=1, with a process)
>> 	    |
>> 	    2 (its process will be killed by memcg oom)
>>
>> Following are samples of oom output:
>>
>> (1)Before change:
>>
>> [  295.754215] mal invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
>> [  295.754219] mal cpuset=/ mems_allowed=0-1
>> [  295.754221] Pid: 4623, comm: mal Not tainted 3.6.0+ #26
>> [  295.754223] Call Trace:
>> [  295.754230]  [<ffffffff8111b9c4>] dump_header+0x84/0xd0
>> [  295.754233]  [<ffffffff8111c691>] oom_kill_process+0x331/0x350
>> 		..... (call trace)
>> [  295.754288]  [<ffffffff815171e5>] page_fault+0x25/0x30
>> [  295.754291] Task in /1/2 killed as a result of limit of /1
>> [  295.754293] memory: usage 511640kB, limit 512000kB, failcnt 4471
>> [  295.754294] memory+swap: usage 563200kB, limit 563200kB, failcnt 22
>> [  295.754296] kmem: usage 0kB, limit 9007199254740991kB, failcnt 0
>> [  295.754297] Mem-Info:
>> [  295.754298] Node 0 DMA per-cpu:           <<<<<<<<<<<<<<<<<<<<< print per cpu pageset stat
>> [  295.754300] CPU    0: hi:    0, btch:   1 usd:   0
>> 	       ......
>> [  295.754302] CPU    15: hi:    0, btch:   1 usd:   0
>>
>> [  295.754448] Node 0 DMA32 per-cpu:
>> [  295.754450] CPU    0: hi:  186, btch:  31 usd: 181
>> 	       ......
>> [  295.754451] CPU    15: hi:  186, btch:  31 usd:  25
>>
>> [  295.754470] Node 0 Normal per-cpu:
>> [  295.754472] CPU    0: hi:  186, btch:  31 usd:  56
>> 	       ......
>> [  295.754473] CPU    15: hi:  186, btch:  31 usd: 150
>>
>> [  295.754493] Node 1 Normal per-cpu:
>> [  295.754495] CPU    0: hi:  186, btch:  31 usd:   0
>> 	       ......
>> [  295.754496] CPU    15: hi:  186, btch:  31 usd:   0
>> 					     <<<<<<<<<<<<<<<<<<<<< print global page state
>> [  295.754519] active_anon:57756 inactive_anon:73437 isolated_anon:0
>> [  295.754519]  active_file:2659 inactive_file:14291 isolated_file:0
>> [  295.754519]  unevictable:1268 dirty:0 writeback:4961 unstable:0
>> [  295.754519]  free:5979740 slab_reclaimable:2955 slab_unreclaimable:5460
>> [  295.754519]  mapped:2478 shmem:62 pagetables:994 bounce:0
>> [  295.754519]  free_cma:0
>> 					     <<<<<<<<<<<<<<<<<<<<< print per zone page state
>> [  295.754522] Node 0 DMA free:15884kB min:56kB low:68kB high:84kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15884kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>> [  295.754527] lowmem_reserve[]: 0 2966 12013 12013
>> [  295.754530] Node 0 DMA32 free:3041228kB min:11072kB .....
>> [  295.754535] lowmem_reserve[]: 0 0 9046 9046
>> [  295.754537] Node 0 Normal free:8616716kB min:33756kB .....
>> [  295.754542] lowmem_reserve[]: 0 0 0 0
>> [  295.754545] Node 1 Normal free:12245132kB min:45220kB ....
>> [  295.754550] lowmem_reserve[]: 0 0 0 0
>> [  295.754552] Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15884kB
>> [  295.754563] Node 0 DMA32: 5*4kB (M) 3*8kB (M) 6*16kB (UM) ... 738*4096kB (MR) = 3041228kB
>> [  295.754574] Node 0 Normal: 16*4kB (EM) 165*8kB (UEM) ... 2101*4096kB (MR) = 8616840kB
>> [  295.754586] Node 1 Normal: 768*4kB (UEM) 924*8kB (UEM) ... 048kB (EM) 2976*4096kB (MR) = 12245264kB
>> [  295.754598] 25266 total pagecache pages
>> [  295.754599] 7227 pages in swap cache
>> 					     <<<<<<<<<<<<<<<<<<<<< print global swap cache stat
>> [  295.754600] Swap cache stats: add 21474, delete 14247, find 533/576
>> [  295.754601] Free swap  = 2016000kB
>> [  295.754602] Total swap = 2096444kB
>> [  295.816119] 6291440 pages RAM
>> [  295.816121] 108291 pages reserved
>> [  295.816122] 9427 pages shared
>> [  295.816123] 195843 pages non-shared
>> [  295.816124] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
>> [  295.816161] [ 4569]     0  4569    16626      475      18       30             0 bash
>> [  295.816164] [ 4622]     0  4622   103328    87541     208    14950             0 mal
>> [  295.816167] [ 4623]     0  4623   103328    33468      85     5162             0 mal
>> [  295.816171] Memory cgroup out of memory: Kill process 4622 (mal) score 699 or sacrifice child
>> [  295.816173] Killed process 4622 (mal) total-vm:413312kB, anon-rss:349872kB, file-rss:292kB
>>
>> We can see that messages dumped by show_free_areas() are longsome and can provide so limited info for memcg that just happen oom.
>>
>> (2) After change
>> [  269.225628] mal invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
>> [  269.225633] mal cpuset=/ mems_allowed=0-1
>> [  269.225636] Pid: 4616, comm: mal Not tainted 3.6.0+ #25
>> [  269.225637] Call Trace:
>> [  269.225647]  [<ffffffff8111b9c4>] dump_header+0x84/0xd0
>> [  269.225650]  [<ffffffff8111c691>] oom_kill_process+0x331/0x350
>> [  269.225710]  .......(call trace)
>> [  269.225713]  [<ffffffff81517325>] page_fault+0x25/0x30
>> [  269.225716] Task in /1/2 killed as a result of limit of /1
>> [  269.225718] memory: usage 511732kB, limit 512000kB, failcnt 5071
>> [  269.225720] memory+swap: usage 563200kB, limit 563200kB, failcnt 57
>> [  269.225721] kmem: usage 0kB, limit 9007199254740991kB, failcnt 0
>> [  269.225722] Memory cgroup stats:cache:8KB rss:511724KB mapped_file:4KB swap:51468KB inactive_anon:265864KB active_anon:245832KB inactive_file:0KB active_file:0KB unevictable:0KB
>> [  269.225741] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
>> [  269.225757] [ 4554]     0  4554    16626      473      17       25             0 bash
>> [  269.225759] [ 4611]     0  4611   103328    90231     208    12260             0 mal
>> [  269.225762] [ 4616]     0  4616   103328    32799      88     7562             0 mal
>> [  269.225764] Memory cgroup out of memory: Kill process 4611 (mal) score 699 or sacrifice child
>> [  269.225766] Killed process 4611 (mal) total-vm:413312kB, anon-rss:360632kB, file-rss:292kB
>>
>> This version provides more pointed info for memcg in "Memory cgroup stats" section.
>>
> seems very nice !
> some nitpicks below.
>
>> Change log:
>> v3 <--- v2
>> 	1. fix towards hierarchy
>> 	2. undo rework dump_tasks
>> v2 <--- v1
>> 	1. some modification towards hierarchy
>> 	2. rework dump_tasks
>> 	3. rebased on Michal's mm tree since-3.6
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> ---
>>   mm/memcontrol.c |   41 +++++++++++++++++++++++++++++++----------
>>   mm/oom_kill.c   |    6 ++++--
>>   2 files changed, 35 insertions(+), 12 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 0eab7d5..17317fa 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -118,6 +118,14 @@ static const char * const mem_cgroup_events_names[] = {
>>   	"pgmajfault",
>>   };
>>   
>> +static const char * const mem_cgroup_lru_names[] = {
>> +	"inactive_anon",
>> +	"active_anon",
>> +	"inactive_file",
>> +	"active_file",
>> +	"unevictable",
>> +};
>> +
>>   /*
>>    * Per memcg event counter is incremented at every pagein/pageout. With THP,
>>    * it will be incremated by the number of pages. This counter is used for
>> @@ -1501,8 +1509,8 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
>>   	spin_unlock_irqrestore(&memcg->move_lock, *flags);
>>   }
>>   
>> +#define K(x) ((x) << (PAGE_SHIFT-10))
>>   /**
>> - * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
>>    * @memcg: The memory cgroup that went over limit
>>    * @p: Task that is going to be killed
>>    *
>> @@ -1520,8 +1528,10 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>>   	 */
>>   	static char memcg_name[PATH_MAX];
>>   	int ret;
>> +	struct mem_cgroup *mi;
> A nitpick but I prefer using 'iter' as variable name as other for_each_mem_cgroup_tree()
> in memcontrol.c
>

Okay, got it.

>> +	unsigned int i;
>>   
>> -	if (!memcg || !p)
>> +	if (!p)
>>   		return;
>>   
>>   	rcu_read_lock();
>> @@ -1569,6 +1579,25 @@ done:
>>   		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
>>   		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
>>   		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
>> +
>> +	printk(KERN_INFO "Memory cgroup stats:");
> why KERN_INFO rather than default_log_level ?
>

Err, I just keep the level consistent with the upper part of this
function. But the log levels
in oom are various: default, KERN_WARNING, KERN_INFO... etc. How about
reconcile them
in another individual patch? : )


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
