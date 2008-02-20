Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1K6j5xr026325
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 12:15:05 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1K6j5WU610398
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 12:15:05 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1K6j4ww010071
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 06:45:04 GMT
Message-ID: <47BBCB75.201@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 12:10:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220100333.a014083c.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802200355220.3569@blonde.site> <20080220133742.94a0b1b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080220133742.94a0b1b6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Feb 2008 04:14:58 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
>> On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
>>> On Tue, 19 Feb 2008 15:40:45 +0000 (GMT)
>>> Hugh Dickins <hugh@veritas.com> wrote:
>>>
>>>> A lot in common with yours, a lot not.  (And none of it addressing
>>>> that issue of opt-out I raise in the last paragraph: haven't begun
>>>> to go into that one, hoped you and Balbir would look into it.)
>>>>
>>> I have some trial patches for reducing atomic_ops by do_it_lazy method.
>>> Now, I'm afraid that performence is too bad when there is *no* memory
>>> pressure.
>> But it isn't just the atomic ops, it's the whole business of
>> mem_cgroup_charge_common plus mem_cgroup_uncharge_page per page.
>>
>> The existence of force_empty indicates that the system can get along
>> without the charge on the page. 
> Yes.
> 
>> What's needed, I think, is something in struct mm, a flag or a reserved value
>> in mm->mem_cgroup, to say don't do any of this mem_cgroup stuff on me; and a cgroup
>> fs interface to set that, in the same way as force_empty is done.
> 
> I agree here. I believe we need "no charge" flag at least to the root group.
> For root group, it's better to have boot option if not complicated.

I don't think that would work very well. A boot option to turn off everything
makes more sense. The reason why I say it would not work very well is

1. You might want to control the memory used the root cgroup. Consider a system
where all tasks are distributed across sub-cgroups and only a few and default
tasks will be left in the root cgroup. The administrator might want to control
how much memory can be used
2. We need to account for root's usage. This will become very important once we
implement a hierarchy and build in support for shares.
3. The interface remains consistent that way, treating the root as special would
make our interface inconsistent (since we cannot apply/enforce limits at root).

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
