Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B80896B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 16:58:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7-v6so15070542pfi.8
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 13:58:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k13-v6si1512361pfd.97.2018.06.01.13.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Jun 2018 13:58:40 -0700 (PDT)
Date: Fri, 1 Jun 2018 13:58:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
Message-ID: <20180601205837.GB29651@bombadil.infradead.org>
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com>
 <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com>
 <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, Anton Eidelman <anton@lightbitslabs.com>, Linux-MM <linux-mm@kvack.org>, linux-hardened@lists.openwall.com

On Fri, Jun 01, 2018 at 01:49:38PM -0700, Kees Cook wrote:
> On Fri, Jun 1, 2018 at 12:02 PM, Laura Abbott <labbott@redhat.com> wrote:
> > (cc-ing some interested people)
> >
> >
> >
> > On 05/31/2018 05:03 PM, Anton Eidelman wrote:
> >> Here's a rare issue I reproduce on 4.12.10 (centos config): full log
> >> sample below.
> 
> Thanks for digging into this! Do you have any specific reproducer for
> this? If so, I'd love to try a bisection, as I'm surprised this has
> only now surfaced: hardened usercopy was introduced in 4.8 ...
> 
> >> An innocent process (dhcpclient) is about to receive a datagram, but
> >> during skb_copy_datagram_iter() usercopy triggers a BUG in:
> >> usercopy.c:check_heap_object() -> slub.c:__check_heap_object(), because
> >> the sk_buff fragment being copied crosses the 64-byte slub object boundary.
> >>
> >> Example __check_heap_object() context:
> >>    n=128    << usually 128, sometimes 192.
> >>    object_size=64
> >>    s->size=64
> >>    page_address(page)=0xffff880233f7c000
> >>    ptr=0xffff880233f7c540
> >>
> >> My take on the root cause:
> >>    When adding data to an skb, new data is appended to the current
> >> fragment if the new chunk immediately follows the last one: by simply
> >> increasing the frag->size, skb_frag_size_add().
> >>    See include/linux/skbuff.h:skb_can_coalesce() callers.
> 
> Oooh, sneaky:
>                 return page == skb_frag_page(frag) &&
>                        off == frag->page_offset + skb_frag_size(frag);
> 
> Originally I was thinking that slab red-zoning would get triggered
> too, but I see the above is checking to see if these are precisely
> neighboring allocations, I think.
> 
> But then ... how does freeing actually work? I'm really not sure how
> this seeming layering violation could be safe in other areas?

I'm confused ... I thought skb frags came from the page_frag allocator,
not the slab allocator.  But then why would the slab hardening trigger?

> > The analysis makes sense. Kees, any thoughts about what
> > we might do? It seems unlikely we can fix the networking
> > code so do we need some kind of override in usercopy?
> 
> If this really is safe against kfree(), then I'd like to find the
> logic that makes it safe and either teach skb_can_coalesce() different
> rules (i.e. do not cross slab objects) or teach __check_heap_object()
> about skb... which seems worse. Wheee.
> 
> -Kees
> 
> -- 
> Kees Cook
> Pixel Security
> 
