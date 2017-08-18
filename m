Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 551656B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 21:20:19 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id v17so133597314ywh.15
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:20:19 -0700 (PDT)
Received: from mail-yw0-x230.google.com (mail-yw0-x230.google.com. [2607:f8b0:4002:c05::230])
        by mx.google.com with ESMTPS id w5si1209303ywe.213.2017.08.17.18.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 18:20:18 -0700 (PDT)
Received: by mail-yw0-x230.google.com with SMTP id s143so51022588ywg.1
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:20:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170818011023.181465-1-shakeelb@google.com>
References: <20170818011023.181465-1-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 17 Aug 2017 18:20:17 -0700
Message-ID: <CALvZod444NZaw9wcdSMs5Y60a0cV4j9SEt-TLBJT34OJ_yg3CQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: fadvise: avoid fadvise for fs without backing device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

+linux-mm, linux-kernel

On Thu, Aug 17, 2017 at 6:10 PM, Shakeel Butt <shakeelb@google.com> wrote:
> The fadvise() manpage is silent on fadvise()'s effect on
> memory-based filesystems (shmem, hugetlbfs & ramfs) and pseudo
> file systems (procfs, sysfs, kernfs). The current implementaion
> of fadvise is mostly a noop for such filesystems except for
> FADV_DONTNEED which will trigger expensive remote LRU cache
> draining. This patch makes the noop of fadvise() on such file
> systems very explicit.
>
> However this change has two side effects for ramfs and one for
> tmpfs. First fadvise(FADV_DONTNEED) can remove the unmapped clean
> zero'ed pages of ramfs (allocated through read, readahead & read
> fault) and tmpfs (allocated through read fault). Also
> fadvise(FADV_WILLNEED) on create such clean zero'ed pages for
> ramfs. This change removes these two interfaces.
>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  mm/fadvise.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index a43013112581..702f239cd6db 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -52,7 +52,9 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>                 goto out;
>         }
>
> -       if (IS_DAX(inode)) {
> +       bdi = inode_to_bdi(mapping->host);
> +
> +       if (IS_DAX(inode) || (bdi == &noop_backing_dev_info)) {
>                 switch (advice) {
>                 case POSIX_FADV_NORMAL:
>                 case POSIX_FADV_RANDOM:
> @@ -75,8 +77,6 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>         else
>                 endbyte--;              /* inclusive */
>
> -       bdi = inode_to_bdi(mapping->host);
> -
>         switch (advice) {
>         case POSIX_FADV_NORMAL:
>                 f.file->f_ra.ra_pages = bdi->ra_pages;
> --
> 2.14.1.480.gb18f417b89-goog
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
