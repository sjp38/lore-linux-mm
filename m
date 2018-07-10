Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0BC76B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 13:33:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x14-v6so19786949ioa.6
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 10:33:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x25-v6sor6967224iob.83.2018.07.10.10.33.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 10:33:20 -0700 (PDT)
MIME-Version: 1.0
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com> <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 10 Jul 2018 10:33:08 -0700
Message-ID: <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

NAK.

On Tue, Jul 10, 2018 at 2:56 AM Wei Wang <wei.w.wang@intel.com> wrote:
>
> +
> +       buf_page = list_first_entry_or_null(pages, struct page, lru);
> +       if (!buf_page)
> +               return -EINVAL;
> +       buf = (__le64 *)page_address(buf_page);

Stop this garbage.

Why the hell would you pass in some crazy "liost of pages" that uses
that lru list?

That's just insane shit.

Just pass in a an array to fill in. No idiotic games like this with
odd list entries (what's the locking?) and crazy casting to

So if you want an array of page addresses, pass that in as such. If
you want to do it in a page, do it with

    u64 *array = page_address(page);
    int nr = PAGE_SIZE / sizeof(u64);

and now you pass that array in to the thing. None of this completely
insane crazy crap interfaces.

Plus, I still haven't heard an explanation for why you want so many
pages in the first place, and why you want anything but MAX_ORDER-1.

So no. This kind of unnecessarily complex code with completely insane
calling interfaces does not make it into the VM layer.

Maybe that crazy "let's pass a chain of pages that uses the lru list"
makes sense to the virtio-balloon code. But you need to understand
that it makes ZERO conceptual sense to anybody else. And the core VM
code is about a million times more important than the balloon code in
this case, so you had better make the interface make sense to *it*.

               Linus
