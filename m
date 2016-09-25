Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF33428025E
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 20:18:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t83so398406574oie.0
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 17:18:29 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id j5si2013705otb.156.2016.09.24.17.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 17:18:29 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id i193so11321059oib.3
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 17:18:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com> <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 24 Sep 2016 17:18:28 -0700
Message-ID: <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Matthew Wilcox <mawilcox@linuxonhyperv.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat, Sep 24, 2016 at 4:35 PM, Cedric Blancher
<cedric.blancher@gmail.com> wrote:
>>
>>         void *entry = parent->slots[offset];
>>         int siboff = entry - parent->slots;
>
> If entry is a pointer to void, how can you do pointer arithmetic with it?

It's actually void **.

(That said, gcc has an extension that considers "void *" to be a byte
pointer, so you can actually do arithmetic on them, and it acts like
"char *")

> Also, if you use pointer distances, the use of int is not valid, it
> should then be ptrdiff_t siboff.

The use of "int" is perfectly valid, since it's limited by
RADIX_TREE_MAP_SIZE, so it's going to be a small integer.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
