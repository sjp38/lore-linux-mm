Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 461CF6B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:30:50 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h9-v6so19419717qti.19
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:30:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 45si2800058qvx.28.2018.04.26.08.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 08:30:48 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
 <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
 <20180416140810.GR17484@dhcp22.suse.cz>
 <d39f5b5d-db9b-0729-e68b-b15c314ddd13@redhat.com>
 <20180419073323.GO17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <493367d5-efbc-d9d6-3f32-3cd7e9a2b222@redhat.com>
Date: Thu, 26 Apr 2018 17:30:47 +0200
MIME-Version: 1.0
In-Reply-To: <20180419073323.GO17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 19.04.2018 09:33, Michal Hocko wrote:
> On Wed 18-04-18 17:46:25, David Hildenbrand wrote:
> [...]
>> BTW I was able to easily produce the case where do_migrate_range() would
>> loop for ever (well at least for multiple minutes, but I assume this
>> would have went on :) )
> 
> I am definitely interested to hear details.
> 

migrate_pages() seems to be returning > 0 all the time. Seems to come
from too many -EAGAIN from unmap_and_move().

This in return (did not go further down that road) can be as simple as
trylock_page() failing.

Of course, we could have other permanent errors here (-ENOMEM).
__offline_pages() ignores all errors coming from do_migrate_range(). So
in theory, this can take forever - at least not what I want for my use
case. I want it to fail fast. "if this block cannot be offlined, try
another one".

I wonder if it is the right thing to do in __offline_pages() to ignore
even permanent errors. Anyhow, I think I'll need some way of telling
offline_pages "please don't retry forever".

-- 

Thanks,

David / dhildenb
