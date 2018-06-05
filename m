Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C69A6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 10:51:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u73-v6so2660193qku.12
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 07:51:24 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id q1-v6si1900400qve.94.2018.06.05.07.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 07:51:22 -0700 (PDT)
Date: Tue, 5 Jun 2018 14:51:22 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
In-Reply-To: <20180601205837.GB29651@bombadil.infradead.org>
Message-ID: <01000163d06e5616-69f9336a-c45d-4aa0-9ff1-76354b8949e2-000000@email.amazonses.com>
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com> <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com> <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com> <20180601205837.GB29651@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Anton Eidelman <anton@lightbitslabs.com>, Linux-MM <linux-mm@kvack.org>, linux-hardened@lists.openwall.com

On Fri, 1 Jun 2018, Matthew Wilcox wrote:

> > >> My take on the root cause:
> > >>    When adding data to an skb, new data is appended to the current
> > >> fragment if the new chunk immediately follows the last one: by simply
> > >> increasing the frag->size, skb_frag_size_add().
> > >>    See include/linux/skbuff.h:skb_can_coalesce() callers.
> >
> > Oooh, sneaky:
> >                 return page == skb_frag_page(frag) &&
> >                        off == frag->page_offset + skb_frag_size(frag);
> >
> > Originally I was thinking that slab red-zoning would get triggered
> > too, but I see the above is checking to see if these are precisely
> > neighboring allocations, I think.
> >
> > But then ... how does freeing actually work? I'm really not sure how
> > this seeming layering violation could be safe in other areas?

So if there are two neighboring slab objects that the page struct
addresses will match and the network code will coalesce the objects even
if they are in two different slab objects?

The check in skb_can_coalesce() must verify that these are distinct slab
object. Simple thing would be to return false if one object is a slab
object but then the coalescing would not work in a single slab object
either.

So what needs to happen is that we need to check if this is

1) A Page. Then the proper length of the segment within we can coalesce is
the page size.

2) A slab page. Then we can use ksize() to establish the end of the slab
object and we should only coalesce within that boundary.
