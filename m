Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 0DB516B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 04:44:04 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so3206609ghr.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 01:44:04 -0700 (PDT)
Message-ID: <4F6C37AC.4080101@gmail.com>
Date: Fri, 23 Mar 2012 16:43:24 +0800
From: bill4carson <bill4carson@gmail.com>
MIME-Version: 1.0
Subject: Re: Why memory.usage_in_bytes is always increasing after every mmap/dirty/unmap
 sequence
References: <4F6C2E9B.9010200@gmail.com> <4F6C31F7.2010804@jp.fujitsu.com>
In-Reply-To: <4F6C31F7.2010804@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2012a1'03ae??23ae?JPY 16:19, KAMEZAWA Hiroyuki wrote:
> (2012/03/23 17:04), bill4carson wrote:
>
>> Hi, all
>>
>> I'm playing with memory cgroup, I'm a bit confused why
>> memory.usage in bytes is steadily increasing at 4K page pace
>> after every mmap/dirty/unmap sequence.
>>
>> On linux-3.6.34.10/linux-3.3.0-rc5
>> A simple test case does following:
>>
>> a) mmap 128k memory in private anonymous way
>> b) dirty all 128k to demand physical page
>> c) print memory.usage_in_bytes<-- increased at 4K after every loop
>> d) unmap previous 128 memory
>> e) goto a) to repeat
>
> In Documentation/cgroup/memory.txt
> ==
> 5.5 usage_in_bytes
>
> For efficiency, as other kernel components, memory cgroup uses some optimization
> to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
> method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
> value for efficient access. (Of course, when necessary, it's synchronized.)
> If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
> value in memory.stat(see 5.2).
> ==
>
> In current implementation, memcg tries to charge resource in size of 32 pages.
> So, if you get 32 pages and free 32pages, usage_in_bytes may not change.
> This is affected by caches in other cpus and other flushing operations caused
> by some workload in other cgroups. memcg's usage_in_bytes is not precise in
> 128k degree.

Thanks for the internal design details.
I noticed on 2.6.34, it's checked on every 512 Kbytes

See http://lxr.linux.no/#linux+v2.6.34/mm/memcontrol.c#L571

And I haven't see the 3.3.0 changes.


>
> - How memory.stat changes ?


root@localhost:/sys/fs/cgroup/memory/a> cat memory.stat;cat 
memory.usage_in_bytes
cache 0
rss 131072            <------ when mmap/dirty/
mapped_file 0
pgpgin 1278
pgpgout 1246
inactive_anon 0
active_anon 131072
inactive_file 0
active_file 0
unevictable 0
hierarchical_memory_limit 9223372036854775807
total_cache 0
total_rss 131072
total_mapped_file 0
total_pgpgin 1278
total_pgpgout 1246
total_inactive_anon 0
total_active_anon 131072
total_inactive_file 0
total_active_file 0
total_unevictable 0


root@localhost:/sys/fs/cgroup/memory/a> cat memory.stat;cat 
memory.usage_in_bytes
cache 0
rss 4096            <------ when mmap/dirty/unmap
mapped_file 0
pgpgin 1278
pgpgout 1277
inactive_anon 0
active_anon 4096
inactive_file 0
active_file 0
unevictable 0
hierarchical_memory_limit 9223372036854775807
total_cache 0
total_rss 4096
total_mapped_file 0
total_pgpgin 1278
total_pgpgout 1277
total_inactive_anon 0
total_active_anon 4096
total_inactive_file 0
total_active_file 0
total_unevictable 0


> - What happens when you do test with 4M alloc/free ?
>

I tried on 2.6.34, it's the same behavior.


> Thanks,
> -Kame
>
>
>
>
>
>
>
>
>

-- 
Love each day!

--bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
