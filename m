Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1KBMPrw025908
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 16:52:25 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KBMP4G741532
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 16:52:25 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1KBMOMe007289
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 11:22:25 GMT
Message-ID: <47BC0C72.4080004@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 16:48:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <47BBC15E.5070405@linux.vnet.ibm.com> <20080220.185821.61784723.taka@valinux.co.jp> <6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com> <47BBFCC2.5020408@linux.vnet.ibm.com> <6599ad830802200218t41c70455u5d008c605e8b9762@mail.gmail.com> <47BC0704.9010603@linux.vnet.ibm.com> <20080220202143.4cc2fc05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080220202143.4cc2fc05.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Feb 2008 16:25:00 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Paul Menage wrote:
>>> On Feb 20, 2008 2:11 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>> Dynamically turning on/off the memory controller, can/will lead to accounting
>>>> issues and deficiencies, since the memory controller would now have no idea of
>>>> how much memory has been allocated by which cgroup.
>>>>
>>> A cgroups subsystem can only be unbound from its hierarchy when there
>>> are no child cgroups of the root cgroup in that hierarchy. So this
>>> shouldn't be too much of a problem - when this transition occurs, all
>>> tasks are in the same group, and no other groups exist.
>>>
>>> Paul
>> Yes, I agree, but then at the point of unbinding them, tasks could have already
>> allocated several pages to their RSS or brought in pages into the page cache.
>> Accounting from this state is not so straight forward and will lead to more
>> complexity in code.
> 
> unbind -> force_empty can't work ?
> 
> Thanks,
> -Kame
> 

Kame, unbind->force_empty can work, but we can't force_empty the root cgroup.
Even if we could, the code to deal with turning on/off the entire memory
controller and accounting is likely to be very complex and probably racy.

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
