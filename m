Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 442E16B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:19:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z55so4592039wrz.2
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:19:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor604874wmx.87.2017.10.19.12.19.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 12:19:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019101832.xli25kizn3y55pbq@node.shutemov.name>
References: <20171018231730.42754-1-shakeelb@google.com> <20171019101832.xli25kizn3y55pbq@node.shutemov.name>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 19 Oct 2017 12:19:20 -0700
Message-ID: <CALvZod53p3P_cM9bZVtjgQ34Y5+d+bF__sOpgUfofMS7n8Ugog@mail.gmail.com>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Oct 19, 2017 at 3:18 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Oct 18, 2017 at 04:17:30PM -0700, Shakeel Butt wrote:
>> Recently we have observed high latency in mlock() in our generic
>> library and noticed that users have started using tmpfs files even
>> without swap and the latency was due to expensive remote LRU cache
>> draining.
>
> Hm. Isn't the point of mlock() to pay price upfront and make execution
> smoother after this?
>
> With this you shift latency onto reclaim (and future memory allocation).
>
> I'm not sure if it's a win.
>

It will not shift latency to fast path memory allocation. Reclaim
happens on slow path and only reclaim may see more mlocked pages.
Please note that the very antagonistics workload i.e. for each mlock
on a cpu, the pages being mlocked happen to be on the cache of other
cpus, is very hard to trigger.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
