Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7L3ZpPr026745
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 13:35:51 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7L3aubj300916
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 13:36:56 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7L3auhN006777
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 13:36:56 +1000
Message-ID: <48ACE2D5.8090106@linux.vnet.ibm.com>
Date: Thu, 21 Aug 2008 09:06:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH -mm 0/7] memcg: lockless page_cgroup v1
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com> <20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com> <20080820194108.e76b20b3.kamezawa.hiroyu@jp.fujitsu.com> <20080820200006.a152c14c.kamezawa.hiroyu@jp.fujitsu.com> <20080821111740.49f99038.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080821111740.49f99038.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Aug 2008 20:00:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> On Wed, 20 Aug 2008 19:41:08 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>>> On Wed, 20 Aug 2008 18:53:06 +0900
>>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>
>>>> Hi, this is a patch set for lockless page_cgroup.
>>>>
>>>> dropped patches related to mem+swap controller for easy review.
>>>> (I'm rewriting it, too.)
>>>>
>>>> Changes from current -mm is.
>>>>   - page_cgroup->flags operations is set to be atomic.
>>>>   - lock_page_cgroup() is removed.
>>>>   - page->page_cgroup is changed from unsigned long to struct page_cgroup*
>>>>   - page_cgroup is freed by RCU.
>>>>   - For avoiding race, charge/uncharge against mm/memory.c::insert_page() is
>>>>     omitted. This is ususally used for mapping device's page. (I think...)
>>>>
>>>> In my quick test, perfomance is improved a little. But the benefit of this
>>>> patch is to allow access page_cgroup without lock. I think this is good 
>>>> for Yamamoto's Dirty page tracking for memcg.
>>>> For I/O tracking people, I added a header file for allowing access to
>>>> page_cgroup from out of memcontrol.c
>>>>
>>>> The base kernel is recent mmtom. Any comments are welcome.
>>>> This is still under test. I have to do long-run test before removing "RFC".
>>>>
>>> Known problem: force_emtpy is broken...so rmdir will struck into nightmare.
>>> It's because of patch 2/7.
>>> will be fixed in the next version.
>>>
>> This is a quick fix but I think I can find some better solution..
>> ==
>> Because removal from LRU is delayed, mz->lru will never be empty until
>> someone kick drain. This patch rotate LRU while force_empty and makes
>> page_cgroup will be freed.
>>
> 
> I'd like to rewrite force_empty to move all usage to "default" cgroup.
> There are some reasons.
> 
> 1. current force_empty creates an alive page which has no page_cgroup.
>    This is bad for routine which want to access page_cgroup from page.
>    And this behavior will be an issue of race condition in future.    
> 2. We can see amount of out-of-control usage in default cgroup.
> 
> But to do this, I'll have to avoid "hitting limit" in default cgroup.
> I'm now wondering to make it impossible to set limit to default cgroup.
> (will show as a patch in the next version of series.) 
> Does anyone have an idea ?
> 

Hi, Kamezawa-San,

The definition of default-cgroup would be root cgroup right? I would like to
implement hierarchies correctly in order to define the default-cgroup (it could
be a parent of the child cgroup for example).


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
