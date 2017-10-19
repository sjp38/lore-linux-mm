Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2493A6B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:13:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l8so85704wre.19
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:13:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e191sor587448wme.81.2017.10.19.13.12.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 13:12:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019141859.4c17f813@MiWiFi-R3-srv>
References: <20171018231730.42754-1-shakeelb@google.com> <20171019141859.4c17f813@MiWiFi-R3-srv>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 19 Oct 2017 13:12:55 -0700
Message-ID: <CALvZod5md_JyBpGC8yCJQteWZvg_AmSaDwiYh+bhoybJ60rwRA@mail.gmail.com>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 18, 2017 at 8:18 PM, Balbir Singh <bsingharora@gmail.com> wrote:
> On Wed, 18 Oct 2017 16:17:30 -0700
> Shakeel Butt <shakeelb@google.com> wrote:
>
>> Recently we have observed high latency in mlock() in our generic
>> library and noticed that users have started using tmpfs files even
>> without swap and the latency was due to expensive remote LRU cache
>> draining.
>>
>> Is lru_add_drain_all() required by mlock()? The answer is no and the
>> reason it is still in mlock() is to rapidly move mlocked pages to
>> unevictable LRU. Without lru_add_drain_all() the mlocked pages which
>> were on pagevec at mlock() time will be moved to evictable LRUs but
>> will eventually be moved back to unevictable LRU by reclaim. So, we
>> can safely remove lru_add_drain_all() from mlock(). Also there is no
>> need for local lru_add_drain() as it will be called deep inside
>> __mm_populate() (in follow_page_pte()).
>>
>> Signed-off-by: Shakeel Butt <shakeelb@google.com>
>> ---
>
> Does this perturb statistics around LRU pages in cgroups and meminfo
> about where the pages actually belong?
>

Yes, it would because the page can be in the evictable LRU until the
reclaim moves it back to the unevictable LRU. However even with the
draining there is a chance that the same thing can happen. For
example, after mlock drains all caches and before getting mmap_sem,
another cpu swaps in the page which the mlock syscall wants to mlock.
Though the without draining the chance of this scenario will increase
and in worst case mlock() can fail to move at most PAGEVEC_SIZE *
(number of cpus - 1)  pages to the unevictable LRU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
