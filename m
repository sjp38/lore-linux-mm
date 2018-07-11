Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B406B0007
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 21:44:47 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k187-v6so10259206ita.1
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:44:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11-v6sor6558764iob.59.2018.07.10.18.44.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 18:44:45 -0700 (PDT)
MIME-Version: 1.0
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com> <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
 <5B455D50.90902@intel.com>
In-Reply-To: <5B455D50.90902@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 10 Jul 2018 18:44:34 -0700
Message-ID: <CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Tue, Jul 10, 2018 at 6:24 PM Wei Wang <wei.w.wang@intel.com> wrote:
>
> We only get addresses of the "MAX_ORDER-1" blocks into the array. The
> max size of the array that could be allocated by kmalloc is
> KMALLOC_MAX_SIZE (i.e. 4MB on x86). With that max array, we could load
> "4MB / sizeof(u64)" addresses of "MAX_ORDER-1" blocks, that is, 2TB free
> memory at most. We thought about removing that 2TB limitation by passing
> in multiple such max arrays (a list of them).

No.

Stop this already./

You're doing everthing wrong.

If the array has to describe *all* memory you will ever free, then you
have already lost.

Just do it in chunks.

I don't want the VM code to even fill in that big of an array anyway -
this all happens under the zone lock, and you're walking a list that
is bad for caching anyway.

So plan on an interface that allows _incremental_ freeing, because any
plan that starts with "I worry that maybe two TERABYTES of memory
isn't big enough" is so broken that it's laughable.

That was what I tried to encourage with actually removing the pages
form the page list. That would be an _incremental_ interface. You can
remove MAX_ORDER-1 pages one by one (or a hundred at a time), and mark
them free for ballooning that way. And if you still feel you have tons
of free memory, just continue removing more pages from the free list.

Notice? Incremental. Not "I want to have a crazy array that is enough
to hold 2TB at one time".

So here's the rule:

 - make it a simple array interface

 - make the array *small*. Not megabytes. Kilobytes. Because if you're
filling in megabytes worth of free pointers while holding the zone
lock, you're doing something wrong.

 - design the interface so that you do not *need* to have this crazy
"all or nothing" approach.

See what I'm trying to push for. Think "low latency". Think "small
arrays". Think "simple and straightforward interfaces".

At no point should you ever worry about "2TB". Never.

           Linus
