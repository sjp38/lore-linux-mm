Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42C1C6B0006
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:46:27 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id e21so1374904qkm.1
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 08:46:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h185si1827907qkd.101.2018.04.18.08.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 08:46:26 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
 <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
 <20180416140810.GR17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d39f5b5d-db9b-0729-e68b-b15c314ddd13@redhat.com>
Date: Wed, 18 Apr 2018 17:46:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180416140810.GR17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org


>>>> - Once all 4MB chunks of a memory block are offline, we can remove the
>>>>   memory block and therefore the struct pages (seems to work in my prototype),
>>>>   which is nice.
>>>
>>> OK, so our existing ballooning solutions indeed do not free up memmaps
>>> which is suboptimal.
>>
>> And we would have to hack deep into the current offlining code to make
>> it work (at least that's my understanding).
>>
>>>
>>>> Todo:
>>>> - We might have to add a parameter to offline_pages(), telling it to not
>>>>   try forever but abort in case it takes too long.
>>>
>>> Offlining fails when it see non-migrateable pages but other than that it
>>> should always succeed in the finite time. If not then there is a bug to
>>> be fixed.
>>
>> I just found the -EINTR in the offlining code and thought this might be
>> problematic. (e.g. if somebody pins a page that is still to be migrated
>> - or is that avoided by isolating?) I haven't managed to trigger this
>> scenario yet. Was just a thought, that's why I mentioned it but didn't
>> implement it.
> 
> Offlining is a 3 stage thing. Check for unmovable pages and fail with
> EBUSY, isolating free memory and migrating the rest. If the first 2
> succeed we expect the migration will finish in a finite time. 


BTW I was able to easily produce the case where do_migrate_range() would
loop for ever (well at least for multiple minutes, but I assume this
would have went on :) )


-- 

Thanks,

David / dhildenb
