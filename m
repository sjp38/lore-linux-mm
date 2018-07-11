Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E27E26B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 00:00:47 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y130-v6so29793613qka.1
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 21:00:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g22-v6si5049530qto.401.2018.07.10.21.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 21:00:46 -0700 (PDT)
Date: Wed, 11 Jul 2018 07:00:37 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
Message-ID: <20180711064709-mutt-send-email-mst@kernel.org>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On Tue, Jul 10, 2018 at 10:33:08AM -0700, Linus Torvalds wrote:
> NAK.
> 
> On Tue, Jul 10, 2018 at 2:56 AM Wei Wang <wei.w.wang@intel.com> wrote:
> >
> > +
> > +       buf_page = list_first_entry_or_null(pages, struct page, lru);
> > +       if (!buf_page)
> > +               return -EINVAL;
> > +       buf = (__le64 *)page_address(buf_page);
> 
> Stop this garbage.
> 
> Why the hell would you pass in some crazy "liost of pages" that uses
> that lru list?
> 
> That's just insane shit.
> 
> Just pass in a an array to fill in.
> No idiotic games like this with
> odd list entries (what's the locking?) and crazy casting to
> 
> So if you want an array of page addresses, pass that in as such. If
> you want to do it in a page, do it with
> 
>     u64 *array = page_address(page);
>     int nr = PAGE_SIZE / sizeof(u64);
> 
> and now you pass that array in to the thing. None of this completely
> insane crazy crap interfaces.

Question was raised what to do if there are so many free
MAX_ORDER pages that their addresses don't fit in a single MAX_ORDER
page. Yes, only a huge guest would trigger that but it seems
theoretically possible.

I guess an array of arrays then?

An alternative suggestion was not to pass an array at all,
instead peel enough pages off the list to contain
all free entries. Maybe that's too hacky.


> 
> Plus, I still haven't heard an explanation for why you want so many
> pages in the first place, and why you want anything but MAX_ORDER-1.
> 
> So no. This kind of unnecessarily complex code with completely insane
> calling interfaces does not make it into the VM layer.
> 
> Maybe that crazy "let's pass a chain of pages that uses the lru list"
> makes sense to the virtio-balloon code. But you need to understand
> that it makes ZERO conceptual sense to anybody else. And the core VM
> code is about a million times more important than the balloon code in
> this case, so you had better make the interface make sense to *it*.
> 
>                Linus
