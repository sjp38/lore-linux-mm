Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id F32E86B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 11:57:40 -0400 (EDT)
Date: Thu, 6 Jun 2013 17:57:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM Killer and add_to_page_cache_locked
Message-ID: <20130606155323.GD24115@dhcp22.suse.cz>
References: <51B05616.9050501@adocean-global.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B05616.9050501@adocean-global.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Nowojski <piotr.nowojski@adocean-global.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

[CCing linux-mm and lkml]

On Thu 06-06-13 11:27:50, Piotr Nowojski wrote:
> Hi,

Hi,
 
> In our system we have hit some very annoying situation (bug?) with
> cgroups. I'm writing to you, because I have found your posts on
> mailing lists with similar topic. Maybe you could help us or point
> some direction where to look for/ask.
> 
> We have system with ~15GB RAM (+2GB SWAP), and we are running ~10
> heavy IO processes. Each process is using constantly 200-210MB RAM
> (RSS) and a lot of page cache. All processes are in cgroup with
> following limits:
> 
> /sys/fs/cgroup/taskell2 $ cat memory.limit_in_bytes
> memory.memsw.limit_in_bytes
> 14183038976
> 15601344512

I assume that memory.use_hierarchy is 1, right?

> Each process is being started in separate cgroup, with
> memory_soft_limit set to 1GB.
> 
> /sys/fs/cgroup/taskell2 $ ls | grep subtask
> subtask5462692
> subtask5462697
> subtask5462698
> subtask5462699
> subtask5462700
> subtask5462701
> subtask5462702
> subtask5462703
> subtask5462704
> 
> /sys/fs/cgroup/taskell2 $ cat subtask5462704/memory.limit_in_bytes
> subtask5462704/memory.memsw.limit_in_bytes
> subtask5462704/memory.soft_limit_in_bytes
> 9223372036854775807
> 9223372036854775807
> 1073741824
> 
> Memory usage is following:
> 
> free -g
>              total       used       free     shared    buffers cached
> Mem:            14         14          0          0 0         12
> -/+ buffers/cache:          1         13
> Swap:            1          0          1
> 
> /sys/fs/cgroup/taskell2 $ cat memory.stat
> cache 13208932352
> rss 0
> hierarchical_memory_limit 14183038976
> hierarchical_memsw_limit 15601344512
> total_cache 13775765504
> total_rss 264949760
> total_swap 135974912
> 
> In other words, most memory is used by page cache and everything IMO
> should work just fine, but it isn't. Every couple of minutes, one of
> the processes is being killed by OOM Killer, triggered from IO read
> and "add_to_page_cache" (full stack attached below). For me this is
> ridiculous behavior. Process is trying to put something into page
> cache, but there is no free memory (because everything is eaten by
> page_cache) thus triggering OOM Killer. Why? Most of this page cache
> is not even used - at least not heavily used. Is this a bug? Stupid
> feature? Or am I missing something? Our configuration:

It sounds like a bug to me. If you had a small groups I would say that
the memory reclaim is not able to free any memory because almost all
the pages on the LRU are dirty and dirty pages throttling is not memcg
aware but your groups contain a lot of pages and all of they shouldn't
be dirty because the global dirty memory throttling should slow down
writers and writeback should have already started.

This has been fixed (or worked around to be more precise) by e62e384e
(memcg: prevent OOM with too many dirty pages) in 3.6.

Maybe you could try this patch and see if it helps. I would be sceptical
but it is worth trying.

The core thing to find out is why the hard limit reclaim is not able to
free anything. Unfortunatelly we do not have memcg reclaim statistics so
it would be a bit harder. I would start with the above patch first and
then I can prepare some debugging patches for you.

Also does 3.4 vanila (or the stable kernel) behave the same way? Is the
current vanilla behaving the same way?

Finally, have you seen the issue for a longer time or it started showing
up only now?

> cat /etc/issue
> Ubuntu 12.04.2 LTS
> 
> uname -a
> Linux alfa 3.4.35-030435-generic #201303031830 SMP Sun Mar 3
> 23:31:50 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
> 
> regards, Piotr Nowojski
> 
> 
> Jun  5 17:27:10 alfa kernel: [3634217.398303] gzip invoked
> oom-killer: gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
> Jun  5 17:27:10 alfa kernel: [3634217.398308] gzip
> cpuset=subtask5452469 mems_allowed=0
> Jun  5 17:27:10 alfa kernel: [3634217.398311] Pid: 416, comm: gzip
> Not tainted 3.4.35-030435-generic #201303031830
> Jun  5 17:27:10 alfa kernel: [3634217.398314] Call Trace:
> Jun  5 17:27:10 alfa kernel: [3634217.398323] [<ffffffff81668a2d>]
> dump_header+0x86/0xc0
> Jun  5 17:27:10 alfa kernel: [3634217.398326] [<ffffffff81668b1e>]
> oom_kill_process.part.8+0x55/0x264
> Jun  5 17:27:10 alfa kernel: [3634217.398331] [<ffffffff81122f54>]
> oom_kill_process+0x34/0x40
> Jun  5 17:27:10 alfa kernel: [3634217.398334] [<ffffffff81123016>]
> mem_cgroup_out_of_memory+0xb6/0x100
> Jun  5 17:27:10 alfa kernel: [3634217.398339] [<ffffffff81179500>]
> mem_cgroup_handle_oom+0x160/0x2d0
> Jun  5 17:27:10 alfa kernel: [3634217.398342] [<ffffffff8117507a>] ?
> mem_cgroup_margin+0xaa/0xb0
> Jun  5 17:27:10 alfa kernel: [3634217.398345] [<ffffffff81175340>] ?
> mc_handle_file_pte+0xd0/0xd0
> Jun  5 17:27:10 alfa kernel: [3634217.398347] [<ffffffff811797a8>]
> mem_cgroup_do_charge+0x138/0x160
> Jun  5 17:27:10 alfa kernel: [3634217.398350] [<ffffffff811798cf>]
> __mem_cgroup_try_charge+0xff/0x3a0
> Jun  5 17:27:10 alfa kernel: [3634217.398354] [<ffffffff81290430>] ?
> fuse_readpages+0xe0/0xe0
> Jun  5 17:27:10 alfa kernel: [3634217.398357] [<ffffffff8117a110>]
> mem_cgroup_charge_common+0x60/0xa0
> Jun  5 17:27:10 alfa kernel: [3634217.398360] [<ffffffff8117abce>]
> mem_cgroup_cache_charge+0xbe/0xd0
> Jun  5 17:27:10 alfa kernel: [3634217.398363] [<ffffffff8128f7cd>] ?
> fuse_wait_on_page_writeback+0x1d/0xa0
> Jun  5 17:27:10 alfa kernel: [3634217.398366] [<ffffffff8111fbdc>]
> add_to_page_cache_locked+0x4c/0xa0
> Jun  5 17:27:10 alfa kernel: [3634217.398369] [<ffffffff8111fc51>]
> add_to_page_cache_lru+0x21/0x50
> Jun  5 17:27:10 alfa kernel: [3634217.398372] [<ffffffff8112b1fc>]
> read_cache_pages+0x7c/0x120
> Jun  5 17:27:10 alfa kernel: [3634217.398375] [<ffffffff812903d4>]
> fuse_readpages+0x84/0xe0
> Jun  5 17:27:10 alfa kernel: [3634217.398377] [<ffffffff8112ae98>]
> read_pages+0x48/0x100
> Jun  5 17:27:10 alfa kernel: [3634217.398380] [<ffffffff8112b0ab>]
> __do_page_cache_readahead+0x15b/0x170
> Jun  5 17:27:10 alfa kernel: [3634217.398383] [<ffffffff8112b421>]
> ra_submit+0x21/0x30
> Jun  5 17:27:10 alfa kernel: [3634217.398385] [<ffffffff8112b545>]
> ondemand_readahead+0x115/0x230
> Jun  5 17:27:10 alfa kernel: [3634217.398388] [<ffffffff8112b6e8>]
> page_cache_async_readahead+0x88/0xb0
> Jun  5 17:27:10 alfa kernel: [3634217.398393] [<ffffffff81324fbe>] ?
> radix_tree_lookup_slot+0xe/0x10
> Jun  5 17:27:10 alfa kernel: [3634217.398396] [<ffffffff8111f9ce>] ?
> find_get_page+0x1e/0x90
> Jun  5 17:27:10 alfa kernel: [3634217.398399] [<ffffffff81120319>]
> do_generic_file_read.constprop.33+0x269/0x440
> Jun  5 17:27:10 alfa kernel: [3634217.398402] [<ffffffff8112128f>]
> generic_file_aio_read+0xef/0x280
> Jun  5 17:27:10 alfa kernel: [3634217.398406] [<ffffffff811896dc>] ?
> pipe_write+0x2fc/0x590
> Jun  5 17:27:10 alfa kernel: [3634217.398408] [<ffffffff8128efcb>]
> fuse_file_aio_read+0x7b/0xa0
> Jun  5 17:27:10 alfa kernel: [3634217.398412] [<ffffffff8117f80a>]
> do_sync_read+0xda/0x120
> Jun  5 17:27:10 alfa kernel: [3634217.398416] [<ffffffff81040b15>] ?
> pvclock_clocksource_read+0x55/0xf0
> Jun  5 17:27:10 alfa kernel: [3634217.398420] [<ffffffff812adb33>] ?
> security_file_permission+0x93/0xb0
> Jun  5 17:27:10 alfa kernel: [3634217.398424] [<ffffffff8117fc91>] ?
> rw_verify_area+0x61/0xf0
> Jun  5 17:27:10 alfa kernel: [3634217.398427] [<ffffffff81180170>]
> vfs_read+0xb0/0x180
> Jun  5 17:27:10 alfa kernel: [3634217.398430] [<ffffffff8118028a>]
> sys_read+0x4a/0x90
> Jun  5 17:27:10 alfa kernel: [3634217.398434] [<ffffffff8167f34e>] ?
> do_device_not_available+0xe/0x10
> Jun  5 17:27:10 alfa kernel: [3634217.398438] [<ffffffff81686969>]
> system_call_fastpath+0x16/0x1b
> Jun  5 17:27:10 alfa kernel: [3634217.398441] Task in
> /taskell2/subtask5452467 killed as a result of limit of /taskell2
> Jun  5 17:27:10 alfa kernel: [3634217.398444] memory: usage
> 13850624kB, limit 13850624kB, failcnt 35456895
> Jun  5 17:27:10 alfa kernel: [3634217.398446] memory+swap: usage
> 13865844kB, limit 15235688kB, failcnt 63280
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
