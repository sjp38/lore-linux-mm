Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA3F6B0010
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:33:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12-v6so9416440edi.12
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 03:33:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j62-v6si510775edd.44.2018.07.11.03.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 03:33:32 -0700 (PDT)
Date: Wed, 11 Jul 2018 12:33:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-ID: <20180711103312.GH20050@dhcp22.suse.cz>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-07-18 07:34:06, Yang Shi wrote:
> 
> Background:
> Recently, when we ran some vm scalability tests on machines with large memory,
> we ran into a couple of mmap_sem scalability issues when unmapping large memory
> space, please refer to https://lkml.org/lkml/2017/12/14/733 and
> https://lkml.org/lkml/2018/2/20/576.
> 
> 
> History:
> Then akpm suggested to unmap large mapping section by section and drop mmap_sem
> at a time to mitigate it (see https://lkml.org/lkml/2018/3/6/784).
> 
> V1 patch series was submitted to the mailing list per Andrew's suggestion
> (see https://lkml.org/lkml/2018/3/20/786). Then I received a lot great feedback
> and suggestions.
> 
> Then this topic was discussed on LSFMM summit 2018. In the summit, Michal Hocko
> suggested (also in the v1 patches review) to try "two phases" approach. Zapping
> pages with read mmap_sem, then doing via cleanup with write mmap_sem (for
> discussion detail, see https://lwn.net/Articles/753269/)
> 
> 
> Approach:
> Zapping pages is the most time consuming part, according to the suggestion from
> Michal Hocko [1], zapping pages can be done with holding read mmap_sem, like
> what MADV_DONTNEED does. Then re-acquire write mmap_sem to cleanup vmas.
> 
> But, we can't call MADV_DONTNEED directly, since there are two major drawbacks:
>   * The unexpected state from PF if it wins the race in the middle of munmap.
>     It may return zero page, instead of the content or SIGSEGV.
>   * Cana??t handle VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe mappings, which
>     is a showstopper from akpm

I do not really understand why this is a showstopper. This is a mere
optimization. VM_LOCKED ranges are usually not that large. VM_HUGETLB
can be quite large alright but this should be doable on top. Is there
any reason to block any "cover most mappings first" patch?

> And, some part may need write mmap_sem, for example, vma splitting. So, the
> design is as follows:
>         acquire write mmap_sem
>         lookup vmas (find and split vmas)
>         set VM_DEAD flags
>         deal with special mappings
>         downgrade_write
> 
>         zap pages
>         release mmap_sem
> 
>         retake mmap_sem exclusively
>         cleanup vmas
>         release mmap_sem

Please explain why dropping the lock and then ratake it to cleanup vmas
is OK. This is really important because parallel thread could have
changed the underlying address space range.

Moreover

>  include/linux/mm.h  |   8 +++
>  include/linux/oom.h |  20 -------
>  mm/huge_memory.c    |   4 +-
>  mm/hugetlb.c        |   5 ++
>  mm/memory.c         |  57 ++++++++++++++++---
>  mm/mmap.c           | 221 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------
>  mm/shmem.c          |   9 ++-
>  7 files changed, 255 insertions(+), 69 deletions(-)

this is not a small change for something that could be achieved
from the userspace trivially (just call madvise before munmap - library
can hide this). Most workloads will even not care about races because
they simply do not play tricks with mmaps and userspace MM. So why do we
want to put the additional complexity into the kernel?

Note that I am _not_ saying this is a wrong idea, we just need some
pretty sounds arguments to justify the additional complexity which is
mostly based on our fear that somebody might be doing something
(half)insane or dubious at best.

-- 
Michal Hocko
SUSE Labs
