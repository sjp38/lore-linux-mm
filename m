Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCE3D6B0038
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 04:09:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 11so3992292wrb.10
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 01:09:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2si434679wme.57.2017.10.21.01.09.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 21 Oct 2017 01:09:46 -0700 (PDT)
Date: Sat, 21 Oct 2017 10:09:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: mlock: remove lru_add_drain_all()
Message-ID: <20171021080943.q6b6ac5uucs3vyxc@dhcp22.suse.cz>
References: <20171019222507.2894-1-shakeelb@google.com>
 <CAKTCnznZzFAwc88NW6EJw5vDF_=ARmjPDiP-of=s3geuYNKYTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnznZzFAwc88NW6EJw5vDF_=ARmjPDiP-of=s3geuYNKYTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat 21-10-17 08:51:04, Balbir Singh wrote:
> On Fri, Oct 20, 2017 at 9:25 AM, Shakeel Butt <shakeelb@google.com> wrote:
> > lru_add_drain_all() is not required by mlock() and it will drain
> > everything that has been cached at the time mlock is called. And
> > that is not really related to the memory which will be faulted in
> > (and cached) and mlocked by the syscall itself.
> >
> > Without lru_add_drain_all() the mlocked pages can remain on pagevecs
> > and be moved to evictable LRUs. However they will eventually be moved
> > back to unevictable LRU by reclaim. So, we can safely remove
> > lru_add_drain_all() from mlock syscall. Also there is no need for
> > local lru_add_drain() as it will be called deep inside __mm_populate()
> > (in follow_page_pte()).
> >
> > On larger machines the overhead of lru_add_drain_all() in mlock() can
> > be significant when mlocking data already in memory. We have observed
> > high latency in mlock() due to lru_add_drain_all() when the users
> > were mlocking in memory tmpfs files.
> >
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> > ---
> 
> I'm afraid I still don't fully understand the impact in terms of numbers and
> statistics as seen from inside a cgroup.

I really fail to see why there would be anything cgroup specific here.

> My understanding is that we'll slowly
> see the unreclaimable stats go up as we drain the pvec's across CPU's

Not really. Draining is a bit tricky. Anonymous PF (gup) use
lru_cache_add_active_or_unevictable so we bypass the LRU cache
on mlocked pages altogether. Filemap faults go via cache and
__pagevec_lru_add_fn to flush a full cache is not mlock aware. But gup
(follow_page_pte) path tries to move existing and mapped pages to the
unevictable LRU list. So yes we can see lazy mlock pages on evictable
LRU but reclaim will get them to the unevictable list when needed.
This should be mostly reduced to file mappings. But I haven't checked
the code recently and mlock is quite tricky so I might misremember.

In any case lru_add_drain_all is quite tangent to all this AFAICS.

> I understand the optimization and I can see why lru_add_drain_all() is
> expensive.

not only it is expensive it is paying price for previous caching which
might not be directly related to the mlock syscall.
 
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> 
> Balbir Singh.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
