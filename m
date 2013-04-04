Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 8B4896B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 19:41:32 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 09:34:43 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3AB1F2BB0052
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 10:41:27 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r34NfMbI4194730
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 10:41:22 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r34NfQur001126
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 10:41:26 +1100
Date: Fri, 5 Apr 2013 07:41:23 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20130404234123.GA362@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130404161746.GP29911@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130404161746.GP29911@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 04, 2013 at 06:17:46PM +0200, Michal Hocko wrote:
>On Thu 04-04-13 17:09:08, Wanpeng Li wrote:
>> order >= MAX_ORDER pages are only allocated at boot stage using the 
>> bootmem allocator with the "hugepages=xxx" option. These pages are never 
>> free after boot by default since it would be a one-way street(>= MAX_ORDER
>> pages cannot be allocated later), but if administrator confirm not to 
>> use these gigantic pages any more, these pinned pages will waste memory
>> since other users can't grab free pages from gigantic hugetlb pool even
>> if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
>> shrink supporting. Administrator can enable knob exported in sysctl to
>> permit to shrink gigantic hugetlb pool.
>
>I am not sure I see why the new knob is needed.
>/sys/kernel/mm/hugepages/hugepages-*/nr_hugepages is root interface so
>an additional step to allow writing to the file doesn't make much sense
>to me to be honest.
>
>Support for shrinking gigantic huge pages makes some sense to me but I
>would be interested in the real world example. GB pages are usually used
>in very specific environments where the amount is usually well known.

Gigantic huge pages in hugetlb means h->order >= MAX_ORDER instead of GB 
pages. ;-)

Regards,
Wanpeng Li 

>
>I could imagine nr_hugepages_mempolicy would make more sense to free
>pages from particular nodes so they could be offlined for example.
>Does the patchset handles this as well?
>
>> Testcase:
>> boot: hugepagesz=1G hugepages=10
>> 
>> [root@localhost hugepages]# free -m
>>              total       used       free     shared    buffers     cached
>> Mem:         36269      10836      25432          0         11        288
>> -/+ buffers/cache:      10537      25732
>> Swap:        35999          0      35999
>> [root@localhost hugepages]# echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
>> -bash: echo: write error: Invalid argument
>> [root@localhost hugepages]# echo 1 > /proc/sys/vm/hugetlb_shrink_gigantic_pool
>> [root@localhost hugepages]# echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
>> [root@localhost hugepages]# free -m
>>              total       used       free     shared    buffers     cached
>> Mem:         36269        597      35672          0         11        288
>> -/+ buffers/cache:        297      35972
>> Swap:        35999          0      35999
>> 
>> Wanpeng Li (6):
>>   introduce new sysctl knob which control gigantic page pools shrinking
>>   update_and_free_page gigantic pages awareness
>>   enable gigantic hugetlb page pools shrinking
>>   use already exist huge_page_order() instead of h->order
>>   remove redundant hugetlb_prefault 
>>   use already exist interface huge_page_shift
>> 
>>  Documentation/sysctl/vm.txt |   13 +++++++
>>  include/linux/hugetlb.h     |    5 +--
>>  kernel/sysctl.c             |    7 ++++
>>  mm/hugetlb.c                |   83 +++++++++++++++++++++++++++++--------------
>>  mm/internal.h               |    1 +
>>  mm/page_alloc.c             |    2 +-
>>  6 files changed, 82 insertions(+), 29 deletions(-)
>> 
>> -- 
>> 1.7.10.4
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
