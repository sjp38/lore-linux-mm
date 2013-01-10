Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 44EB96B006C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 03:36:01 -0500 (EST)
Message-ID: <50EE7D75.8080100@parallels.com>
Date: Thu, 10 Jan 2013 12:36:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <20130109142314.1ce04a96.akpm@linux-foundation.org> <50EE24A4.8020601@cn.fujitsu.com> <50EE6A48.7060307@parallels.com> <50EE6E50.3040609@jp.fujitsu.com> <50EE73DE.30208@parallels.com> <50EE7A6B.7020005@jp.fujitsu.com>
In-Reply-To: <50EE7A6B.7020005@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org


> If it's configure as ZONE_NORMAL, you need to pray for offlining memory.
> 
> AFAIK, IBM's ppc? has 16MB section size. So, some of sections can be
> offlined
> even if they are configured as ZONE_NORMAL. For them, placement of offlined
> memory is not important because it's virtualized by LPAR, they don't try
> to remove DIMM, they just want to increase/decrease amount of memory.
> It's an another approach.
> 
> But here, we(fujitsu) tries to remove a system board/DIMM.
> So, configuring the whole memory of a node as ZONE_MOVABLE and tries to
> guarantee
> DIMM as removable.
> 
>>> IMHO, I don't think shrink_slab() can kill all objects in a node even
>>> if they are some caches. We need more study for doing that.
>>>
>>
>> Indeed, shrink_slab can only kill cached objects. They, however, are
>> usually a very big part of kernel memory. I wonder though if in case of
>> failure, it is worth it to try at least one shrink pass before you
>> give up.
>>
> 
> Yeah, now, his (our) approach is never allowing kernel memory on a node
> to be
> hot-removed by ZONE_MOVABLE. So, shrink_slab()'s effect will not be seen.

Ok, that clarifies it to me.
> 
> If other brave guys tries to use ZONE_NORMAL for hot-pluggable DIMM, I see,
> it's worth triying.
> 
I was under the impression that this was being done in here.

> How about checking the target memsection is in NORMAL or in MOVABLE at
> hot-removing ? If NORMAL, shrink_slab() will be worth to be called.
> 
Yes, this is what I meant. I think there is value investigating this,
since for a lot of workloads, a lot of the kernel memory will consist of
shrinkable cached memory. It would provide you with the same level of
guarantees (zero), but can improve the success  rate (this is, of
course, a guess)


> BTW, shrink_slab() is now node/zone aware ? If not, fixing that first will
> be better direction I guess.
> 
It is not upstream, but there are patches for this that I am already
using in my private tree.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
