Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BDCF26B0033
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 23:20:08 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 19 Jul 2013 08:44:27 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 960661258051
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 08:49:24 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6J3JxDC22478852
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 08:49:59 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6J3K2cg023418
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 13:20:03 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: hugepage related lockdep trace.
In-Reply-To: <CAJd=RBA0UDCJGE5ua7m44hOQp5g9EQdkeC00iWSEDkmLhc0rDw@mail.gmail.com>
References: <20130717153223.GD27731@redhat.com> <20130718000901.GA31972@blaptop> <87hafrdatb.fsf@linux.vnet.ibm.com> <CAJd=RBA0UDCJGE5ua7m44hOQp5g9EQdkeC00iWSEDkmLhc0rDw@mail.gmail.com>
Date: Fri, 19 Jul 2013 08:50:02 +0530
Message-ID: <87d2qfck2l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Hillf Danton <dhillf@gmail.com> writes:

> On Fri, Jul 19, 2013 at 1:42 AM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>>> IMHO, it's a false positive because i_mmap_mutex was held by kswapd
>>> while one in the middle of fault path could be never on kswapd context.
>>>
>>> It seems lockdep for reclaim-over-fs isn't enough smart to identify
>>> between background and direct reclaim.
>>>
>>> Wait for other's opinion.
>>
>> Is that reasoning correct ?. We may not deadlock because hugetlb pages
>> cannot be reclaimed. So the fault path in hugetlb won't end up
>> reclaiming pages from same inode. But the report is correct right ?
>>
>>
>> Looking at the hugetlb code we have in huge_pmd_share
>>
>> out:
>>         pte = (pte_t *)pmd_alloc(mm, pud, addr);
>>         mutex_unlock(&mapping->i_mmap_mutex);
>>         return pte;
>>
>> I guess we should move that pmd_alloc outside i_mmap_mutex. Otherwise
>> that pmd_alloc can result in a reclaim which can call shrink_page_list ?
>>
> Hm, can huge pages be reclaimed, say by kswapd currently?

No we don't reclaim hugetlb pages.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
