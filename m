Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99A646B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 15:07:09 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m2-v6so2944651qti.2
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:07:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x5-v6si395308qtb.117.2018.06.27.12.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 12:07:08 -0700 (PDT)
Date: Wed, 27 Jun 2018 22:07:02 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v33 1/4] mm: add a function to get free page blocks
Message-ID: <20180627220402-mutt-send-email-mst@kernel.org>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFzhuGKinEq5udPsk_uYHShkQxJYqcPO=tLCkT-oxpsgPg@mail.gmail.com>
 <20180626045118-mutt-send-email-mst@kernel.org>
 <CA+55aFwFpDPvfL=KPdabO-x1r0FnwpfPk5oN8+e01TKqAPNYbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwFpDPvfL=KPdabO-x1r0FnwpfPk5oN8+e01TKqAPNYbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Wed, Jun 27, 2018 at 09:05:39AM -0700, Linus Torvalds wrote:
> [ Sorry for slow reply, my travels have made a mess of my inbox ]
> 
> On Mon, Jun 25, 2018 at 6:55 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > Linus, do you think it would be ok to have get_from_free_page_list
> > actually pop entries from the free list and use them as the buffer
> > to store PAs?
> 
> Honestly, what I think the best option would be is to get rid of this
> interface *entirely*, and just have the balloon code do
> 
>     #define GFP_MINFLAGS (__GFP_NORETRY | __GFP_NOWARN |
> __GFP_THISNODE | __GFP_NOMEMALLOC)
> 
>     struct page *page =  alloc_pages(GFP_MINFLAGS, MAX_ORDER-1);
> 
>  which is not a new interface, and simply removes the max-order page
> from the list if at all possible.
> 
> The above has the advantage of "just working", and not having any races.
> 
> Now, because you don't want to necessarily *entirely* deplete the max
> order, I'd suggest that the *one* new interface you add is just a "how
> many max-order pages are there" interface. So then you can query
> (either before or after getting the max-order page) just how many of
> them there were and whether you want to give that page back.
> 
> Notice? No need for any page lists or physical addresses. No races. No
> complex new functions.
> 
> The physical address you can just get from the "struct page" you got.
> 
> And if you run out of memory because of getting a page, you get all
> the usual "hey, we ran out of memory" responses..
> 
> Wouldn't the above be sufficient?
> 
>             Linus

I think so, thanks!

Wei, to put it in balloon terms, I think there's one thing we missed: if
you do manage to allocate a page, and you don't have a use for it, then
hey, you can just give it to the host because you know it's free - you
are going to return it to the free list.

-- 
MST
