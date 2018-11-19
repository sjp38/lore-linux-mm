Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 363C06B1B71
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 12:01:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so2523819ede.19
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 09:01:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6-v6si5066685edl.383.2018.11.19.09.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 09:01:07 -0800 (PST)
Date: Mon, 19 Nov 2018 18:01:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181119170105.GT22247@dhcp22.suse.cz>
References: <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <eb979e1e-e0fc-b1a3-b6cc-70b503a74a20@suse.cz>
 <20181119164618.GQ22247@dhcp22.suse.cz>
 <c7c20cc5-c2a4-ce61-3d97-56c8acfb13ec@suse.cz>
 <6017b36f-3e29-c2ad-f2d1-2ebd77bbaef1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6017b36f-3e29-c2ad-f2d1-2ebd77bbaef1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Mon 19-11-18 17:48:35, Vlastimil Babka wrote:
> On 11/19/18 5:46 PM, Vlastimil Babka wrote:
> > On 11/19/18 5:46 PM, Michal Hocko wrote:
> >> On Mon 19-11-18 17:36:21, Vlastimil Babka wrote:
> >>>
> >>> So what protects us from locking a page whose refcount dropped to zero?
> >>> and is being freed? The checks in freeing path won't be happy about a
> >>> stray lock.
> >>
> >> Nothing really prevents that. But does it matter. The worst that might
> >> happen is that we lock a freed or reused page. Who would complain?
> > 
> > free_pages_check() for example
> > 
> > PAGE_FLAGS_CHECK_AT_FREE includes PG_locked

Right you are.

> And besides... what about the last page being offlined and then the
> whole struct page's part of vmemmap destroyed as the node goes away?

Yeah, that is quite unlikely though because the there is quite a large
time window between the two events. I am not entirely sure we are safe
right now TBH. Any access to the struct page after the put_page is
unsafe theoretically.

Then we have to come up with something more clever I am afraid.

-- 
Michal Hocko
SUSE Labs
