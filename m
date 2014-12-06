Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 501076B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 20:07:22 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id q107so1295468qgd.41
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 17:07:22 -0800 (PST)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com. [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id w51si1275591qge.89.2014.12.05.17.07.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 17:07:21 -0800 (PST)
Received: by mail-qc0-f171.google.com with SMTP id r5so1352974qcx.16
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 17:07:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
References: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
Date: Fri, 5 Dec 2014 17:07:20 -0800
Message-ID: <CA+55aFwvWk6twgBaevPrF5z_0Faetnh0L19ZokWLidiaAaUmQg@mail.gmail.com>
Subject: Re: [RFC PATCH V2 0/4] Reducing parameters of alloc_pages* family of functions
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Fri, Dec 5, 2014 at 11:59 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> Hey all,
>
> this is a V2 of attempting something that has been discussed when Minchan
> proposed to expand the x86 kernel stack [1], namely the reduction of huge
> number of parameters that the alloc_pages* family and get_page_from_freelist()
> functions have.

So I generally like this, but looking at that "struct alloc_context",
one member kind of stands out: the "order" parameter doesn't fit in
with all the other members.

Most everything else is describing where or what kind of pages to work
with. The "order" in contrast, really is separate.

So conceptually, my reaction is that it looks like a good cleanup even
aside from the code/stack size reduction, but that the alloc_context
definition is a bit odd.

Quite frankly, I think the :"order" really fits much more closely with
"alloc_flags", not with the alloc_context. Because like alloc_flags,.
it really describes how we need to allocate things within the context,
I'd argue.

In fact, I think that the order could actually be packed with the
alloc_flags in a single register, even on 32-bit (using a single-word
structure, perhaps). If we really care about number of parameters.

I'd rather go for "makes conceptual sense" over "packs order in
because it kind of works" and we don't modify it".

Hmm?

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
