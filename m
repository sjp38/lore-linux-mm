Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id DDE4A6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 22:20:22 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id 131so1019515ykp.34
        for <linux-mm@kvack.org>; Thu, 29 May 2014 19:20:22 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id b25si5063606yhc.7.2014.05.29.19.20.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 19:20:22 -0700 (PDT)
Message-ID: <1401416415.2618.14.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/5] mm: i_mmap_mutex to rwsem
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 29 May 2014 19:20:15 -0700
In-Reply-To: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

ping? Andrew any chance of getting this in -next?

On Thu, 2014-05-22 at 20:33 -0700, Davidlohr Bueso wrote:
> This patchset extends the work started by Ingo Molnar in late 2012,
> optimizing the anon-vma mutex lock, converting it from a exclusive mutex
> to a rwsem, and sharing the lock for read-only paths when walking the
> the vma-interval tree. More specifically commits 5a505085 and 4fc3f1d6.
> 
> The i_mmap_mutex has similar responsibilities with the anon-vma, protecting
> file backed pages. Therefore we can use similar locking techniques: covert
> the mutex to a rwsem and share the lock when possible.
> 
> With the new optimistic spinning property we have in rwsems, we no longer
> take a hit in performance when using this lock, and we can therefore
> safely do the conversion. Tests show no throughput regressions in aim7 or
> pgbench runs, and we can see gains from sharing the lock, in disk workloads
> ~+15% for over 1000 users on a 8-socket Westmere system.
> 
> This patchset applies on linux-next-20140522.
> 
> Thanks!
> 
> Davidlohr Bueso (5):
>   mm,fs: introduce helpers around i_mmap_mutex
>   mm: use new helper functions around the i_mmap_mutex
>   mm: convert i_mmap_mutex to rwsem
>   mm/rmap: share the i_mmap_rwsem
>   mm: rename leftover i_mmap_mutex
> 
>  fs/hugetlbfs/inode.c         | 14 +++++++-------
>  fs/inode.c                   |  2 +-
>  include/linux/fs.h           | 23 ++++++++++++++++++++++-
>  include/linux/mmu_notifier.h |  2 +-
>  kernel/events/uprobes.c      |  6 +++---
>  kernel/fork.c                |  4 ++--
>  mm/filemap.c                 | 10 +++++-----
>  mm/filemap_xip.c             |  4 ++--
>  mm/hugetlb.c                 | 22 +++++++++++-----------
>  mm/memory-failure.c          |  4 ++--
>  mm/memory.c                  |  8 ++++----
>  mm/mmap.c                    | 22 +++++++++++-----------
>  mm/mremap.c                  |  6 +++---
>  mm/nommu.c                   | 14 +++++++-------
>  mm/rmap.c                    | 10 +++++-----
>  15 files changed, 86 insertions(+), 65 deletions(-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
