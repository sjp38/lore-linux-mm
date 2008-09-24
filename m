Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8O8XKaR013000
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 18:33:20 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8O8WJUq4120682
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 18:33:08 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8O8WJsn014178
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 18:32:19 +1000
Message-ID: <48D9FAFF.8070404@linux.vnet.ibm.com>
Date: Wed, 24 Sep 2008 01:31:59 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer from
 struct page)
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com> <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com> <20080924084839.f5901719.kamezawa.hiroyu@jp.fujitsu.com> <661de9470809231909h24ca4a39k470e322f2c1019dc@mail.gmail.com> <20080924120940.5aea6907.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080924120940.5aea6907.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 24 Sep 2008 07:39:58 +0530
> "Balbir Singh" <balbir@linux.vnet.ibm.com> wrote:
>>> I'll add FLATMEM/DISCONTIGMEM/SPARSEMEM support directly.
>>> I already have wasted a month on this not-interesting work and want to fix
>>> this soon.
>>>
>> Let's look at the basic requirement, make memory resource controller
>> not suck with 32 bit systems. I have been thinking of about removing
>> page_cgroup from struct page only for 32 bit systems (use radix tree),
>> 32 bit systems can have a maximum of 64GB if PAE is enabled, I suspect
>> radix tree should work there and let the 64 bit systems work as is. If
>> performance is an issue, I would recommend the 32 bit folks upgrade to
>> 64 bit :) Can we build consensus around this approach?
>>
> My thinking is below. (assume 64bit)
> 

assume 64 bit for the calculations below?

>   - remove page_cgroup pointer from struct page allows us to reduce
>     static memory usage at boot by 8bytes/4096bytes if memory cgroup is disabled.
>     This reaches 96MB on my 48 GB box. I think this is big.
>   - pre-allocation of page_cgroup gives us following.
>    Pros.
>       - We are not necessary to be afraid of "failure of kmalloc" and
>         "goes down to memory reclaim at kmalloc"
>         This makes memory resource controller much simpler and robust.
>       - We can know what amount of kernel memory will be used for
>         LRU pages management.
>    Cons.
>       - All page_cgroups are allocated at boot.
>         This reaches 480MB on my 48GB box.
> 
>   But I think we can ignore "Cons.". If we use up memory, we'll use tons of
>   page_cgroup. Considering memory fragmentation caused by allocating a lots of
>   very small object, pre-allocation makes memcg better.

This looks like a good patch. I'll review and test it.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
