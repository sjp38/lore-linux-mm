Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA706B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 17:50:00 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j13so13486943iod.6
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:50:00 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id 141si160713itu.33.2017.01.05.14.49.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 14:49:59 -0800 (PST)
Received: by mail-io0-x22b.google.com with SMTP id p127so44561931iop.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:49:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170105211056.18340.qmail@ns.sciencehorizons.net>
References: <CA+55aFyNFb7Ns7O2yjWsKZHOEzgGkyVznp=kLRE9an-mEUC0BQ@mail.gmail.com>
 <20170105211056.18340.qmail@ns.sciencehorizons.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Jan 2017 14:49:58 -0800
Message-ID: <CA+55aFyZtmjsaE_g6TXoqwhBUL-gtt53ARGmpU8eFFZ0wNWDbg@mail.gmail.com>
Subject: Re: A use case for MAP_COPY
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@sciencehorizons.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>

On Thu, Jan 5, 2017 at 1:10 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
>
>> Not going to happen.
>
> Really?  Because the rest of your response is a lot more encouraging.

The thing is, I don't think you can do it with a reasonable patch. It
just gets too nasty.

For example, what happens when there is low memory? What you would
*want* to happen is to just forget the page and read it back in.
That/s how MAP_PRIVATE works. But that won't actually work for
MAP_COPY. You'd need to page the thing out, as if you had written to
it (even though you didn't). Not because you want to, but because your
versioning scheme depends on it.

So how are y ou going to solve that versioning probnlem wrt memory
pressure? The whole point of MAP_COPY is to avoid a memory copy, but
if you now end up having to do IO, and having to have a swap device
for it, it's completely unacceptable. See?

How are you going to avoid the issues with growing 'struct page'?

So the fact is, it's a horrible idea. I don't think you understand how
horrible it is. The only way you'll understand is if you try to write
the patch.

"Siperia opettaa".

So you can try to prove me wrong by sending a patch. I doubt you will.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
