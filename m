Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 506F26B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 13:59:10 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 71so554537751ioe.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 10:59:10 -0800 (PST)
Received: from mail-it0-x22e.google.com (mail-it0-x22e.google.com. [2607:f8b0:4001:c0b::22e])
        by mx.google.com with ESMTPS id m125si53423293iof.46.2017.01.05.10.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 10:59:09 -0800 (PST)
Received: by mail-it0-x22e.google.com with SMTP id x2so353114112itf.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 10:59:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170105063705.29290.qmail@ns.sciencehorizons.net>
References: <20170105063705.29290.qmail@ns.sciencehorizons.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Jan 2017 10:59:08 -0800
Message-ID: <CA+55aFyNFb7Ns7O2yjWsKZHOEzgGkyVznp=kLRE9an-mEUC0BQ@mail.gmail.com>
Subject: Re: A use case for MAP_COPY
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@sciencehorizons.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Wed, Jan 4, 2017 at 10:37 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> Back in 2001, Linus had some very negative things to say about MAP_COPY.
> I'm going to try to change that opinion.

Not going to happen.

Basically, the way you can change that opinion is if you can show some
clever zero-cost versioning model that "just work". With an actual
patch.

Because I'm not seeing it.

And without it being zero cost to all the _real_ users, I'm not adding
a MAP_COPY that absolutely nobody will ever use because it's not
standard, and it's not useful enough to them.

We've had a history of failed clever interfaces that end up being very
painful to maintain (splice() being the most obvious one, but we've
had a numebr of filesystem innovations that just didn't work either,
devfs being the most spectacularly bad one).

> I think I have a semantic for MAP_COPY that is both efficiently
> implementable and useful.

The semantic meaning is not my worry. The implementation is.

> The meaning is "For each page in the mapping, a snapshot of the backing
> file is taken at some undefined time between the mmap() call and the
> first access to the mapped memory.  The time of the snapshot may (will!)
> be different for each page.  Once taken, the snapshot will not be affected
> by later writes to the file.

Show me the efficient implementation.

I see the trivial part: at page fault time, just do a COW if the page
has any other users. But to know if it has "users", you now need
another count that distinguishes between plain other mappings or
*writable* mappings (so "mapcount" needs to be split up).

That part is fairly simple, because the "new writable mappings" is
hopefully just in a few places.

But the hard part is for all *other* users that might write to the
page now need to do the cow for somebody else. So it basically
requires a per-page count (possibly just flag) of "this has a copy
mapping", along with everybody who might write to it that currently
just get a ref to the page to check it, and do the rmap thing etc.

And just creating those two new fields is a big problem. We literally
had a long discussion just about getting a single new _bit_ free'd up
in the page flags, because things are so tight. You need two new
fields entirely.

I'm not saying it's impossible. But it's a lot of details (and that
extra field to a very core data structure really is surprisingly
painful) for some very dubious gains. People simply won't be using it.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
