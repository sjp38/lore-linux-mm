Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3EFC6B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:57:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z36so26716232wrb.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:57:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x124si10931499wmx.38.2017.07.27.04.57.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 04:57:48 -0700 (PDT)
Subject: Re: gigantic hugepages vs. movable zones
References: <20170726105004.GI2981@dhcp22.suse.cz>
 <87inie1uwf.fsf@linux.vnet.ibm.com> <20170727072857.GI20970@dhcp22.suse.cz>
 <1529e986-5f28-35dd-c82e-a4b5801b4afd@linux.vnet.ibm.com>
 <20170727081236.GK20970@dhcp22.suse.cz>
 <20170727082258.GL20970@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fe817e86-c756-653f-1cd8-e7c8cf6779ee@suse.cz>
Date: Thu, 27 Jul 2017 13:56:54 +0200
MIME-Version: 1.0
In-Reply-To: <20170727082258.GL20970@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/27/2017 10:22 AM, Michal Hocko wrote:
> [CC for real]
> 
> On Thu 27-07-17 10:12:36, Michal Hocko wrote:
>> On Thu 27-07-17 13:30:31, Aneesh Kumar K.V wrote:
>>>
>>>
>>> On 07/27/2017 12:58 PM, Michal Hocko wrote:
>>>> On Thu 27-07-17 07:52:08, Aneesh Kumar K.V wrote:
>>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>>
>>>>>> Hi,
>>>>>> I've just noticed that alloc_gigantic_page ignores movability of the
>>>>>> gigantic page and it uses any existing zone. Considering that
>>>>>> hugepage_migration_supported only supports 2MB and pgd level hugepages
>>>>>> then 1GB pages are not migratable and as such allocating them from a
>>>>>> movable zone will break the basic expectation of this zone. Standard
>>>>>> hugetlb allocations try to avoid that by using htlb_alloc_mask and I
>>>>>> believe we should do the same for gigantic pages as well.
>>>>>>
>>>>>> I suspect this behavior is not intentional. What do you think about the
>>>>>> following untested patch?
>>>>>
>>>>>
>>>>> I also noticed an unrelated issue with the usage of
>>>>> start_isolate_page_range. On error we set the migrate type to
>>>>> MIGRATE_MOVABLE.
>>>>
>>>> Why that should be a problem? I think it is perfectly OK to have
>>>> MIGRATE_MOVABLE pageblocks inside kernel zones.
>>>>
>>>
>>> we can pick pages with migrate type movable and if we fail to isolate won't

                                        ^ CMA

>>> we set the migrate type of that pages to MOVABLE ?

Yes, it seems we can silently kill CMA pageblocks in such case. Joonsoo,
can you check?

>>
>> I do not see an immediate problem. GFP_KERNEL allocations can fallback
>> to movable migrate pageblocks AFAIR. But I am not very much familiar
>> with migratetypes. Vlastimil, could you have a look please?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
