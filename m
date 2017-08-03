Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8806B0634
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 19:25:48 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id f11so137806oic.3
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 16:25:48 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id s134si80801ois.453.2017.08.03.16.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 16:25:47 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id j194so134376oib.4
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 16:25:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170803161146.4316d105e533a363a5597e64@linux-foundation.org>
References: <20170803054630.18775-1-xiyou.wangcong@gmail.com> <20170803161146.4316d105e533a363a5597e64@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 3 Aug 2017 16:25:46 -0700
Message-ID: <CA+55aFyPq+vVyFJ9GGm8FxH-MYAzLA+Q86Gmz44aDopQxrsC9g@mail.gmail.com>
Subject: Re: [PATCH] mm: fix list corruptions on shmem shrinklist
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "# .39.x" <stable@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 3, 2017 at 4:11 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> Where is this INIT_LIST_HEAD()?

I think it's this one:

        list_del_init(&info->shrinklist);

in shmem_unused_huge_shrink().

> I'm not sure I'm understanding this.  AFAICT all the list operations to
> which you refer are synchronized under spin_lock(&sbinfo->shrinklist_lock)?

No, notice how shmem_unused_huge_shrink() does the

        list_move(&info->shrinklist, &to_remove);

and

        list_move(&info->shrinklist, &list);

to move to (two different) private lists under the shrinklist_lock,
but once it is on that private "list/to_remove" list, it is then
accessed outside the locked region.

Honestly, I don't love this situation, or the patch, but I think the
patch is likely the right thing to do.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
