Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01C56B074F
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 14:06:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g32so6785415wrd.8
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 11:06:25 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id a11si5471454edk.129.2017.08.04.11.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 11:06:24 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id x64so6529569wmg.1
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 11:06:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyPq+vVyFJ9GGm8FxH-MYAzLA+Q86Gmz44aDopQxrsC9g@mail.gmail.com>
References: <20170803054630.18775-1-xiyou.wangcong@gmail.com>
 <20170803161146.4316d105e533a363a5597e64@linux-foundation.org> <CA+55aFyPq+vVyFJ9GGm8FxH-MYAzLA+Q86Gmz44aDopQxrsC9g@mail.gmail.com>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 4 Aug 2017 11:06:03 -0700
Message-ID: <CAM_iQpXNpZC+2Fs4Gjm13qHDtL_Nk_BwOH5xg+bp65QE8=Pfng@mail.gmail.com>
Subject: Re: [PATCH] mm: fix list corruptions on shmem shrinklist
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "# .39.x" <stable@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 3, 2017 at 4:25 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Aug 3, 2017 at 4:11 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>> Where is this INIT_LIST_HEAD()?
>
> I think it's this one:
>
>         list_del_init(&info->shrinklist);
>
> in shmem_unused_huge_shrink().


Yes, this is correct. Sorry about confusion.


>
>> I'm not sure I'm understanding this.  AFAICT all the list operations to
>> which you refer are synchronized under spin_lock(&sbinfo->shrinklist_lock)?
>
> No, notice how shmem_unused_huge_shrink() does the
>
>         list_move(&info->shrinklist, &to_remove);
>
> and
>
>         list_move(&info->shrinklist, &list);
>
> to move to (two different) private lists under the shrinklist_lock,
> but once it is on that private "list/to_remove" list, it is then
> accessed outside the locked region.
>
> Honestly, I don't love this situation, or the patch, but I think the
> patch is likely the right thing to do.
>

Me neither. This is probably the quickest fix we could have,
other possible changes might need much more work.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
