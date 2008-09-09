Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m89E3ZnP028050
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 00:03:35 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m89E4gYf242360
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 00:04:44 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m89E4f4m003651
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 00:04:42 +1000
Message-ID: <48C6826B.9000202@linux.vnet.ibm.com>
Date: Tue, 09 Sep 2008 07:04:27 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/14]  memcg: lockless page cgroup
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com> <20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp> <20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Sep 2008 14:40:07 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
>>> +	/* Double counting race condition ? */
>>> +	VM_BUG_ON(page_get_page_cgroup(page));
>>> +
>>>  	page_assign_page_cgroup(page, pc);
>>>  
>>>  	mz = page_cgroup_zoneinfo(pc);
>> I got this VM_BUG_ON at swapoff.
>>
>> Trying to shmem_unuse_inode a page which has been moved
>> to swapcache by shmem_writepage causes this BUG, because
>> the page has not been uncharged(with all the patches applied).
>>
>> I made a patch which changes shmem_unuse_inode to charge with
>> GFP_NOWAIT first and shrink usage on failure, as shmem_getpage does.
>>
>> But I don't stick to my patch if you handle this case :)
>>
> Thank you for testing and sorry for no progress in these days.
> 
> I'm sorry to say that I'll have to postpone this to remove
> page->page_cgroup pointer. I need some more performance-improvement
> effort to remove page->page_cgroup pointer without significant overhead.
> 

I don't think this should take long to do. It's really easy to do (I've tried
two approaches and it look me a day to get them working). I am trying some other
approach based on early_init and alloc_bootmem*.

> So please be patient for a while.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
