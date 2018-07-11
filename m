Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACBB36B0266
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:24:06 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w23-v6so12983745iob.18
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:24:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6-v6sor7836876iob.244.2018.07.11.09.24.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 09:24:05 -0700 (PDT)
MIME-Version: 1.0
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com> <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
 <5B455D50.90902@intel.com> <CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com>
 <20180711092152.GE20050@dhcp22.suse.cz>
In-Reply-To: <20180711092152.GE20050@dhcp22.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 11 Jul 2018 09:23:54 -0700
Message-ID: <CA+55aFwku2tDH4+rfaC67xc4-cEwSrXgnQaci=e2id5ZCRE9JQ@mail.gmail.com>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Wed, Jul 11, 2018 at 2:21 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> We already have an interface for that. alloc_pages(GFP_NOWAIT, MAX_ORDER -1).
> So why do we need any array based interface?

That was actually my original argument in the original thread - that
the only new interface people might want is one that just tells how
many of those MAX_ORDER-1 pages there are.

See the thread in v33 with the subject

  "[PATCH v33 1/4] mm: add a function to get free page blocks"

and look for me suggesting just using

    #define GFP_MINFLAGS (__GFP_NORETRY | __GFP_NOWARN |
__GFP_THISNODE | __GFP_NOMEMALLOC)

    struct page *page =  alloc_pages(GFP_MINFLAGS, MAX_ORDER-1);

for this all.

But I could also see an argument for "allocate N pages of size
MAX_ORDER-1", with some small N, simply because I can see the
advantage of not taking and releasing the locking and looking up the
zone individually N times.

If you want to get gigabytes of memory (or terabytes), doing it in
bigger chunks than one single maximum-sized page sounds fairly
reasonable.

I just don't think that "thousands of pages" is reasonable. But "tens
of max-sized pages" sounds fair enough to me, and it would certainly
not be a pain for the VM.

So I'm open to new interfaces. I just want those new interfaces to
make sense, and be low latency and simple for the VM to do. I'm
objecting to the incredibly baroque and heavy-weight one that can
return near-infinite amounts of memory.

The real advantage of jjuist the existing "alloc_pages()" model is
that I think the ballooning people can use that to *test* things out.
If it turns out that taking and releasing the VM locks is a big cost,
we can see if a batch interface that allows you to get tens of pages
at the same time is worth it.

So yes, I'd suggest starting with just the existing alloc_pages. Maybe
it's not enough, but it should be good enough for testing.

                    Linus
