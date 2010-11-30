Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49A776B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 02:03:36 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id oAU73X8H021676
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 23:03:33 -0800
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by kpbe19.cbf.corp.google.com with ESMTP id oAU73W8i023329
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 23:03:32 -0800
Received: by qyk33 with SMTP id 33so5833294qyk.2
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 23:03:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130155327.8313.A69D9226@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<20101130155327.8313.A69D9226@jp.fujitsu.com>
Date: Mon, 29 Nov 2010 23:03:31 -0800
Message-ID: <AANLkTi=idNjuptkQuiaOF+GiUDjBaBC9kW370u-041sT@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/4] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 10:54 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> The current implementation of memcg only supports direct reclaim and this
>> patchset adds the support for background reclaim. Per cgroup background
>> reclaim is needed which spreads out the memory pressure over longer period
>> of time and smoothes out the system performance.
>>
>> The current implementation is not a stable version, and it crashes sometimes
>> on my NUMA machine. Before going further for debugging, I would like to start
>> the discussion and hear the feedbacks of the initial design.
>
> I haven't read your code at all. However I agree your claim that memcg
> also need background reclaim.

Thanks for your comment.
>
> So if you post high level design memo, I'm happy.

My high level design is kind of spreading out into each patch, and
here is the consolidated one. This is nothing more but cluing all the
commits' messages for the following patches.

"
The current implementation of memcg only supports direct reclaim and this
patchset adds the support for background reclaim. Per cgroup background
reclaim is needed which spreads out the memory pressure over longer period
of time and smoothes out the system performance.

There is a kswapd kernel thread for each memory node. We add a different kswapd
for each cgroup. The kswapd is sleeping in the wait queue headed at kswapd_wait
field of a kswapd descriptor. The kswapd descriptor stores information of node
or cgroup and it allows the global and per cgroup background reclaim to share
common reclaim algorithms. The per cgroup kswapd is invoked at mem_cgroup_charge
when the cgroup's memory usage above a threshold--low_wmark. Then the kswapd
thread starts to reclaim pages in a priority loop similar to global algorithm.
The kswapd is done if the usage below a threshold--high_wmark.

The per cgroup background reclaim is based on the per cgroup LRU and also adds
per cgroup watermarks. There are two watermarks including "low_wmark" and
"high_wmark", and they are calculated based on the limit_in_bytes(hard_limit)
for each cgroup. Each time the hard_limit is change, the corresponding wmarks
are re-calculated. Since memory controller charges only user pages, there is
no need for a "min_wmark". The current calculation of wmarks is a function of
"memory.min_free_kbytes" which could be adjusted by writing different values
into the new api. This is added mainly for debugging purpose.

The kswapd() function now is shared between global and per cgroup kswapd thread.
It is passed in with the kswapd descriptor which contains the information of
either node or cgroup. Then the new function balance_mem_cgroup_pgdat is invoked
if it is per cgroup kswapd thread. The balance_mem_cgroup_pgdat performs a
priority loop similar to global reclaim. In each iteration it invokes
balance_pgdat_node for all nodes on the system, which is a new function performs
background reclaim per node. After reclaiming each node, it checks
mem_cgroup_watermark_ok() and breaks the priority loop if returns true. A per
memcg zone will be marked as "unreclaimable" if the scanning rate is much
greater than the reclaiming rate on the per cgroup LRU. The bit is cleared when
there is a page charged to the cgroup being freed. Kswapd breaks the priority
loop if all the zones are marked as "unreclaimable".
"

Also, I am happy to add more descriptions if anything not clear :)

thanks

--Ying

>
>>
>> Current status:
>> I run through some simple tests which reads/writes a large file and makes sure
>> it triggers per cgroup kswapd on the low_wmark. Also, I compared at
>> pg_steal/pg_scan ratio w/o background reclaim.
>>
>> Step1: Create a cgroup with 500M memory_limit and set the min_free_kbytes to 1024.
>> $ mount -t cgroup -o cpuset,memory cpuset /dev/cgroup
>> $ mkdir /dev/cgroup/A
>> $ echo 0 >/dev/cgroup/A/cpuset.cpus
>> $ echo 0 >/dev/cgroup/A/cpuset.mems
>> $ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
>> $ echo 1024 >/dev/cgroup/A/memory.min_free_kbytes
>> $ echo $$ >/dev/cgroup/A/tasks
>>
>> Step2: Check the wmarks.
>> $ cat /dev/cgroup/A/memory.reclaim_wmarks
>> memcg_low_wmark 98304000
>> memcg_high_wmark 81920000
>>
>> Step3: Dirty the pages by creating a 20g file on hard drive.
>> $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1
>>
>> Checked the memory.stat w/o background reclaim. It used to be all the pages are
>> reclaimed from direct reclaim, and now about half of them are reclaimed at
>> background. (note: writing '0' to min_free_kbytes disables per cgroup kswapd)
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
