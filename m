From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hugetlb: fix total hugetlbfs pages count when memory
 overcommit accouting
Date: Wed, 13 Mar 2013 16:32:47 +0800
Message-ID: <47170.273846905$1363163620@news.gmane.org>
References: <1363158511-21272-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <CAJd=RBBVU8uvHZ3AHkBqOWe-hEqFQ5-5Mf5dGXYuGczvM6EpUw@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UFh7u-0002Gh-5E
	for glkm-linux-mm-2@m.gmane.org; Wed, 13 Mar 2013 09:33:34 +0100
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 4E42A6B0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 04:33:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 13:59:32 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id CE2D9394004F
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 14:02:50 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2D8WkIr31654130
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 14:02:46 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2D8WoFF027332
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 19:32:50 +1100
Content-Disposition: inline
In-Reply-To: <CAJd=RBBVU8uvHZ3AHkBqOWe-hEqFQ5-5Mf5dGXYuGczvM6EpUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>, Andi Kleen <ak@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 13, 2013 at 04:02:03PM +0800, Hillf Danton wrote:
>[cc Andi]
>On Wed, Mar 13, 2013 at 3:08 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> After commit 42d7395f ("mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB")
>> be merged, kernel permit multiple huge page sizes, and when the system administrator
>> has configured the system to provide huge page pools of different sizes, application
>> can choose the page size used for their allocation. However, just default size of
>> huge page pool is statistical when memory overcommit accouting, the bad is that this
>> will result in innocent processes be killed by oom-killer later. Fix it by statistic
>> all huge page pools of different sizes provided by administrator.
>>

Hi Hillf,

>Can we enrich the output of hugetlb_report_meminfo() ?
>

Yes, I have already thought of this stuff, we can dump multiple huge page
pools information in /proc/meminfo and /sys/devices/system/node/node*/meminfo.
I can do it in another patch, what's your opinion, Andi?

Regards,
Wanpeng Li 

>thanks
>Hillf
>
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
>> -       struct hstate *h = &default_hstate;
>> -       return h->nr_huge_pages * pages_per_huge_page(h);
>> +       struct hstate *h;
>> +       unsigned long nr_total_pages = 0;
>> +       for_each_hstate(h)
>> +               nr_total_pages += h->nr_huge_pages * pages_per_huge_page(h);
>> +       return nr_total_pages;
>>  }
>>
>>  static int hugetlb_acct_memory(struct hstate *h, long delta)
>> --
>> 1.7.11.7
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
