Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2D8E6B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:19:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r79so4497674wrb.7
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:19:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r201sor551909wme.51.2017.10.19.12.19.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 12:19:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <edbbda21-85ad-2bbe-4e09-298133fd471b@linux.vnet.ibm.com>
References: <20171018231730.42754-1-shakeelb@google.com> <edbbda21-85ad-2bbe-4e09-298133fd471b@linux.vnet.ibm.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 19 Oct 2017 12:19:16 -0700
Message-ID: <CALvZod5qS1WRc_RgaR2abLic221Os3amnouKKuPbRF9KJ2NC8g@mail.gmail.com>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 18, 2017 at 11:24 PM, Anshuman Khandual
<khandual@linux.vnet.ibm.com> wrote:
> On 10/19/2017 04:47 AM, Shakeel Butt wrote:
>> Recently we have observed high latency in mlock() in our generic
>> library and noticed that users have started using tmpfs files even
>> without swap and the latency was due to expensive remote LRU cache
>> draining.
>
> With and without this I patch I dont see much difference in number
> of instructions executed in the kernel for mlock() system call on
> POWER8 platform just after reboot (all the pagevecs might not been
> filled by then though). There is an improvement but its very less.
>
> Could you share your latency numbers and how this patch is making
> them better.
>

The latency is very dependent on the workload and the number of cores
on the machine. On production workload, the customers were complaining
single mlock() was taking around 10 seconds on tmpfs files which were
already in memory.

>>
>> Is lru_add_drain_all() required by mlock()? The answer is no and the
>> reason it is still in mlock() is to rapidly move mlocked pages to
>> unevictable LRU. Without lru_add_drain_all() the mlocked pages which
>> were on pagevec at mlock() time will be moved to evictable LRUs but
>> will eventually be moved back to unevictable LRU by reclaim. So, we
>
> Wont this affect the performance during reclaim ?
>

Yes, but reclaim is already a slow path and to seriously impact
reclaim we will need a very very antagonistic workload which is very
hard to trigger (i.e. for each mlock on a cpu, the pages being mlocked
happen to be on the cache of other cpus).

>> can safely remove lru_add_drain_all() from mlock(). Also there is no
>> need for local lru_add_drain() as it will be called deep inside
>> __mm_populate() (in follow_page_pte()).
>
> The following commit which originally added lru_add_drain_all()
> during mlock() and mlockall() has similar explanation.
>
> 8891d6da ("mm: remove lru_add_drain_all() from the munlock path")
>
> "In addition, this patch add lru_add_drain_all() to sys_mlock()
> and sys_mlockall().  it isn't must.  but it reduce the failure
> of moving to unevictable list.  its failure can rescue in
> vmscan later.  but reducing is better."
>
> Which sounds like either we have to handle the active to inactive
> LRU movement during reclaim or it can be done here to speed up
> reclaim later on.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
