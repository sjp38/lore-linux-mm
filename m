Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFC86B0003
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 17:55:24 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id 2-v6so5678701vkc.3
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 14:55:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4-v6sor19129023uae.20.2018.06.01.14.55.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 14:55:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180601205837.GB29651@bombadil.infradead.org>
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com>
 <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com> <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com>
 <20180601205837.GB29651@bombadil.infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 1 Jun 2018 14:55:21 -0700
Message-ID: <CAGXu5jLvN5bmakZ3aDu4TRB9+_DYVaCX2LTLtKvsqgYpjMaNsA@mail.gmail.com>
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Laura Abbott <labbott@redhat.com>, Anton Eidelman <anton@lightbitslabs.com>, Linux-MM <linux-mm@kvack.org>, linux-hardened@lists.openwall.com

On Fri, Jun 1, 2018 at 1:58 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Jun 01, 2018 at 01:49:38PM -0700, Kees Cook wrote:
>> On Fri, Jun 1, 2018 at 12:02 PM, Laura Abbott <labbott@redhat.com> wrote:
>> > (cc-ing some interested people)
>> >
>> >
>> >
>> > On 05/31/2018 05:03 PM, Anton Eidelman wrote:
>> >> Here's a rare issue I reproduce on 4.12.10 (centos config): full log
>> >> sample below.
>>
>> Thanks for digging into this! Do you have any specific reproducer for
>> this? If so, I'd love to try a bisection, as I'm surprised this has
>> only now surfaced: hardened usercopy was introduced in 4.8 ...
>>
>> >> An innocent process (dhcpclient) is about to receive a datagram, but
>> >> during skb_copy_datagram_iter() usercopy triggers a BUG in:
>> >> usercopy.c:check_heap_object() -> slub.c:__check_heap_object(), because
>> >> the sk_buff fragment being copied crosses the 64-byte slub object boundary.
>> >>
>> >> Example __check_heap_object() context:
>> >>    n=128    << usually 128, sometimes 192.
>> >>    object_size=64
>> >>    s->size=64
>> >>    page_address(page)=0xffff880233f7c000
>> >>    ptr=0xffff880233f7c540
>> >>
>> >> My take on the root cause:
>> >>    When adding data to an skb, new data is appended to the current
>> >> fragment if the new chunk immediately follows the last one: by simply
>> >> increasing the frag->size, skb_frag_size_add().
>> >>    See include/linux/skbuff.h:skb_can_coalesce() callers.
>>
>> Oooh, sneaky:
>>                 return page == skb_frag_page(frag) &&
>>                        off == frag->page_offset + skb_frag_size(frag);
>>
>> Originally I was thinking that slab red-zoning would get triggered
>> too, but I see the above is checking to see if these are precisely
>> neighboring allocations, I think.
>>
>> But then ... how does freeing actually work? I'm really not sure how
>> this seeming layering violation could be safe in other areas?
>
> I'm confused ... I thought skb frags came from the page_frag allocator,
> not the slab allocator.  But then why would the slab hardening trigger?

Well that would certainly make more sense (well, the sense about
alloc/free). Having it overlap with a slab allocation, though, that's
quite bad. Perhaps this is a very odd use-after-free case? I.e. freed
page got allocated to slab, and when it got copied out, usercopy found
it spanned a slub object?

[ 655.602500] usercopy: kernel memory exposure attempt detected from
ffff88022a31aa00 (kmalloc-64) (192 bytes)

This wouldn't be the first time usercopy triggered due to a memory corruption...

-Kees

-- 
Kees Cook
Pixel Security
