Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5A236B028A
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 04:36:30 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n4so70221206lfb.3
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 01:36:30 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id j200si4983488lfg.177.2016.09.24.01.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 01:36:28 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id l131so6792706lfl.0
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 01:36:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com> <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 24 Sep 2016 11:36:27 +0300
Message-ID: <CALYGNiNczCgx31dVPtdoN2kOhUEk2uCTk_Xd_28JrRTy5_Ee8g@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Sep 22, 2016 at 9:53 PM, Matthew Wilcox
<mawilcox@linuxonhyperv.com> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> When compiling the radix tree with -O2, GCC thinks it can optimise:
>
>         void *entry = parent->slots[offset];
>         int siboff = entry - parent->slots;
>         void *slot = parent->slots + siboff;
>
> into
>
>         void *slot = entry;
>
> Unfortunately, 'entry' is a tagged pointer, so this optimisation leads
> to getting an unaligned pointer back from radix_tree_lookup_slot().
> The test suite wasn't being compiled with optimisation, so we hadn't
> spotted it before now.  Change the test suite to compile with -O2, and
> fix the optimisation problem by passing 'entry' through entry_to_node()
> so gcc knows this isn't a plain pointer.
> ---
>  lib/radix-tree.c                  | 3 ++-
>  tools/testing/radix-tree/Makefile | 2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 1b7bf73..8bf1f32 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -105,7 +105,8 @@ static unsigned int radix_tree_descend(struct radix_tree_node *parent,
>
>  #ifdef CONFIG_RADIX_TREE_MULTIORDER
>         if (radix_tree_is_internal_node(entry)) {
> -               unsigned long siboff = get_slot_offset(parent, entry);
> +               unsigned long siboff = get_slot_offset(parent,
> +                                               (void **)entry_to_node(entry));

As I see this is the only place where get_slot_offset used for
unaligned pointer.
Nobody uses "multiorder entries" so this never happens. And I have
plan to kill this code.

>                 if (siboff < RADIX_TREE_MAP_SIZE) {
>                         offset = siboff;
>                         entry = rcu_dereference_raw(parent->slots[offset]);
> diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
> index 3b53046..9d0919ed 100644
> --- a/tools/testing/radix-tree/Makefile
> +++ b/tools/testing/radix-tree/Makefile
> @@ -1,5 +1,5 @@
>
> -CFLAGS += -I. -g -Wall -D_LGPL_SOURCE
> +CFLAGS += -I. -g -O2 -Wall -D_LGPL_SOURCE
>  LDFLAGS += -lpthread -lurcu
>  TARGETS = main
>  OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
> --
> 2.9.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
