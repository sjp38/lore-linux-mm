Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCD396B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:51:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o201so87888128ita.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:51:53 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id l24si4376153ioi.104.2017.06.05.15.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:51:53 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id 67so24603820itx.2
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:51:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwrCep+F8zV-fK5ufiDRX+N9yTcHMsyR-JhvFeoD-1LYg@mail.gmail.com>
References: <cover.1496701658.git.luto@kernel.org> <a5eb3dead15bcb36732bb5b655ef4ebe23cf4aa3.1496701658.git.luto@kernel.org>
 <CA+55aFwrCep+F8zV-fK5ufiDRX+N9yTcHMsyR-JhvFeoD-1LYg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 5 Jun 2017 15:51:52 -0700
Message-ID: <CA+55aFwo5UXidsA23FcbD6+VCSbWC9ZHt65it9q9f0L_hycPLw@mail.gmail.com>
Subject: Re: [RFC 01/11] x86/ldt: Simplify LDT switching logic
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 5, 2017 at 3:40 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I think the "LDT didn't match" was really just a simpler and more
> efficient way to say "they weren't both NULL".

In fact, looking back in the history, it used to instead add the sizes
of the context (and then similar logic: "if the sum is non-zero, one
or the other was non-zero").

Commit 0bbed3beb4 ("[PATCH] Thread-Local Storage (TLS) support") in
the historical tree then did this:

-               if (next->context.size+prev->context.size)
+               if (unlikely(prev->context.ldt != next->context.ldt))

I'm ok with your change, but I reacted to the commit log about how
this was "overcomplicated". It was actually an optimization exactly to
avoid two compares..

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
