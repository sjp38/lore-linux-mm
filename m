Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3D6B6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 17:51:06 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id p5so2481008vkf.20
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 14:51:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s14sor828834vke.20.2017.10.20.14.51.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 14:51:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019222507.2894-1-shakeelb@google.com>
References: <20171019222507.2894-1-shakeelb@google.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sat, 21 Oct 2017 08:51:04 +1100
Message-ID: <CAKTCnznZzFAwc88NW6EJw5vDF_=ARmjPDiP-of=s3geuYNKYTA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: mlock: remove lru_add_drain_all()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Oct 20, 2017 at 9:25 AM, Shakeel Butt <shakeelb@google.com> wrote:
> lru_add_drain_all() is not required by mlock() and it will drain
> everything that has been cached at the time mlock is called. And
> that is not really related to the memory which will be faulted in
> (and cached) and mlocked by the syscall itself.
>
> Without lru_add_drain_all() the mlocked pages can remain on pagevecs
> and be moved to evictable LRUs. However they will eventually be moved
> back to unevictable LRU by reclaim. So, we can safely remove
> lru_add_drain_all() from mlock syscall. Also there is no need for
> local lru_add_drain() as it will be called deep inside __mm_populate()
> (in follow_page_pte()).
>
> On larger machines the overhead of lru_add_drain_all() in mlock() can
> be significant when mlocking data already in memory. We have observed
> high latency in mlock() due to lru_add_drain_all() when the users
> were mlocking in memory tmpfs files.
>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---

I'm afraid I still don't fully understand the impact in terms of numbers and
statistics as seen from inside a cgroup. My understanding is that we'll slowly
see the unreclaimable stats go up as we drain the pvec's across CPU's
I understand the optimization and I can see why lru_add_drain_all() is
expensive.

Acked-by: Balbir Singh <bsingharora@gmail.com>

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
