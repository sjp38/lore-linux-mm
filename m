From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hugetlb: fix total hugetlbfs pages count when memory
 overcommit accouting
Date: Thu, 14 Mar 2013 18:15:58 +0800
Message-ID: <5163.06542926959$1363256197@news.gmane.org>
References: <1363158511-21272-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130314094419.GA11631@dhcp22.suse.cz>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UG5D6-00057j-JW
	for glkm-linux-mm-2@m.gmane.org; Thu, 14 Mar 2013 11:16:32 +0100
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id C69B46B004D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 06:16:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 15:43:01 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 0B71DE004E
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 15:47:23 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2EAFwhT21233896
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 15:45:58 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EAG08h011511
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:16:00 +1100
Content-Disposition: inline
In-Reply-To: <20130314094419.GA11631@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, Mar 14, 2013 at 10:44:19AM +0100, Michal Hocko wrote:
>On Wed 13-03-13 15:08:31, Wanpeng Li wrote:
>> After commit 42d7395f ("mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB")
>> be merged, kernel permit multiple huge page sizes,
>

Hi Michal,

>multiple huge page sizes were possible long before this commit. The
>above mentioned patch just made their usage via IPC much easier. You
>could do the same previously (since a137e1cc) by mounting hugetlbfs with
>a specific page size as a parameter and using mmap.
>

Agreed.

>> and when the system administrator has configured the system to provide
>> huge page pools of different sizes, application can choose the page
>> size used for their allocation.
>
>> However, just default size of huge page pool is statistical when
>> memory overcommit accouting, the bad is that this will result in
>> innocent processes be killed by oom-killer later.
>
>Why would an innnocent process be killed? The overcommit calculation
>is incorrect, that is true, but this just means that an unexpected
>ENOMEM/EFAULT or SIGSEGV would be returned, no? How an OOM could be a
>result?

Agreed.

>
>> Fix it by statistic all huge page pools of different sizes provided by
>> administrator.
>
>The patch makes sense but the description is misleading AFAICS.
>

Thanks for your pointing out Michal, I will update the description. :-)

Regards,
Wanpeng Li 

>> Testcase:
>> boot: hugepagesz=1G hugepages=1
>> before patch:
>> egrep 'CommitLimit' /proc/meminfo
>> CommitLimit:     55434168 kB
>> after patch:
>> egrep 'CommitLimit' /proc/meminfo
>> CommitLimit:     54909880 kB
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/hugetlb.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index cdb64e4..9e25040 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2124,8 +2124,11 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
>>  /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
>>  unsigned long hugetlb_total_pages(void)
>>  {
>> -	struct hstate *h = &default_hstate;
>> -	return h->nr_huge_pages * pages_per_huge_page(h);
>> +	struct hstate *h;
>> +	unsigned long nr_total_pages = 0;
>> +	for_each_hstate(h)
>> +		nr_total_pages += h->nr_huge_pages * pages_per_huge_page(h);
>> +	return nr_total_pages;
>>  }
>>  
>>  static int hugetlb_acct_memory(struct hstate *h, long delta)
>> -- 
>> 1.7.11.7
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
