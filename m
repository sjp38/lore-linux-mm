Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2B56A6B0035
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 03:04:34 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so9364588pbb.19
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 00:04:33 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id t7si10616735pab.39.2014.04.01.00.04.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 00:04:32 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F26133EE1DB
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:04:30 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E30C145DE54
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:04:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2BC945DE63
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:04:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AC58E1DB804C
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:04:30 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57AF6E08004
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:04:30 +0900 (JST)
Message-ID: <533A649B.5020109@jp.fujitsu.com>
Date: Tue, 1 Apr 2014 16:02:51 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: hugetlb: fix softlockup when a large number of hugepages
 are freed.
References: <533946D4.1060305@jp.fujitsu.com> <20140331123028.113f3e263daa1b9e749a1678@linux-foundation.org>
In-Reply-To: <20140331123028.113f3e263daa1b9e749a1678@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 31 Mar 2014 12:30:28 -0700 Andrew Morton wrote:
> On Mon, 31 Mar 2014 19:43:32 +0900 "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com> wrote:
>
>> Hi,
>>
>> When I decrease the value of nr_hugepage in procfs a lot, softlockup happens.
>> It is because there is no chance of context switch during this process.
>>
>> On the other hand, when I allocate a large number of hugepages,
>> there is some chance of context switch. Hence softlockup doesn't happen
>> during this process. So it's necessary to add the context switch
>> in the freeing process as same as allocating process to avoid softlockup.
>>
>> ...
>>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1535,6 +1535,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>>   	while (min_count < persistent_huge_pages(h)) {
>>   		if (!free_pool_huge_page(h, nodes_allowed, 0))
>>   			break;
>> +		cond_resched_lock(&hugetlb_lock);
>>   	}
>>   	while (count < persistent_huge_pages(h)) {
>>   		if (!adjust_pool_surplus(h, nodes_allowed, 1))
>
> Are you sure we don't need a cond_resched_lock() in this second loop as
> well?

We don't need a cond_resched_lock() in the second loop. Because,
the long scheduling stalls is occured by freeing hugepage at
free_pool_huge_page() and the freeing is heavy.
adjust_pool_surplus(), which is called at the second loop, is not
heavy, I believe.

>
> Let's bear in mind the objective here: it is to avoid long scheduling
> stalls, not to prevent softlockup-detector warnings.  A piece of code
> which doesn't trip the lockup detector can still be a problem.

I see, thank you!

Thanks,
Masayoshi Mizuma
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
