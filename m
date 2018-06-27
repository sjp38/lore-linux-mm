Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54EF96B0269
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:05:52 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s19-v6so1959032iog.0
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:05:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e6-v6sor1651493ioa.63.2018.06.27.09.05.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 09:05:51 -0700 (PDT)
MIME-Version: 1.0
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-2-git-send-email-wei.w.wang@intel.com> <CA+55aFzhuGKinEq5udPsk_uYHShkQxJYqcPO=tLCkT-oxpsgPg@mail.gmail.com>
 <20180626045118-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180626045118-mutt-send-email-mst@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jun 2018 09:05:39 -0700
Message-ID: <CA+55aFwFpDPvfL=KPdabO-x1r0FnwpfPk5oN8+e01TKqAPNYbw@mail.gmail.com>
Subject: Re: [PATCH v33 1/4] mm: add a function to get free page blocks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

[ Sorry for slow reply, my travels have made a mess of my inbox ]

On Mon, Jun 25, 2018 at 6:55 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> Linus, do you think it would be ok to have get_from_free_page_list
> actually pop entries from the free list and use them as the buffer
> to store PAs?

Honestly, what I think the best option would be is to get rid of this
interface *entirely*, and just have the balloon code do

    #define GFP_MINFLAGS (__GFP_NORETRY | __GFP_NOWARN |
__GFP_THISNODE | __GFP_NOMEMALLOC)

    struct page *page =  alloc_pages(GFP_MINFLAGS, MAX_ORDER-1);

 which is not a new interface, and simply removes the max-order page
from the list if at all possible.

The above has the advantage of "just working", and not having any races.

Now, because you don't want to necessarily *entirely* deplete the max
order, I'd suggest that the *one* new interface you add is just a "how
many max-order pages are there" interface. So then you can query
(either before or after getting the max-order page) just how many of
them there were and whether you want to give that page back.

Notice? No need for any page lists or physical addresses. No races. No
complex new functions.

The physical address you can just get from the "struct page" you got.

And if you run out of memory because of getting a page, you get all
the usual "hey, we ran out of memory" responses..

Wouldn't the above be sufficient?

            Linus
