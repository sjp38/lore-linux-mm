Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9331D6B005A
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 23:58:28 -0400 (EDT)
Message-ID: <4A31D326.3030206@cn.fujitsu.com>
Date: Fri, 12 Jun 2009 12:01:42 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: boot panic with memcg enabled (Was [PATCH 3/4] memcg: don't use
 bootmem allocator in setup code)
References: <Pine.LNX.4.64.0906110820170.2258@melkki.cs.Helsinki.FI>	<4A31C258.2050404@cn.fujitsu.com>	<20090612115501.df12a457.kamezawa.hiroyu@jp.fujitsu.com> <20090612124408.721ba2ae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090612124408.721ba2ae.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, yinghai@kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 12 Jun 2009 11:55:01 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> On Fri, 12 Jun 2009 10:50:00 +0800
>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>
>>> (This patch should have CCed memcg maitainers)
>>>
>>> My box failed to boot due to initialization failure of page_cgroup, and
>>> it's caused by this patch:
>>>
>>> +	page = alloc_pages_node(nid, GFP_NOWAIT | __GFP_ZERO, order);
>>>
>> Oh, I don't know this patch ;(
>>
>>> I added a printk, and found that order == 11 == MAX_ORDER.
>>>
>> maybe possible because this allocates countinous pages of 60%? length of
>> memmap. 
>> If __alloc_bootmem_node_nopanic() is not available any more, memcg should be
>> only used under CONFIG_SPARSEMEM. 
>>
>> Is that a request from bootmem maintainer ?
>>
> In other words,
>  - Is there any replacment function to allocate continuous pages bigger
>    than MAX_ORDER ?
>  - If not, memcg (and io-controller under development) shouldn't support
>    memory model other than SPARSEMEM.
> 
> IIUC, page_cgroup_init() is called before mem_init() and we could use
> alloc_bootmem() here.
> 
> Could someone teach me which thread should I read to know
> "why alloc_bootmem() is gone ?" ?
> 

alloc_bootmem() is not gone, but slab allocator is setup much earlier now.
See this commit:

commit 83b519e8b9572c319c8e0c615ee5dd7272856090
Author: Pekka Enberg <penberg@cs.helsinki.fi>
Date:   Wed Jun 10 19:40:04 2009 +0300

    slab: setup allocators earlier in the boot sequence

now page_cgroup_init() is called after mem_init().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
