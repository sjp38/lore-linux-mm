Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE4C6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 20:08:27 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id q71so5883392ywg.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 17:08:27 -0800 (PST)
Received: from ns.sciencehorizons.net (ns.sciencehorizons.net. [71.41.210.147])
        by mx.google.com with SMTP id k13si21085033ywe.451.2017.01.05.17.08.26
        for <linux-mm@kvack.org>;
        Thu, 05 Jan 2017 17:08:26 -0800 (PST)
Date: 5 Jan 2017 20:08:25 -0500
Message-ID: <20170106010825.30586.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: A use case for MAP_COPY
In-Reply-To: <CA+55aFyZtmjsaE_g6TXoqwhBUL-gtt53ARGmpU8eFFZ0wNWDbg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@sciencehorizons.net, torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, riel@surriel.com

> For example, what happens when there is low memory? What you would
> *want* to happen is to just forget the page and read it back in.
> That/s how MAP_PRIVATE works. But that won't actually work for
> MAP_COPY. You'd need to page the thing out, as if you had written to
> it (even though you didn't). Not because you want to, but because your
> versioning scheme depends on it.

Yes, I explained that in the first message.  For memory overcommit
bean-counting purposes, it counts as a copy.  When there's a request to
shrink the page, the process looks like this:

- Page dirty?  Schedule write.
- Page clean, but MAP_COPY?  Drop file mappings, leave dirty anonymous
  page behind.  Optionally (but recommended) add_to_swap() and
  schedule swap-out.
- (From this point, it's a generic anonymous page.)

The net result is no worse than if you'd made a private copy in the
first place.

(In *really* extreme corner cases, point the oom-killer at whoever asked
for MAP_COPY and cannibalize them so the others may live.)

The basic performance goals are:
- If the COW never happens: No slower than, and less memory than,
  making an eager copy up front.
- If the COW happens: Not more than 10x slower than, and no more memory
  than, making an eager copy up front.

The net result is that if the chance of a COW is less than 10%, it's
worth considering.  If the chance of a COW is non-trivial, just do
an eager copy.

> The whole point of MAP_COPY is to avoid a memory copy, but
> if you now end up having to do IO, and having to have a swap device
> for it, it's completely unacceptable. See?

No, I don't see.  I thought I figured that out before posting and
explained it already.  You can do the required virtual copy with no
actual RAM copies; you just have to swap the same page out twice.

The easy way to implement it serializes the two writes, which isn't
ideal, but isn't a disaster, either.

> How are you going to avoid the issues with growing 'struct page'?

At the moment, no idea.  Compared to your profound grokking of the mm,
I'm like one of those mechanics saying "lookit all them WIRES in there!"

I certainly understand that growing struct page is a non-starter.

> So the fact is, it's a horrible idea. I don't think you understand how
> horrible it is. The only way you'll understand is if you try to write
> the patch.

Agreed, I definitely don't understand.  For me, mm/ is a blank spot on
the map marked "Hic sunt dracones."  While that's better than "Lasciate
ogne speranza, voi ch'intrate", it's still very intimidating.  The part
I'm most frightened of is lock ordering.  That's a maze of twisty little
passages.

And the cgroup accounting is likely to be unpleasant in the extreme.

This is definitely a long-term goal.  I have to go and finish the
software that made me wish for this feature first.  And then a lot
of other to-do items.  But I'll start studying.

>  "Siperia opettaa".

Very appropriate aphorism!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
