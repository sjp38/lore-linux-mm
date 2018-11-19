Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E35EE6B1B69
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:51:29 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x98-v6so15980569ede.0
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:51:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a22-v6si2764261eje.78.2018.11.19.08.51.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:51:28 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
From: Vlastimil Babka <vbabka@suse.cz>
References: <20181115131927.GT23831@dhcp22.suse.cz>
 <20181115133840.GR2653@MiWiFi-R3L-srv>
 <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <eb979e1e-e0fc-b1a3-b6cc-70b503a74a20@suse.cz>
 <20181119164618.GQ22247@dhcp22.suse.cz>
 <c7c20cc5-c2a4-ce61-3d97-56c8acfb13ec@suse.cz>
Message-ID: <6017b36f-3e29-c2ad-f2d1-2ebd77bbaef1@suse.cz>
Date: Mon, 19 Nov 2018 17:48:35 +0100
MIME-Version: 1.0
In-Reply-To: <c7c20cc5-c2a4-ce61-3d97-56c8acfb13ec@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 11/19/18 5:46 PM, Vlastimil Babka wrote:
> On 11/19/18 5:46 PM, Michal Hocko wrote:
>> On Mon 19-11-18 17:36:21, Vlastimil Babka wrote:
>>>
>>> So what protects us from locking a page whose refcount dropped to zero?
>>> and is being freed? The checks in freeing path won't be happy about a
>>> stray lock.
>>
>> Nothing really prevents that. But does it matter. The worst that might
>> happen is that we lock a freed or reused page. Who would complain?
> 
> free_pages_check() for example
> 
> PAGE_FLAGS_CHECK_AT_FREE includes PG_locked

And besides... what about the last page being offlined and then the
whole struct page's part of vmemmap destroyed as the node goes away?
