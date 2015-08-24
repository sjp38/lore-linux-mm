Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1C56B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:11:16 -0400 (EDT)
Received: by qkch123 with SMTP id h123so64829115qkc.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:11:16 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id u205si10370676ywa.76.2015.08.24.08.11.15
        for <linux-mm@kvack.org>;
        Mon, 24 Aug 2015 08:11:15 -0700 (PDT)
Date: 24 Aug 2015 11:11:14 -0400
Message-ID: <20150824151114.18743.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 3/3 v4] mm/vmalloc: Cache the vmalloc memory info
In-Reply-To: <21979.6150.929309.800457@quad.stoffel.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john@stoffel.org, mingo@kernel.org
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@horizon.com, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

John Stoffel <john@stoffel.org> wrote:
>> vmap_info_gen should be initialized to 1 to force an initial
>> cache update.

> Blech, it should be initialized with a proper #define
> VMAP_CACHE_NEEDS_UPDATE 1, instead of more magic numbers.

Er... this is a joke, right?

First, this number is used exactly once, and it's not part of a collection
of similar numbers.  And the definition would be adjacent to the use.

We have easier ways of accomplishing that, called "comments".


Second, your proposed name is misleading.  "needs update" is defined
as vmap_info_gen != vmap_info_cache_gen.  There is no particular value
of either that has this meaning.

For example, initializing vmap_info_cache_gen to -1 would do just as well.
(I actually considered that before deciding that +1 was "simpler" than -1.)

For some versions of the code, an *arbitrary* difference is okay.
You could set one ot 0xDEADBEEF and the other to 0xFEEDFACE.

For other versions, the magnitude matters, but not *too* much.
Initializing it to 42 would be perfectly correct, but waste time doing
42 cache updates before settling down.

Singling out the value 1 as VMAP_CACHE_NEEDS_UPDATE is actively misleading.


> This will help keep bugs like this out in the future... I hope!

And this is the punchline, right?

The problem was not realizing that non-default initialization was required;
what we *call* the non-default value is irrelevant.

I doubt it would ever have been a real (i.e. noticeable) bug, actually;
the first bit of vmap activity in very early boot would have invalidated
the cache.


(John, my apologies if I went over the top and am contributing to LKML's
reputation for flaming.  I *did* actually laugh, and *do* think it's a
dumb idea, but my annoyance is really directed at unpleasant memories of
mindless application of coding style guidelines.  In this case, I suspect
you just posted before reading carefully enough to see the subtle logic.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
