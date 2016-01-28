Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 611166B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:17:49 -0500 (EST)
Received: by mail-lf0-f43.google.com with SMTP id s81so21150461lfd.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 23:17:49 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id u4si4931419lfd.72.2016.01.27.23.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 23:17:41 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id t141so1572571lfd.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 23:17:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
Date: Thu, 28 Jan 2016 10:17:41 +0300
Message-ID: <CALYGNiMYZMk6qmjfgcnz5Z0k3DLA3CihOdNjR+D0fqsoJn2mVQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] Fix races & improve the radix tree iterator patterns
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ohad Ben-Cohen <ohad@wizery.com>, Matthew Wilcox <willy@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 28, 2016 at 12:17 AM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
>
> The first two patches here are bugfixes, and I would like to see them
> make their way into stable ASAP since they can lead to data corruption
> (very low probabilty).
>
> The last three patches do not qualify as bugfixes.  They simply improve
> the standard pattern used to do radix tree iterations by removing the
> 'goto restart' part.  Partially this is because this is an ugly &
> confusing goto, and partially because with multi-order entries in the
> tree, it'll be more likely that we'll see an indirect_ptr bit, and
> it's more efficient to kep going from the point of the iteration we're
> currently in than restart from the beginning each time.

Ack  whole set.

I think we should go deeper in hide dereference/retry inside iterator.
Something like radix_tree_for_each_data(data, slot, root, iter, start).
I'll prepare patch for that.

>
> Matthew Wilcox (5):
>   radix-tree: Fix race in gang lookup
>   hwspinlock: Fix race between radix tree insertion and lookup
>   btrfs: Use radix_tree_iter_retry()
>   mm: Use radix_tree_iter_retry()
>   radix-tree,shmem: Introduce radix_tree_iter_next()
>
>  drivers/hwspinlock/hwspinlock_core.c |  4 +++
>  fs/btrfs/tests/btrfs-tests.c         |  3 +-
>  include/linux/radix-tree.h           | 31 +++++++++++++++++++++
>  lib/radix-tree.c                     | 12 ++++++--
>  mm/filemap.c                         | 53 ++++++++++++------------------------
>  mm/shmem.c                           | 30 ++++++++++----------
>  6 files changed, 78 insertions(+), 55 deletions(-)
>
> --
> 2.7.0.rc3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
