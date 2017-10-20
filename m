Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D83106B025E
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 11:07:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 4so1198687wrt.8
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:07:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n128sor414015wma.79.2017.10.20.08.07.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 08:07:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020061902.sqz5vklhtqrawelf@dhcp22.suse.cz>
References: <20171019222507.2894-1-shakeelb@google.com> <20171020061902.sqz5vklhtqrawelf@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 20 Oct 2017 08:07:19 -0700
Message-ID: <CALvZod6YGNKPi6-ny-eoP0+uQOWokP2hh+iNvKewT6XJdtgKrw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: mlock: remove lru_add_drain_all()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Oct 19, 2017 at 11:19 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 19-10-17 15:25:07, Shakeel Butt wrote:
>> lru_add_drain_all() is not required by mlock() and it will drain
>> everything that has been cached at the time mlock is called. And
>> that is not really related to the memory which will be faulted in
>> (and cached) and mlocked by the syscall itself.
>>
>> Without lru_add_drain_all() the mlocked pages can remain on pagevecs
>> and be moved to evictable LRUs. However they will eventually be moved
>> back to unevictable LRU by reclaim. So, we can safely remove
>> lru_add_drain_all() from mlock syscall. Also there is no need for
>> local lru_add_drain() as it will be called deep inside __mm_populate()
>> (in follow_page_pte()).
>
> This paragraph can be still a bit confusing. I suspect you meant to say
> something like: "If anything lru_add_drain_all" should be called _after_
> pages have been mlocked and faulted in but even that is not strictly
> needed because those pages would get to the appropriate LRUs lazily
> during the reclaim path. Moreover follow_page_pte (gup) will drain the
> local pcp LRU cache."
>

Andrew, can you please replace the second paragraph of the commit with
Michal's suggested paragraph.

>> On larger machines the overhead of lru_add_drain_all() in mlock() can
>> be significant when mlocking data already in memory. We have observed
>> high latency in mlock() due to lru_add_drain_all() when the users
>> were mlocking in memory tmpfs files.
>>
>> Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> Anyway, this patch makes a lot of sense to me. Feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>
>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
