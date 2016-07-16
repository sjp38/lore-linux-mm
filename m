Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19D706B0253
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 09:45:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so32338193wmr.0
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 06:45:34 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id cy7si6399469wjc.180.2016.07.16.06.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jul 2016 06:45:32 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id x83so5810838wma.3
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 06:45:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160715190040.GA7195@linux.intel.com>
References: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
 <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
 <20160714222527.GA26136@linux.intel.com> <5788A46A.70106@virtuozzo.com> <20160715190040.GA7195@linux.intel.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 16 Jul 2016 16:45:31 +0300
Message-ID: <CALYGNiOAKHtU0U6YSg39ByGsBYxrtuWEx270zC3=dtEijDHBaA@mail.gmail.com>
Subject: Re: [PATCH] radix-tree: fix radix_tree_iter_retry() for tagged iterators.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Stable <stable@vger.kernel.org>

On Fri, Jul 15, 2016 at 10:00 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Fri, Jul 15, 2016 at 11:52:58AM +0300, Andrey Ryabinin wrote:
>> On 07/15/2016 01:25 AM, Ross Zwisler wrote:
>> > On Thu, Jul 14, 2016 at 02:19:56PM +0300, Andrey Ryabinin wrote:
>> >> radix_tree_iter_retry() resets slot to NULL, but it doesn't reset tags.
>> >> Then NULL slot and non-zero iter.tags passed to radix_tree_next_slot()
>> >> leading to crash:
>> >>
>> >> RIP: [<     inline     >] radix_tree_next_slot include/linux/radix-tree.h:473
>> >>   [<ffffffff816951a4>] find_get_pages_tag+0x334/0x930 mm/filemap.c:1452
>> >> ....
>> >> Call Trace:
>> >>  [<ffffffff816cd91a>] pagevec_lookup_tag+0x3a/0x80 mm/swap.c:960
>> >>  [<ffffffff81ab4231>] mpage_prepare_extent_to_map+0x321/0xa90 fs/ext4/inode.c:2516
>> >>  [<ffffffff81ac883e>] ext4_writepages+0x10be/0x2b20 fs/ext4/inode.c:2736
>> >>  [<ffffffff816c99c7>] do_writepages+0x97/0x100 mm/page-writeback.c:2364
>> >>  [<ffffffff8169bee8>] __filemap_fdatawrite_range+0x248/0x2e0 mm/filemap.c:300
>> >>  [<ffffffff8169c371>] filemap_write_and_wait_range+0x121/0x1b0 mm/filemap.c:490
>> >>  [<ffffffff81aa584d>] ext4_sync_file+0x34d/0xdb0 fs/ext4/fsync.c:115
>> >>  [<ffffffff818b667a>] vfs_fsync_range+0x10a/0x250 fs/sync.c:195
>> >>  [<     inline     >] vfs_fsync fs/sync.c:209
>> >>  [<ffffffff818b6832>] do_fsync+0x42/0x70 fs/sync.c:219
>> >>  [<     inline     >] SYSC_fdatasync fs/sync.c:232
>> >>  [<ffffffff818b6f89>] SyS_fdatasync+0x19/0x20 fs/sync.c:230
>> >>  [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1 arch/x86/entry/entry_64.S:207
>> >>
>> >> We must reset iterator's tags to bail out from radix_tree_next_slot() and
>> >> go to the slow-path in radix_tree_next_chunk().
>> >
>> > This analysis doesn't make sense to me.  In find_get_pages_tag(), when we call
>> > radix_tree_iter_retry(), this sets the local 'slot' variable to NULL, then
>> > does a 'continue'.  This will hop to the next iteration of the
>> > radix_tree_for_each_tagged() loop, which will very check the exit condition of
>> > the for() loop:
>> >
>> > #define radix_tree_for_each_tagged(slot, root, iter, start, tag)    \
>> >     for (slot = radix_tree_iter_init(iter, start) ;                 \
>> >          slot || (slot = radix_tree_next_chunk(root, iter,          \
>> >                           RADIX_TREE_ITER_TAGGED | tag)) ;          \
>> >          slot = radix_tree_next_slot(slot, iter,                    \
>> >                             RADIX_TREE_ITER_TAGGED))
>> >
>> > So, we'll run the
>> >          slot || (slot = radix_tree_next_chunk(root, iter,          \
>> >                           RADIX_TREE_ITER_TAGGED | tag)) ;          \
>> >
>> > bit first.
>>
>> This is not the way how the for() loop works. slot = radix_tree_next_slot() executed first
>> and only after that goes the condition statement.
>
> Right...*sigh*...  Thanks for the sanity check. :)
>
>> > 'slot' is NULL, so we'll set it via radix_tree_next_chunk().  At
>> > this point radix_tree_next_slot() hasn't been called.
>> >
>> > radix_tree_next_chunk() will set up the iter->index, iter->next_index and
>> > iter->tags before it returns.  The next iteration of the loop in
>> > find_get_pages_tag() will use the non-NULL slot provided by
>> > radix_tree_next_chunk(), and only after that iteration will we call
>> > radix_tree_next_slot() again.  By then iter->tags should be up to date.
>> >
>> > Do you have a test setup that reliably fails without this code but passes when
>> > you zero out iter->tags?
>> >
>>
>>
>> Yup, I run Dmitry's reproducer in a parallel loop:
>>       $ while true; do ./a.out & done
>>
>> Usually it takes just couple minutes maximum.
>
> Cool - I was able to get this to work on my system as well by upping the
> thread count.
>
> In looking at this more, I agree that your patch fixes this particular bug,
> but I think that ultimately we might want something more general.
>
> IIUC, the real issue is that we shouldn't be running through
> radix_tree_next_slot() with a NULL 'slot' parameter.  In the end I think it's
> fine to zero out iter->tags in radix_tree_iter_retry(), but really we want to
> guarantee that we just bail out of radix_tree_next_slot() if we have a NULL
> 'slot'.
>
> I've run this patch in my test setup, and it fixes the reproducer provided by
> Dmitry.  I've also run xfstests against it with out any failures.
>
> --- 8< ---
> From 533beefac12f61f467aeb72e2d2c46685247b9bc Mon Sep 17 00:00:00 2001
> From: Ross Zwisler <ross.zwisler@linux.intel.com>
> Date: Fri, 15 Jul 2016 12:46:38 -0600
> Subject: [PATCH] radix-tree: 'slot' can be NULL in radix_tree_next_slot()
>
> There are four cases I can see where we could end up with a NULL 'slot' in
> radix_tree_next_slot() (there might be more):
>
> 1) radix_tree_iter_retry() via a non-tagged iteration like
> radix_tree_for_each_slot().  In this case we currently aren't seeing a bug
> because radix_tree_iter_retry() sets
>
>         iter->next_index = iter->index;
>
> which means that in in the else case in radix_tree_next_slot(), 'count' is
> zero, so we skip over the while() loop and effectively just return NULL
> without ever dereferencing 'slot'.
>
> 2) radix_tree_iter_retry() via tagged iteration like
> radix_tree_for_each_tagged().  With the current code this case is
> unhandled and we have seen it result in a kernel crash when we dereference
> 'slot'.
>
> 3) radix_tree_iter_next() via via a non-tagged iteration like
> radix_tree_for_each_slot().  This currently happens in shmem_tag_pins()
> and shmem_partial_swap_usage().
>
> I think that this case is currently unhandled.  Unlike with
> radix_tree_iter_retry() case (#1 above) we can't rely on 'count' in the else
> case of radix_tree_next_slot() to be zero, so I think it's possible we'll end
> up executing code in the while() loop in radix_tree_next_slot() that assumes
> 'slot' is valid.
>
> I haven't actually seen this crash on a test setup, but I don't think the
> current code is safe.

This is becase distance between ->index and ->next_index now could be
more that one?

We could fix that by adding "iter->index = iter->next_index - 1;" into
radix_tree_iter_next()
right after updating next_index and tweak multi-order itreration logic
if it depends on that.

I'd like to keep radix_tree_next_slot() as small as possible because
this is supposed to be a fast-path.

>
> 4) radix_tree_iter_next() via tagged iteration like
> radix_tree_for_each_tagged().  This happens in shmem_wait_for_pins().
>
> radix_tree_iter_next() zeros out iter->tags, so we end up exiting
> radix_tree_next_slot() here:
>
>         if (flags & RADIX_TREE_ITER_TAGGED) {
>                 void *canon = slot;
>
>                 iter->tags >>= 1;
>                 if (unlikely(!iter->tags))
>                         return NULL;
>
> Really we want to guarantee that we just bail out  of
> radix_tree_next_slot() if we have a NULL 'slot'.  This is a more explicit
> way of handling all the 4 above cases.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/radix-tree.h | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index cb4b7e8..840308d 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -463,6 +463,9 @@ static inline struct radix_tree_node *entry_to_node(void *ptr)
>  static __always_inline void **
>  radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
>  {
> +       if (unlikely(!slot))
> +               return NULL;
> +
>         if (flags & RADIX_TREE_ITER_TAGGED) {
>                 void *canon = slot;
>
> --
> 2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
