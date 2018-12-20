Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE7B88E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:20:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s71so702839pfi.22
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 22:20:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor33825076pfj.17.2018.12.19.22.20.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 22:20:23 -0800 (PST)
Subject: Re: [PATCH V5 1/3] mm: Add get_user_pages_cma_migrate
References: <20181219034047.16305-1-aneesh.kumar@linux.ibm.com>
 <20181219034047.16305-2-aneesh.kumar@linux.ibm.com>
 <e9c9b68a-a31b-ab59-902a-73401a89f72a@ozlabs.ru>
 <b316eb1c-36dc-49e0-f46f-e610f29b6058@linux.ibm.com>
 <23cae5a6-4370-224c-523c-ab6ee940cf87@ozlabs.ru>
 <ba05bde5-5ef9-6e96-b15c-cebb9631a84b@linux.ibm.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Message-ID: <406cbd85-c64e-428f-772d-7afb23eb92ec@ozlabs.ru>
Date: Thu, 20 Dec 2018 17:20:15 +1100
MIME-Version: 1.0
In-Reply-To: <ba05bde5-5ef9-6e96-b15c-cebb9631a84b@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org



On 20/12/2018 16:52, Aneesh Kumar K.V wrote:
> On 12/20/18 11:18 AM, Alexey Kardashevskiy wrote:
>>
>>
>> On 20/12/2018 16:22, Aneesh Kumar K.V wrote:
>>> On 12/20/18 9:49 AM, Alexey Kardashevskiy wrote:
>>>>
>>>>
>>>> On 19/12/2018 14:40, Aneesh Kumar K.V wrote:
>>>>> This helper does a get_user_pages_fast and if it find pages in the
>>>>> CMA area
>>>>> it will try to migrate them before taking page reference. This makes
>>>>> sure that
>>>>> we don't keep non-movable pages (due to page reference count) in the
>>>>> CMA area.
>>>>> Not able to move pages out of CMA area result in CMA allocation
>>>>> failures.
>>>>>
>>>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>>>
>>>
>>> .....
>>>>> +         * We did migrate all the pages, Try to get the page
>>>>> references again
>>>>> +         * migrating any new CMA pages which we failed to isolate
>>>>> earlier.
>>>>> +         */
>>>>> +        drain_allow = true;
>>>>> +        goto get_user_again;
>>>>
>>>>
>>>> So it is possible to have pages pinned, then successfully migrated
>>>> (migrate_pages() returned 0), then pinned again, then some pages may
>>>> end
>>>> up in CMA again and migrate again and nothing seems to prevent this
>>>> loop
>>>> from being endless. What do I miss?
>>>>
>>>
>>> pages used as target page for migration won't be allocated from CMA
>>> region.
>>
>>
>> Then migrate_allow should be set to "false" regardless what
>> migrate_pages() returned and then I am totally missing the point of this
>> goto and going through the loop again even when we know for sure it
>> won't do literally anything but checking is_migrate_cma_page() even
>> though we know pages won't be allocated from CMA.
>>
> 
> Because we might have failed to isolate all the pages in the first attempt.

isolate==migrate?

If we failed to migrate, then migrate_pages() returns non zero (positive
or negative), we set migrate_allow to false, empty the cma_page_list
and repeat but we won't add anything to cma_page_list as
migrate_allow==false.

If we succeeded to migrate, then we repeat the loop with
migrate_allow==true but it does not matter as is_migrate_cma_page() is
expected to return false because we just successfully migrated
_everything_ so we won't be adding anything to cma_page_list either.

What have I missed?

-- 
Alexey
