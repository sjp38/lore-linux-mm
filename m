Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA7276B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 02:24:35 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l8-v6so6383608qtb.11
        for <linux-mm@kvack.org>; Sun, 29 Apr 2018 23:24:35 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a94si1212771qkh.179.2018.04.29.23.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Apr 2018 23:24:34 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
 <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
 <20180416140810.GR17484@dhcp22.suse.cz>
 <d39f5b5d-db9b-0729-e68b-b15c314ddd13@redhat.com>
 <20180419073323.GO17484@dhcp22.suse.cz>
 <493367d5-efbc-d9d6-3f32-3cd7e9a2b222@redhat.com>
 <20180429210523.GA26305@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <e980bd68-8864-65e3-0dcd-6c5739cd5e4f@redhat.com>
Date: Mon, 30 Apr 2018 08:24:31 +0200
MIME-Version: 1.0
In-Reply-To: <20180429210523.GA26305@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 29.04.2018 23:05, Michal Hocko wrote:
> On Thu 26-04-18 17:30:47, David Hildenbrand wrote:
>> On 19.04.2018 09:33, Michal Hocko wrote:
>>> On Wed 18-04-18 17:46:25, David Hildenbrand wrote:
>>> [...]
>>>> BTW I was able to easily produce the case where do_migrate_range() would
>>>> loop for ever (well at least for multiple minutes, but I assume this
>>>> would have went on :) )
>>>
>>> I am definitely interested to hear details.
>>>
>>
>> migrate_pages() seems to be returning > 0 all the time. Seems to come
>> from too many -EAGAIN from unmap_and_move().
>>
>> This in return (did not go further down that road) can be as simple as
>> trylock_page() failing.
> 
> Yes but we assume that nobody holds the lock for ever so sooner or later
> we should be able to get the lock.
> 
>> Of course, we could have other permanent errors here (-ENOMEM).
>> __offline_pages() ignores all errors coming from do_migrate_range(). So
>> in theory, this can take forever - at least not what I want for my use
>> case. I want it to fail fast. "if this block cannot be offlined, try
>> another one".
>>
>> I wonder if it is the right thing to do in __offline_pages() to ignore
>> even permanent errors. Anyhow, I think I'll need some way of telling
>> offline_pages "please don't retry forever".
> 
> Well, it would be really great to find a way to distinguish permanent
> errors from temporary ones. But I am not sure this is very easy. Anyway,
> we should be only looking at migratable pages at this stage of the
> offline so the migration should eventually succeed. We have a bug if
> this is not a case and we should address it. Find the page which fails
> to migrate and see who keeps us from migrating it. This might be a page
> pin abuser or something else. That is why I've said I am interested in
> details.
> 

Yes, I am definitely planning to look into the details (because for my
work it implies needlessly trying to offline pages, which is overhead).
For now I think - even having that sorted out - that I'll need a way to
tell offline_pages() to fail fast (as you mentioned: distinguishing
permanent from temporary errors might not be easy).

offline_pages() is historically only triggered by the user, who can
simply decide to stop (-EINTR) if it takes to long.

Let's discuss with the next RFC.

-- 

Thanks,

David / dhildenb
