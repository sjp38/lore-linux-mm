Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 3C5946B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 11:14:09 -0400 (EDT)
Message-ID: <51B1F8B3.8030108@adocean-global.com>
Date: Fri, 07 Jun 2013 17:13:55 +0200
From: Piotr Nowojski <piotr.nowojski@adocean-global.com>
MIME-Version: 1.0
Subject: Re: OOM Killer and add_to_page_cache_locked
References: <51B05616.9050501@adocean-global.com> <20130606155323.GD24115@dhcp22.suse.cz>
In-Reply-To: <20130606155323.GD24115@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

W dniu 06.06.2013 17:57, Michal Hocko pisze:
>   
>> >In our system we have hit some very annoying situation (bug?) with
>> >cgroups. I'm writing to you, because I have found your posts on
>> >mailing lists with similar topic. Maybe you could help us or point
>> >some direction where to look for/ask.
>> >
>> >We have system with ~15GB RAM (+2GB SWAP), and we are running ~10
>> >heavy IO processes. Each process is using constantly 200-210MB RAM
>> >(RSS) and a lot of page cache. All processes are in cgroup with
>> >following limits:
>> >
>> >/sys/fs/cgroup/taskell2 $ cat memory.limit_in_bytes
>> >memory.memsw.limit_in_bytes
>> >14183038976
>> >15601344512
> I assume that memory.use_hierarchy is 1, right?
System has been rebooted since last test, so I can not guarantee that it 
was set for 100%, but it should have been. Currently I'm rerunning this 
scenario that lead to the described problem with:

/sys/fs/cgroup/taskell2# cat memory.use_hierarchy ../memory.use_hierarchy
1
0

Where root cgroup, doesn't have any limits set.

/sys/fs/cgroup/taskell2# cat ../memory*limit*
9223372036854775807
9223372036854775807
9223372036854775807

>> >Each process is being started in separate cgroup, with
>> >memory_soft_limit set to 1GB.
>> >
>> >/sys/fs/cgroup/taskell2 $ ls | grep subtask
>> >subtask5462692
>> >subtask5462697
>> >subtask5462698
>> >subtask5462699
>> >subtask5462700
>> >subtask5462701
>> >subtask5462702
>> >subtask5462703
>> >subtask5462704
>> >
>> >/sys/fs/cgroup/taskell2 $ cat subtask5462704/memory.limit_in_bytes
>> >subtask5462704/memory.memsw.limit_in_bytes
>> >subtask5462704/memory.soft_limit_in_bytes
>> >9223372036854775807
>> >9223372036854775807
>> >1073741824
>> >
>> >Memory usage is following:
>> >
>> >free -g
>> >              total       used       free     shared    buffers cached
>> >Mem:            14         14          0          0 0         12
>> >-/+ buffers/cache:          1         13
>> >Swap:            1          0          1
>> >
>> >/sys/fs/cgroup/taskell2 $ cat memory.stat
>> >cache 13208932352
>> >rss 0
>> >hierarchical_memory_limit 14183038976
>> >hierarchical_memsw_limit 15601344512
>> >total_cache 13775765504
>> >total_rss 264949760
>> >total_swap 135974912
>> >
>> >In other words, most memory is used by page cache and everything IMO
>> >should work just fine, but it isn't. Every couple of minutes, one of
>> >the processes is being killed by OOM Killer, triggered from IO read
>> >and "add_to_page_cache" (full stack attached below). For me this is
>> >ridiculous behavior. Process is trying to put something into page
>> >cache, but there is no free memory (because everything is eaten by
>> >page_cache) thus triggering OOM Killer. Why? Most of this page cache
>> >is not even used - at least not heavily used. Is this a bug? Stupid
>> >feature? Or am I missing something? Our configuration:
> It sounds like a bug to me. If you had a small groups I would say that
> the memory reclaim is not able to free any memory because almost all
> the pages on the LRU are dirty and dirty pages throttling is not memcg
> aware but your groups contain a lot of pages and all of they shouldn't
> be dirty because the global dirty memory throttling should slow down
> writers and writeback should have already started.
>
> This has been fixed (or worked around to be more precise) by e62e384e
> (memcg: prevent OOM with too many dirty pages) in 3.6.
>
> Maybe you could try this patch and see if it helps. I would be sceptical
> but it is worth trying.
>
> The core thing to find out is why the hard limit reclaim is not able to
> free anything. Unfortunatelly we do not have memcg reclaim statistics so
> it would be a bit harder. I would start with the above patch first and
> then I can prepare some debugging patches for you.
I will try 3.6 (probably 3.7) kernel after weekend - unfortunately 
repeating whole scenario is taking 10-30 hours because of very slowly 
growing page cache.
>
> Also does 3.4 vanila (or the stable kernel) behave the same way? Is the
> current vanilla behaving the same way?
I don't know, we are using standard kernel that comes from Ubuntu.
>
> Finally, have you seen the issue for a longer time or it started showing
> up only now?
>
This system is very new. We have started testing scenario which 
triggered OOM something like one week ago and we have immediately hit 
this issue. Previously, with different scenarios and different memory 
usage by processes we didn't have this issue.

Piotr Nowojski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
