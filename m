Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0AED06B027D
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 14:09:31 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r126so214541893oib.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:09:31 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id o6si2783448oig.23.2016.09.22.11.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 11:09:17 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id w11so6857819oia.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:09:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com> <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Sep 2016 11:09:16 -0700
Message-ID: <CA+55aFwNYAFc4KePvx50kwZ3A+8yvCCK_6nYYxG9fqTPhFzQoQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Sep 22, 2016 at 11:53 AM, Matthew Wilcox
<mawilcox@linuxonhyperv.com> wrote:
>
>           Change the test suite to compile with -O2, and
> fix the optimisation problem by passing 'entry' through entry_to_node()
> so gcc knows this isn't a plain pointer.

Ugh. I really don't like this patch very much.

Wouldn't it be cleaner to just fix "get_slot_offset()" instead? As it
is, looking at the code, I suspect that it's really hard to convince
people that there isn't some other place this might happen. Because
the "pointer subtraction followed by pointer addition" pattern is all
hidden in these inline functions.

Or at least add a big comment about why this is the only such case.

Because without that, the code now looks very bad.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
