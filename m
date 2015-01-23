Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4476B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 10:47:10 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id wp18so7796193obc.3
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:47:10 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id 11si964854oin.122.2015.01.23.07.47.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 07:47:09 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YEgRw-0017Jf-Tu
	for linux-mm@kvack.org; Fri, 23 Jan 2015 15:47:09 +0000
Message-ID: <54C26CE3.2060001@roeck-us.net>
Date: Fri, 23 Jan 2015 07:46:43 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050802.GB22751@roeck-us.net> <20150123141817.GA22926@phnom.home.cmpxchg.org>
In-Reply-To: <20150123141817.GA22926@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, cl@linux.com

On 01/23/2015 06:18 AM, Johannes Weiner wrote:
> Hi Guenter,
>
> CC'ing Christoph for slub-stuff:
>
> On Thu, Jan 22, 2015 at 09:08:02PM -0800, Guenter Roeck wrote:
>> On Thu, Jan 22, 2015 at 03:05:17PM -0800, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2015-01-22-15-04 has been uploaded to
>>>
>>>     http://www.ozlabs.org/~akpm/mmotm/
>>>
>> qemu test for ppc64 fails with
>>
>> Unable to handle kernel paging request for data at address 0x0000af50
>> Faulting instruction address: 0xc00000000089d5d4
>> Oops: Kernel access of bad area, sig: 11 [#1]
>>
>> with the following call stack:
>>
>> Call Trace:
>> [c00000003d32f920] [c00000000089d588] .__slab_alloc.isra.44+0x7c/0x6f4
>> (unreliable)
>> [c00000003d32fa90] [c00000000020cf8c] .kmem_cache_alloc_node_trace+0x12c/0x3b0
>> [c00000003d32fb60] [c000000000bceeb4] .mem_cgroup_init+0x128/0x1b0
>> [c00000003d32fbf0] [c00000000000a2b4] .do_one_initcall+0xd4/0x260
>> [c00000003d32fce0] [c000000000ba26a8] .kernel_init_freeable+0x244/0x32c
>> [c00000003d32fdb0] [c00000000000ac24] .kernel_init+0x24/0x140
>> [c00000003d32fe30] [c000000000009564] .ret_from_kernel_thread+0x58/0x74
>>
>> bisect log:
>
> [...]
>
>> # first bad commit: [a40d0d2cf21e2714e9a6c842085148c938bf36ab] mm: memcontrol: remove unnecessary soft limit tree node test
>
> The change in question is this:
>
>      mm: memcontrol: remove unnecessary soft limit tree node test
>
>      kzalloc_node() automatically falls back to nodes with suitable memory.
>
>      Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>      Acked-by: Michal Hocko <mhocko@suse.cz>
>      Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
>      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fb9788af4a3e..10db4a654d68 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4539,13 +4539,10 @@ static void __init mem_cgroup_soft_limit_tree_init(void)
>   {
>          struct mem_cgroup_tree_per_node *rtpn;
>          struct mem_cgroup_tree_per_zone *rtpz;
> -       int tmp, node, zone;
> +       int node, zone;
>
>          for_each_node(node) {
> -               tmp = node;
> -               if (!node_state(node, N_NORMAL_MEMORY))
> -                       tmp = -1;
> -               rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
> +               rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
>                  BUG_ON(!rtpn);
>
>                  soft_limit_tree.rb_tree_per_node[node] = rtpn;
>
> --
>
> Is the assumption of this patch wrong?  Does the specified node have
> to be online for the fallback to work?
>

I added some debugging. First, the problem is only seen with SMP disabled.
Second, there is only one online node.

Without your patch:

Node 0 online 1 high 1 memory 1 cpu 0 normal 1 tmp 0 rtpn c00000003d240600
Node 1 online 0 high 0 memory 0 cpu 0 normal 0 tmp -1 rtpn c00000003d240640
Node 2 online 0 high 0 memory 0 cpu 0 normal 0 tmp -1 rtpn c00000003d240680

[ and so on up to node 255 ]

With your patch:

Node 0 online 1 high 1 memory 1 cpu 0 normal 1 rtpn c00000003d240600
Unable to handle kernel paging request for data at address 0x0000af50
Faulting instruction address: 0xc000000000895a3c
Oops: Kernel access of bad area, sig: 11 [#1]

The log message is after the call to kzalloc_node.

So it doesn't look like the fallback is working, at least not with ppc64
in non-SMP mode.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
