Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDC4D6B03BF
	for <linux-mm@kvack.org>; Mon,  8 May 2017 06:42:44 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t26so21536525qtg.12
        for <linux-mm@kvack.org>; Mon, 08 May 2017 03:42:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k3si12193793qkf.75.2017.05.08.03.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 03:42:44 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v48Ae0m8005077
	for <linux-mm@kvack.org>; Mon, 8 May 2017 06:42:43 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aab4u58tv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 08 May 2017 06:42:43 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 8 May 2017 11:42:39 +0100
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz> <87pofxk20k.fsf@firstfloor.org>
 <20170428060755.GA8143@dhcp22.suse.cz> <20170428073136.GE8143@dhcp22.suse.cz>
 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
 <20170428134831.GB26705@dhcp22.suse.cz>
 <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
 <20170502185507.GB19165@dhcp22.suse.cz> <1493860869.8082.1.camel@gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 8 May 2017 12:42:28 +0200
MIME-Version: 1.0
In-Reply-To: <1493860869.8082.1.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <03a7ec34-106e-3eb6-0b05-f77a40a2d6b9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Vladimir Davydov <vdavydov.dev@gmail.com>

On 04/05/2017 03:21, Balbir Singh wrote:
>> @@ -5527,7 +5527,7 @@ static void uncharge_list(struct list_head *page_list)
>>  		next = page->lru.next;
>>  
>>  		VM_BUG_ON_PAGE(PageLRU(page), page);
>> -		VM_BUG_ON_PAGE(page_count(page), page);
>> +		VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
>>  
>>  		if (!page->mem_cgroup)
>>  			continue;
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 8a6bd3a9eb1e..4497d9619bb4 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -541,6 +541,13 @@ static int delete_from_lru_cache(struct page *p)
>>  		 */
>>  		ClearPageActive(p);
>>  		ClearPageUnevictable(p);
>> +
>> +		/*
>> +		 * Poisoned page might never drop its ref count to 0 so we have to
>> +		 * uncharge it manually from its memcg.
>> +		 */
>> +		mem_cgroup_uncharge(p);
>> +
> 
> Yep, that is the right fix
> 
> https://lkml.org/lkml/2017/4/26/133

Sorry Balbir,

You pointed this out since the beginning but I missed your comment.
My mistake.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
