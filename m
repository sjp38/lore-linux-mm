Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 960478E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:23:07 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q33so20171238qte.23
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 05:23:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k124si2170684qkd.2.2019.01.28.05.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 05:23:06 -0800 (PST)
Subject: Re: [PATCH RFC] mm: migrate: don't rely on PageMovable() of newpage
 after unlocking it
References: <20190128121609.9528-1-david@redhat.com>
 <20190128130709.GJ18811@dhcp22.suse.cz>
 <b03cae19-d02a-0ba2-69a1-010ee76748e7@redhat.com>
 <20190128132146.GK18811@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <17e7d7e4-f4ca-a681-93e5-92a0c285be14@redhat.com>
Date: Mon, 28 Jan 2019 14:22:52 +0100
MIME-Version: 1.0
In-Reply-To: <20190128132146.GK18811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>, Rafael Aquini <aquini@redhat.com>

On 28.01.19 14:21, Michal Hocko wrote:
> On Mon 28-01-19 14:14:28, David Hildenbrand wrote:
>> On 28.01.19 14:07, Michal Hocko wrote:
>>> On Mon 28-01-19 13:16:09, David Hildenbrand wrote:
>>> [...]
>>>> My theory:
>>>>
>>>> In __unmap_and_move(), we lock the old and newpage and perform the
>>>> migration. In case of vitio-balloon, the new page will become
>>>> movable, the old page will no longer be movable.
>>>>
>>>> However, after unlocking newpage, I think there is nothing stopping
>>>> the newpage from getting dequeued and freed by virtio-balloon. This
>>>> will result in the newpage
>>>> 1. No longer having PageMovable()
>>>> 2. Getting moved to the local list before finally freeing it (using
>>>>    page->lru)
>>>
>>> Does that mean that the virtio-balloon can change the Movable state
>>> while there are other users of the page? Can you point to the code that
>>> does it? How come this can be safe at all? Or is the PageMovable stable
>>> only under the page lock?
>>>
>>
>> PageMovable is stable under the lock. The relevant instructions are in
>>
>> mm/balloon_compaction.c and include/linux/balloon_compaction.h
> 
> OK, I have just checked __ClearPageMovable and it indeed requires
> PageLock. Then we also have to move is_lru = __PageMovable(page) after
> the page lock.
> 

I assume that is fine as is as the page is isolated? (yes, it will be
modified later when moving but we are interested in the original state)

-- 

Thanks,

David / dhildenb
