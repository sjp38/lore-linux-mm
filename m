Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9666B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 23:19:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so4751721pfj.21
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 20:19:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor2559514pgc.363.2017.10.18.20.19.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 20:19:10 -0700 (PDT)
Date: Thu, 19 Oct 2017 14:18:59 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Message-ID: <20171019141859.4c17f813@MiWiFi-R3-srv>
In-Reply-To: <20171018231730.42754-1-shakeelb@google.com>
References: <20171018231730.42754-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Oct 2017 16:17:30 -0700
Shakeel Butt <shakeelb@google.com> wrote:

> Recently we have observed high latency in mlock() in our generic
> library and noticed that users have started using tmpfs files even
> without swap and the latency was due to expensive remote LRU cache
> draining.
> 
> Is lru_add_drain_all() required by mlock()? The answer is no and the
> reason it is still in mlock() is to rapidly move mlocked pages to
> unevictable LRU. Without lru_add_drain_all() the mlocked pages which
> were on pagevec at mlock() time will be moved to evictable LRUs but
> will eventually be moved back to unevictable LRU by reclaim. So, we
> can safely remove lru_add_drain_all() from mlock(). Also there is no
> need for local lru_add_drain() as it will be called deep inside
> __mm_populate() (in follow_page_pte()).
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---

Does this perturb statistics around LRU pages in cgroups and meminfo
about where the pages actually belong?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
