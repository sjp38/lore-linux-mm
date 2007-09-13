Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8DFuXTX031447
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 01:56:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DFvbRs058018
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 01:57:37 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DFrk9t031628
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 01:53:46 +1000
Message-ID: <46E95CFA.6090300@linux.vnet.ibm.com>
Date: Thu, 13 Sep 2007 21:23:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: problem with ZONE_MOVABLE.
References: <20070913190719.ab6451e7.kamezawa.hiroyu@jp.fujitsu.com> <20070913131117.GG22778@skynet.ie>
In-Reply-To: <20070913131117.GG22778@skynet.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.osdl.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On (13/09/07 19:07), KAMEZAWA Hiroyuki didst pronounce:
>> Hi, 
>>
>> While I'm playing with memory controller of 2.6.23-rc4-mm1, I met following.
>>
>> ==
>> [root@drpq test-2.6.23-rc4-mm1]# echo $$ > /opt/mem_control/group_1/tasks
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.limit
>> 32768
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.usage
>> 286
>> // Memory is limited to 512 GiB. try "dd" 1GiB (page size is 16KB)
>>  
>> [root@drpq test-2.6.23-rc4-mm1]# dd if=/dev/zero of=/tmp/tmpfile bs=1024 count=1048576
>> Killed
>> [root@drpq test-2.6.23-rc4-mm1]# ls
>> Killed
>> //above are caused by OOM.
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.usage
>> 32763
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.limit
>> 32768
>> // fully filled by page cache. no reclaim run.
>> ==
>>
>> The reason  this happens is  because I used kernelcore= boot option, i.e
>> ZONE_MOVABLE. Seems try_to_free_mem_container_pages() ignores ZONE_MOVABLE.
>>
>> Quick fix is attached, but Mel's one-zonelist-pernode patch may change this.
>> I'll continue to watch.
>>
> 
> You are right on both counts. This is a valid fix but
> one-zonelist-pernode overwrites it. Specifically the code in question
> with one-zonelist will look like;
> 
> 	for_each_online_node(node) {
> 		zonelist = &NODE_DATA(node)->node_zonelist;
> 		if (do_try_to_free_pages(zonelist, sc.gfp_mask, &sc))
> 			return 1;
> 	}
> 
> We should be careful that this problem does not get forgotten about if
> one-zonelist gets delayed for a long period of time. Have the fix at the
> end of the container patchset where it can be easily dropped if
> one-zonelist is merged.
> 
> Thanks

Yes, I second that. So, we should get KAMEZAWA's fix in.

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
