Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1L9Taw2030646
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 14:59:36 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1L9TaG2954556
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 14:59:36 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1L9TZcQ027882
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 09:29:36 GMT
Message-ID: <47BD4375.6010404@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2008 14:55:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <47BC10A8.4020508@linux.vnet.ibm.com> <20080221.114929.42336527.taka@valinux.co.jp> <20080221153536.09c28f44.kamezawa.hiroyu@jp.fujitsu.com> <20080221.180745.74279466.taka@valinux.co.jp>
In-Reply-To: <20080221.180745.74279466.taka@valinux.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:
> Hi,
> 
>>>> We thought of this as well. We dropped it, because we need to track only user
>>>> pages at the moment. Doing it for all pages means having the overhead for each
>>>> page on the system.
>>> Let me clarify that the overhead you said is you'll waste some memory
>>> whose pages are assigned for the kernel internal use, right?
>>> If so, it wouldn't be a big problem since most of the pages are assigned to
>>> process anonymous memory or to the page cache as Paul said.
>>>
>> My idea is..
>> (1) It will be big waste of memory to pre-allocate all page_cgroup struct at
>>     boot.  Because following two will not need it.
>>     (1) kernel memory
>>     (2) HugeTLB memory
>> Mainly because of (2), I don't like pre-allocation.
> 
> I thought kernel memory wasn't big deal but I didn't think about HugeTLB memory.
> 

Yes, true. I don't like pre-allocation either, but people have complained about
increase in page size. I am not committing to pre-allocation, but I promised I
would look at bringing the overhead down. Nick suggested using a radix tree.

>> But we'll be able to archive  pfn <-> page_cgroup relationship using
>> on-demand memmap style.
>> (Someone mentioned about using radix-tree in other thread.)
> 
> My concern is this approach seems to require some spinlocks to protect the
> radix-tree. If you really don't want to allocate page_cgroups for HugeTLB
> memory, what do you think if you should turn on the memory controller after
> allocating HugeTlb pages?
> 

Yes, I expressed that concern on IRC as well. We've have to measure and see
performance impact. It was told to me from experience that, the overhead would
be lost as noise (which I find hard to believe).

>> Balbir-san, I'd like to do some work aroung this becasue I've experience
>> sparsemem and memory hotplug developments.
>>
>> Or have you already started ?
> 
> Not yet. So you can go ahead.
> 

Yes, please feel free to do so.

>> Thanks,
>> -Kame
> 
> Thank you,
> Hirokazu Takahashi.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


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
