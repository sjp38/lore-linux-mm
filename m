Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1185A6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 23:32:37 -0400 (EDT)
Received: by oiko83 with SMTP id o83so127738904oik.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 20:32:36 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id g3si9284446oeu.95.2015.05.04.20.32.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 20:32:36 -0700 (PDT)
Message-ID: <554839D0.3080703@hp.com>
Date: Mon, 04 May 2015 23:32:32 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
References: <1430231830-7702-1-git-send-email-mgorman@suse.de> <554030D1.8080509@hp.com> <5543F802.9090504@hp.com> <554415B1.2050702@hp.com> <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
In-Reply-To: <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/04/2015 05:30 PM, Andrew Morton wrote:
> On Fri, 01 May 2015 20:09:21 -0400 Waiman Long<waiman.long@hp.com>  wrote:
>
>> On 05/01/2015 06:02 PM, Waiman Long wrote:
>>> Bad news!
>>>
>>> I tried your patch on a 24-TB DragonHawk and got an out of memory
>>> panic. The kernel log messages were:
>> ...
>>
>>> [   81.360287]  [<ffffffff8151b0c9>] dump_stack+0x68/0x77
>>> [   81.365942]  [<ffffffff8151ae1e>] panic+0xb9/0x219
>>> [   81.371213]  [<ffffffff810785c3>] ?
>>> __blocking_notifier_call_chain+0x63/0x80
>>> [   81.378971]  [<ffffffff811384ce>] __out_of_memory+0x34e/0x350
>>> [   81.385292]  [<ffffffff811385ee>] out_of_memory+0x5e/0x90
>>> [   81.391230]  [<ffffffff8113ce9e>] __alloc_pages_slowpath+0x6be/0x740
>>> [   81.398219]  [<ffffffff8113d15c>] __alloc_pages_nodemask+0x23c/0x250
>>> [   81.405212]  [<ffffffff81186346>] kmem_getpages+0x56/0x110
>>> [   81.411246]  [<ffffffff81187f44>] fallback_alloc+0x164/0x200
>>> [   81.417474]  [<ffffffff81187cfd>] ____cache_alloc_node+0x8d/0x170
>>> [   81.424179]  [<ffffffff811887bb>] kmem_cache_alloc_trace+0x17b/0x240
>>> [   81.431169]  [<ffffffff813d5f3a>] init_memory_block+0x3a/0x110
>>> [   81.437586]  [<ffffffff81b5f687>] memory_dev_init+0xd7/0x13d
>>> [   81.443810]  [<ffffffff81b5f2af>] driver_init+0x2f/0x37
>>> [   81.449556]  [<ffffffff81b1599b>] do_basic_setup+0x29/0xd5
>>> [   81.455597]  [<ffffffff81b372c4>] ? sched_init_smp+0x140/0x147
>>> [   81.462015]  [<ffffffff81b15c55>] kernel_init_freeable+0x20e/0x297
>>> [   81.468815]  [<ffffffff81512ea0>] ? rest_init+0x80/0x80
>>> [   81.474565]  [<ffffffff81512ea9>] kernel_init+0x9/0xf0
>>> [   81.480216]  [<ffffffff8151f788>] ret_from_fork+0x58/0x90
>>> [   81.486156]  [<ffffffff81512ea0>] ? rest_init+0x80/0x80
>>> [   81.492350] ---[ end Kernel panic - not syncing: Out of memory and
>>> no killable processes...
>>> [   81.492350]
>>>
>>> -Longman
>> I increased the pre-initialized memory per node in update_defer_init()
>> of mm/page_alloc.c from 2G to 4G. Now I am able to boot the 24-TB
>> machine without error. The 12-TB has 0.75TB/node, while the 24-TB
>> machine has 1.5TB/node. I would suggest something like pre-initializing
>> 1G per 0.25TB/node. In this way, it will scale properly with the memory
>> size.
> We're using more than 2G before we've even completed do_basic_setup()?
> Where did it all go?

I think they may be used in the allocation of the hash tables like:

[    2.367440] Dentry cache hash table entries: 2147483648 (order: 22, 
17179869184 bytes)
[   11.522768] Inode-cache hash table entries: 2147483648 (order: 22, 
17179869184 bytes)
[   18.598513] Mount-cache hash table entries: 67108864 (order: 17, 
536870912 bytes)
[   18.667485] Mountpoint-cache hash table entries: 67108864 (order: 17, 
536870912 bytes)

The size of those hash tables do scale somewhat linearly with the amount 
of total memory available.

>> Before the patch, the boot time from elilo prompt to ssh login was 694s.
>> After the patch, the boot up time was 346s, a saving of 348s (about 50%).
> Having to guesstimate the amount of memory which is needed for a
> successful boot will be painful.  Any number we choose will be wrong
> 99% of the time.
>
> If the kswapd threads have started, all we need to do is to wait: take
> a little nap in the allocator's page==NULL slowpath.
>
> I'm not seeing any reason why we can't start kswapd much earlier -
> right at the start of do_basic_setup()?

I think we can, we just have to change the hash table allocator to do that.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
