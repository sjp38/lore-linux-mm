Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C27AF8E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:26:42 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so580232pls.21
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 22:26:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n19si18250861pgd.271.2018.12.19.22.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 22:26:41 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBK6ORd2050001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:26:41 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pg1g0tmgr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:26:40 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 20 Dec 2018 06:26:39 -0000
Subject: Re: [PATCH V5 1/3] mm: Add get_user_pages_cma_migrate
References: <20181219034047.16305-1-aneesh.kumar@linux.ibm.com>
 <20181219034047.16305-2-aneesh.kumar@linux.ibm.com>
 <e9c9b68a-a31b-ab59-902a-73401a89f72a@ozlabs.ru>
 <b316eb1c-36dc-49e0-f46f-e610f29b6058@linux.ibm.com>
 <23cae5a6-4370-224c-523c-ab6ee940cf87@ozlabs.ru>
 <ba05bde5-5ef9-6e96-b15c-cebb9631a84b@linux.ibm.com>
 <406cbd85-c64e-428f-772d-7afb23eb92ec@ozlabs.ru>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 20 Dec 2018 11:56:31 +0530
MIME-Version: 1.0
In-Reply-To: <406cbd85-c64e-428f-772d-7afb23eb92ec@ozlabs.ru>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <ba73bd95-4372-e527-9159-1de95b05d08c@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 12/20/18 11:50 AM, Alexey Kardashevskiy wrote:
> 
> 
> On 20/12/2018 16:52, Aneesh Kumar K.V wrote:
>> On 12/20/18 11:18 AM, Alexey Kardashevskiy wrote:
>>>
>>>
>>> On 20/12/2018 16:22, Aneesh Kumar K.V wrote:
>>>> On 12/20/18 9:49 AM, Alexey Kardashevskiy wrote:
>>>>>
>>>>>
>>>>> On 19/12/2018 14:40, Aneesh Kumar K.V wrote:
>>>>>> This helper does a get_user_pages_fast and if it find pages in the
>>>>>> CMA area
>>>>>> it will try to migrate them before taking page reference. This makes
>>>>>> sure that
>>>>>> we don't keep non-movable pages (due to page reference count) in the
>>>>>> CMA area.
>>>>>> Not able to move pages out of CMA area result in CMA allocation
>>>>>> failures.
>>>>>>
>>>>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>>>>
>>>>
>>>> .....
>>>>>> +         * We did migrate all the pages, Try to get the page
>>>>>> references again
>>>>>> +         * migrating any new CMA pages which we failed to isolate
>>>>>> earlier.
>>>>>> +         */
>>>>>> +        drain_allow = true;
>>>>>> +        goto get_user_again;
>>>>>
>>>>>
>>>>> So it is possible to have pages pinned, then successfully migrated
>>>>> (migrate_pages() returned 0), then pinned again, then some pages may
>>>>> end
>>>>> up in CMA again and migrate again and nothing seems to prevent this
>>>>> loop
>>>>> from being endless. What do I miss?
>>>>>
>>>>
>>>> pages used as target page for migration won't be allocated from CMA
>>>> region.
>>>
>>>
>>> Then migrate_allow should be set to "false" regardless what
>>> migrate_pages() returned and then I am totally missing the point of this
>>> goto and going through the loop again even when we know for sure it
>>> won't do literally anything but checking is_migrate_cma_page() even
>>> though we know pages won't be allocated from CMA.
>>>
>>
>> Because we might have failed to isolate all the pages in the first attempt.
> 
> isolate==migrate?

no

The call to isolate_lru_page and isolate_huge_page. We can fail because 
the percpu pagevec is not fully drained


-aneesh
