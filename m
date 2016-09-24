Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB9628024B
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 17:04:48 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id mi5so272516291pab.2
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 14:04:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 65si814919pfh.155.2016.09.24.14.04.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 24 Sep 2016 14:04:47 -0700 (PDT)
Date: Sun, 25 Sep 2016 00:04:43 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Message-ID: <20160924210443.GA106728@black.fi.intel.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CA+55aFwNYAFc4KePvx50kwZ3A+8yvCCK_6nYYxG9fqTPhFzQoQ@mail.gmail.com>
 <DM2PR21MB0089CA7DCF4845DB02E0E05FCBC80@DM2PR21MB0089.namprd21.prod.outlook.com>
 <CA+55aFwiro5MvOozcF50z4kMBk7rVBViLw8yXX1w-1mCZVAsDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwiro5MvOozcF50z4kMBk7rVBViLw8yXX1w-1mCZVAsDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sat, Sep 24, 2016 at 01:21:36PM -0700, Linus Torvalds wrote:
> On Fri, Sep 23, 2016 at 1:16 PM, Matthew Wilcox <mawilcox@microsoft.com> wrote:
> >
> >  #ifdef CONFIG_RADIX_TREE_MULTIORDER
> >         if (radix_tree_is_internal_node(entry)) {
> > -               unsigned long siboff = get_slot_offset(parent, entry);
> > +               unsigned long siboff = get_slot_offset(parent,
> > +                                               (void **)entry_to_node(entry));
> 
> I feel that it is *this* part that I think needs a huge honking comment.
> 
> If you are going to make get_slot_offset() different, then you could
> just rewrite get_slot_offset() to do
> 
>         unsigned long diff = (unsigned long) slot - (unsigned
> long)parent->slots;
>         return diff / sizeof(void *);
> 
> and add a comment to say "don't do this as a pointer diff, because
> 'slot' may not be an aligned pointer". No BUG_ON() necessary, because
> it "just works".
> 
> At that point, gcc should just generate the right code, because it
> doesn't see it as a pointer subtraction followed by a pointer
> addition.
> 
> And yes, that crazy " (void **)entry_to_node(entry)" fixes it *too*,
> but it needs a *comment*.
> 
> Why is that special, when all the other uses of get_slot_offset()
> don't have that? *That* is what should be explained. Not some internal
> detail.
> 
> That said, if this code isn't even used, as Konstantin says (THP
> selects it - doesn't THP use it?), then the fix really should be to
> just remove the odd code instead of adding to it.
> 
> Looking around for uses that set "order" to anything but zero, I
> really don't see it. So maybe we should just do *that* trivial thing
> instead, and remove CONFIG_RADIX_TREE_MULTIORDER, since it's appears
> to be buggy and always has been.

Well, my ext4-with-huge-pages patchset[1] uses multi-order entries.
It also converts shmem-with-huge-pages and hugetlb to them.

I'm okay with converting it to other mechanism, but I need something.
(I looked into Konstantin's RFC patchset[2]. It looks okay, but I don't
feel myself qualified to review it as I don't know much about radix-tree
internals.)

[1] http://lkml.kernel.org/r/20160915115523.29737-1-kirill.shutemov@linux.intel.com
[2] http://lkml.kernel.org/r/147230727479.9957.1087787722571077339.stgit@zurg

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
