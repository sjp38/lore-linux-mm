Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F67B6B074C
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 13:59:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g71so6482478wmg.13
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 10:59:11 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id j33si4567070ede.404.2017.08.04.10.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 10:59:10 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id q189so6519528wmd.0
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 10:59:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170803165307.172e2e1100b0170f6055894a@linux-foundation.org>
References: <20170803054630.18775-1-xiyou.wangcong@gmail.com>
 <20170803161146.4316d105e533a363a5597e64@linux-foundation.org>
 <CA+55aFyPq+vVyFJ9GGm8FxH-MYAzLA+Q86Gmz44aDopQxrsC9g@mail.gmail.com> <20170803165307.172e2e1100b0170f6055894a@linux-foundation.org>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 4 Aug 2017 10:58:49 -0700
Message-ID: <CAM_iQpU-BQZM2EyxBZ9_maT7WM2LH_Weu4sgBsy=oEZ+aabAbg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix list corruptions on shmem shrinklist
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "# .39.x" <stable@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 3, 2017 at 4:53 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 3 Aug 2017 16:25:46 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>> On Thu, Aug 3, 2017 at 4:11 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>> >
>> > Where is this INIT_LIST_HEAD()?
>>
>> I think it's this one:
>>
>>         list_del_init(&info->shrinklist);
>>
>> in shmem_unused_huge_shrink().
>
> OK.
>
>> > I'm not sure I'm understanding this.  AFAICT all the list operations to
>> > which you refer are synchronized under spin_lock(&sbinfo->shrinklist_lock)?
>>
>> No, notice how shmem_unused_huge_shrink() does the
>>
>>         list_move(&info->shrinklist, &to_remove);
>>
>> and
>>
>>         list_move(&info->shrinklist, &list);
>>
>> to move to (two different) private lists under the shrinklist_lock,
>> but once it is on that private "list/to_remove" list, it is then
>> accessed outside the locked region.
>
> So the code is using sbinfo->shrinklist_lock to protect
> sbinfo->shrinklist AND to protect all the per-inode info->shrinklist's.
> Except it didn't get the coverage complete.


Normally once we move list entries from a global list to a private
one they are no longer visible to others, however in this case
they could still be accessed via setattr() path.

>
> Presumably it's too expensive to extend sbinfo->shrinklist_lock
> coverage in shmem_unused_huge_shrink() (or is it?  - this is huge
> pages).  An alternative would be to add a new
> shmem_inode_info.shrinklist_lock whose mandate is to protect
> shmem_inode_info.shrinklist.

Both find_lock_page() and iput() could sleep, I think this is why
we have to defer these two calls after releasing spinlock.

>
>> Honestly, I don't love this situation, or the patch, but I think the
>> patch is likely the right thing to do.
>
> Well, we could view the premature droppage of sbinfo->shrinklist_lock
> in shmem_unused_huge_shrink() to be a performance optimization and put
> some big fat comments in there explaining what's going on.  But it's
> tricky and it's not known that such an optimization is warranted.

It is not for performance optimization, because we still traverse
the list with the spinlock held. A typical optimization is to use
a list_splice() with spinlock and traverse it without it, this is
used by a few places in networking subsystem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
