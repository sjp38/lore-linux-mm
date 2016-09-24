Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5ADF228024B
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 16:21:38 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r126so383274849oib.2
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 13:21:38 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id 127si9577690oig.248.2016.09.24.13.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 13:21:37 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id a62so11136125oib.1
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 13:21:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DM2PR21MB0089CA7DCF4845DB02E0E05FCBC80@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CA+55aFwNYAFc4KePvx50kwZ3A+8yvCCK_6nYYxG9fqTPhFzQoQ@mail.gmail.com> <DM2PR21MB0089CA7DCF4845DB02E0E05FCBC80@DM2PR21MB0089.namprd21.prod.outlook.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 24 Sep 2016 13:21:36 -0700
Message-ID: <CA+55aFwiro5MvOozcF50z4kMBk7rVBViLw8yXX1w-1mCZVAsDA@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Matthew Wilcox <mawilcox@linuxonhyperv.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Sep 23, 2016 at 1:16 PM, Matthew Wilcox <mawilcox@microsoft.com> wrote:
>
>  #ifdef CONFIG_RADIX_TREE_MULTIORDER
>         if (radix_tree_is_internal_node(entry)) {
> -               unsigned long siboff = get_slot_offset(parent, entry);
> +               unsigned long siboff = get_slot_offset(parent,
> +                                               (void **)entry_to_node(entry));

I feel that it is *this* part that I think needs a huge honking comment.

If you are going to make get_slot_offset() different, then you could
just rewrite get_slot_offset() to do

        unsigned long diff = (unsigned long) slot - (unsigned
long)parent->slots;
        return diff / sizeof(void *);

and add a comment to say "don't do this as a pointer diff, because
'slot' may not be an aligned pointer". No BUG_ON() necessary, because
it "just works".

At that point, gcc should just generate the right code, because it
doesn't see it as a pointer subtraction followed by a pointer
addition.

And yes, that crazy " (void **)entry_to_node(entry)" fixes it *too*,
but it needs a *comment*.

Why is that special, when all the other uses of get_slot_offset()
don't have that? *That* is what should be explained. Not some internal
detail.

That said, if this code isn't even used, as Konstantin says (THP
selects it - doesn't THP use it?), then the fix really should be to
just remove the odd code instead of adding to it.

Looking around for uses that set "order" to anything but zero, I
really don't see it. So maybe we should just do *that* trivial thing
instead, and remove CONFIG_RADIX_TREE_MULTIORDER, since it's appears
to be buggy and always has been.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
