From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm/hugetlb: fix total hugetlbfs pages count when
 memory overcommit accouting
Date: Thu, 14 Mar 2013 19:24:11 +0800
Message-ID: <30897.5976695821$1363260288@news.gmane.org>
References: <1363258189-24945-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130314110927.GC11631@dhcp22.suse.cz>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UG6H7-0005rs-KJ
	for glkm-linux-mm-2@m.gmane.org; Thu, 14 Mar 2013 12:24:45 +0100
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 924C86B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 07:24:20 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 16:51:44 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2EAD71258023
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 16:55:18 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2EBOBxP34996342
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 16:54:11 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EBODa0016812
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:24:13 +1100
Content-Disposition: inline
In-Reply-To: <20130314110927.GC11631@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 14, 2013 at 12:09:27PM +0100, Michal Hocko wrote:
>On Thu 14-03-13 18:49:49, Wanpeng Li wrote:
>> Changelog:
>>  v1 -> v2:
>>   * update patch description, spotted by Michal
>> 
>> hugetlb_total_pages() does not account for all the supported hugepage
>> sizes.
>
>> This can lead to incorrect calculation of the total number of
>> page frames used by hugetlb. This patch corrects the issue.
>

Hi Michal,

>Sorry to be so picky but this doesn't tell us much. Why do we need to
>have the total number of hugetlb pages?
>
>What about the following:
>"hugetlb_total_pages is used for overcommit calculations but the
>current implementation considers only default hugetlb page size (which
>is either the first defined hugepage size or the one specified by
>default_hugepagesz kernel boot parameter).
>
>If the system is configured for more than one hugepage size (which is
>possible since a137e1cc hugetlbfs: per mount huge page sizes) then
>the overcommit estimation done by __vm_enough_memory (resp. shown by
>meminfo_proc_show) is not precise - there is an impression of more
>available/allowed memory. This can lead to an unexpected ENOMEM/EFAULT
>resp. SIGSEGV when memory is accounted."
>

Fair enough, thanks. :-)

>I think this is also worth pushing to the stable tree (it goes back to
>2.6.27)
>

Yup, I will Cc Greg in next version. 

>> Testcase:
>> boot: hugepagesz=1G hugepages=1
>> before patch:
>> egrep 'CommitLimit' /proc/meminfo
>> CommitLimit:     55434168 kB
>> after patch:
>> egrep 'CommitLimit' /proc/meminfo
>> CommitLimit:     54909880 kB
>
>This gives some more confusion to a reader because there is only
>something like 500M difference here without any explanation.
>

the default overcommit ratio is 50.

Regards,
Wanpeng Li 

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
