Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4MAETq5022007
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:44:29 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4MAEHBm1359906
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:44:17 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4MADtWL022359
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:43:56 +0530
Message-ID: <48354751.4060206@linux.vnet.ibm.com>
Date: Thu, 22 May 2008 15:43:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/4] Add memrlimit controller documentation (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521152937.15001.83385.sendpatchset@localhost.localdomain> <20080521211603.9fed5e7f.akpm@linux-foundation.org>
In-Reply-To: <20080521211603.9fed5e7f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 21 May 2008 20:59:37 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>
>> Documentation patch - describes the goals and usage of the memrlimit
>> controller.
>>
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  Documentation/controllers/memrlimit.txt |   29 +++++++++++++++++++++++++++++
>>  1 file changed, 29 insertions(+)
>>
>> diff -puN /dev/null Documentation/controllers/memrlimit.txt
>> --- /dev/null	2008-05-16 21:23:36.290004010 +0530
>> +++ linux-2.6.26-rc2-balbir/Documentation/controllers/memrlimit.txt	2008-05-21 20:53:33.000000000 +0530
>> @@ -0,0 +1,29 @@
>> +This controller is enabled by the CONFIG_CGROUP_MEMRLIMIT_CTLR option. Prior
>> +to reading this documentation please read Documentation/cgroups.txt and
>> +Documentation/controllers/memory.txt. Several of the principles of this
>> +controller are similar to the memory resource controller.
>> +
>> +This controller framework is designed to be extensible to control any
>> +memory resource limit with little effort.
>> +
>> +This new controller, controls the address space expansion of the tasks
>> +belonging to a cgroup. Address space control is provided along the same lines as
>> +RLIMIT_AS control, which is available via getrlimit(2)/setrlimit(2).
> 
> Still would like to see more details here.  RLIMIT_AS is simple because
> it applies to a single mm.  But a control group may contain multiple
> mm's, and those mm's can share stuff.
> 
> The sharing probably isn't important in this situation, where we're
> only concerned with virtual address space size, rather than real
> memory.  But still, readers will be wondering about this.
> 
> They also will be wondering about the handling of threads versus
> heavyweight processes.  _we_ know that, but users and administrators
> may not.
> 
> 
>> +The interface for controlling address space is provided through
>> +"rlimit.limit_in_bytes". The file is similar to "limit_in_bytes" w.r.t. the user
>> +interface. Please see section 3 of the memory resource controller documentation
>> +for more details on how to use the user interface to get and set values.
>> +
>> +The "memrlimit.usage_in_bytes" file provides information about the total address
>> +space usage of the tasks in the cgroup, in bytes.
>> +
>> +Advantages of providing this feature
>> +
>> +1. Control over virtual address space allows for a cgroup to fail gracefully
>> +   i.e., via a malloc or mmap failure as compared to OOM kill when no
>> +   pages can be reclaimed.
> 
> Well it's more than "i.e.".  It would be better to precisely spell out
> the behaviour of this feature.  It's mmap() and brk() only, is it not? 
> malloc() isn't a system call ;)
> 

Yes, true. I thought about wording it that way, but end users understand mmap()
and malloc() better that mmap with MAP_ANONYMOUS or brk(), sbrk().

> Ideally, either the changelog, this document or code comments should be
> sufficient for a manpage to be written.  And this level of description
> will lead to better code review and quite likely a better feature.
> 

That makes a lot of sense. I'll work on enhancing this documentation.

>> +2. It provides better control over how many pages can be swapped out when
>> +   the cgroup goes over its limit. A badly setup cgroup can cause excessive
>> +   swapping. Providing control over the address space allocations ensures
>> +   that the system administrator has control over the total swapping that
>> +   can take place.
> 
> IOW: what, exactly and completely, does this feature do?

I'll send an update with more details with an example if possible.


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
