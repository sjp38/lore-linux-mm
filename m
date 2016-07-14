Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3166B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:21:41 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id j65so70863427vkb.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:21:41 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id 71si425009uas.183.2016.07.14.05.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 05:21:40 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id u25so2743498qtb.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:21:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
References: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
 <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Thu, 14 Jul 2016 15:21:39 +0300
Message-ID: <CALYGNiPm5NYtFAb1A0kGadaUtB8qDKFs-=2WwrMCwqzACK+zmg@mail.gmail.com>
Subject: Re: [PATCH] radix-tree: fix radix_tree_iter_retry() for tagged iterators.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Stable <stable@vger.kernel.org>

ACK

Originally retry could happen only at index 0 when first indirect node
installed:
in this case tags holds only 1 bit. Seems like now this happends at any index.

On Thu, Jul 14, 2016 at 2:19 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> radix_tree_iter_retry() resets slot to NULL, but it doesn't reset tags.
> Then NULL slot and non-zero iter.tags passed to radix_tree_next_slot()
> leading to crash:
>
> RIP: [<     inline     >] radix_tree_next_slot include/linux/radix-tree.h:473
>   [<ffffffff816951a4>] find_get_pages_tag+0x334/0x930 mm/filemap.c:1452
> ....
> Call Trace:
>  [<ffffffff816cd91a>] pagevec_lookup_tag+0x3a/0x80 mm/swap.c:960
>  [<ffffffff81ab4231>] mpage_prepare_extent_to_map+0x321/0xa90 fs/ext4/inode.c:2516
>  [<ffffffff81ac883e>] ext4_writepages+0x10be/0x2b20 fs/ext4/inode.c:2736
>  [<ffffffff816c99c7>] do_writepages+0x97/0x100 mm/page-writeback.c:2364
>  [<ffffffff8169bee8>] __filemap_fdatawrite_range+0x248/0x2e0 mm/filemap.c:300
>  [<ffffffff8169c371>] filemap_write_and_wait_range+0x121/0x1b0 mm/filemap.c:490
>  [<ffffffff81aa584d>] ext4_sync_file+0x34d/0xdb0 fs/ext4/fsync.c:115
>  [<ffffffff818b667a>] vfs_fsync_range+0x10a/0x250 fs/sync.c:195
>  [<     inline     >] vfs_fsync fs/sync.c:209
>  [<ffffffff818b6832>] do_fsync+0x42/0x70 fs/sync.c:219
>  [<     inline     >] SYSC_fdatasync fs/sync.c:232
>  [<ffffffff818b6f89>] SyS_fdatasync+0x19/0x20 fs/sync.c:230
>  [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1 arch/x86/entry/entry_64.S:207
>
> We must reset iterator's tags to bail out from radix_tree_next_slot() and
> go to the slow-path in radix_tree_next_chunk().
>
> Fixes: 46437f9a554f ("radix-tree: fix race in gang lookup")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Matthew Wilcox <willy@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: <stable@vger.kernel.org>
> ---
>  include/linux/radix-tree.h | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index cb4b7e8..eca6f62 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -407,6 +407,7 @@ static inline __must_check
>  void **radix_tree_iter_retry(struct radix_tree_iter *iter)
>  {
>         iter->next_index = iter->index;
> +       iter->tags = 0;
>         return NULL;
>  }
>
> --
> 2.7.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
