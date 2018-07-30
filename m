Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89C926B0269
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:03:33 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i8-v6so11208640qke.7
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:03:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n51-v6si8870308qvn.276.2018.07.30.08.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 08:03:32 -0700 (PDT)
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
References: <20180727165454.27292-1-david@redhat.com>
 <20180730113029.GM24267@dhcp22.suse.cz>
 <6cc416e7-522c-a67e-2706-f37aadff084f@redhat.com>
 <20180730120529.GN24267@dhcp22.suse.cz>
 <7b58af7b-5187-2c76-b458-b0f49875a1fc@redhat.com>
 <CAGM2reahiWj5LFq1npRpwK2k-4K-L9hr3AHUV9uYcmT2s3Bnuw@mail.gmail.com>
 <56e97799-fbe1-9546-46ab-a9b8ee8794e0@redhat.com>
 <20180730141058.GV24267@dhcp22.suse.cz>
 <80641d1a-72fe-26b2-7927-98fcac5e5d71@redhat.com>
 <20180730145035.GY24267@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <0be90c23-e5a0-2628-c671-9923d8e45b0a@redhat.com>
Date: Mon, 30 Jul 2018 17:03:27 +0200
MIME-Version: 1.0
In-Reply-To: <20180730145035.GY24267@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, gregkh@linuxfoundation.org, mingo@kernel.org, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, jack@suse.cz, mawilcox@microsoft.com, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, osalvador@techadventures.net, yasu.isimatu@gmail.com, malat@debian.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com

On 30.07.2018 16:50, Michal Hocko wrote:
> On Mon 30-07-18 16:42:27, David Hildenbrand wrote:
>> On 30.07.2018 16:10, Michal Hocko wrote:
>>> On Mon 30-07-18 15:51:45, David Hildenbrand wrote:
>>>> On 30.07.2018 15:30, Pavel Tatashin wrote:
>>> [...]
>>>>> Hi David,
>>>>>
>>>>> Have you figured out why we access struct pages during hot-unplug for
>>>>> offlined memory? Also, a panic trace would be useful in the patch.
>>>>
>>>> __remove_pages() needs a zone as of now (e.g. to recalculate if the zone
>>>> is contiguous). This zone is taken from the first page of memory to be
>>>> removed. If the struct pages are uninitialized that value is random and
>>>> we might even get an invalid zone.
>>>>
>>>> The zone is also used to locate pgdat.
>>>>
>>>> No stack trace available so far, I'm just reading the code and try to
>>>> understand how this whole memory hotplug/unplug machinery works.
>>>
>>> Yes this is a mess (evolution of the code called otherwise ;) [1].
>>
>> So I guess I should not feel bad if I am having problems understanding
>> all the details? ;)
>>
>>> Functionality has been just added on top of not very well thought
>>> through bases. This is a nice example of it. We are trying to get a zone
>>> to 1) special case zone_device 2) recalculate zone state. The first
>>> shouldn't be really needed because we should simply rely on altmap.
>>> Whether it is used for zone device or not. 2) shouldn't be really needed
>>> if the section is offline and we can check that trivially.
>>>
>>
>> About 2, I am not sure if this is the case and that easy. To me it looks
>> more like remove_pages() fixes up things that should be done in
>> offline_pages(). Especially, if the same memory was onlined/offlined to
>> different zones we might be in trouble (looking at code on a very high
>> level view).
> 
> Well, this might be possible. Hotplug remove path was on my todo list
> for a long time. I didn't get that far TBH. shrink_zone_span begs for
> some attention.
> 

So i guess we agree that the right fix for this is to not touch struct
pages when removing memory, correct?

-- 

Thanks,

David / dhildenb
