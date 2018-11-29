Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D21D6B53A3
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:30:34 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id s12so1277064otc.12
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:30:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 13sor1176066otm.32.2018.11.29.09.30.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 09:30:33 -0800 (PST)
MIME-Version: 1.0
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275558526.76910.7535251937849268605.stgit@dwillia2-desk3.amr.corp.intel.com>
 <6875ca04-a36a-89ae-825b-f629ab011d47@deltatee.com> <CAPcyv4i9QXsX9Rjz9E3gi643LQbSzaO_+iFLqLS+QO-GmrS0Eg@mail.gmail.com>
 <14d6413c-b002-c152-5016-7ed659c08c24@deltatee.com>
In-Reply-To: <14d6413c-b002-c152-5016-7ed659c08c24@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 29 Nov 2018 09:30:20 -0800
Message-ID: <CAPcyv4gZisOAE8VJPJChNXrWv0NhUevWuutsPdvNORBTOBXJfA@mail.gmail.com>
Subject: Re: [PATCH v8 3/7] mm, devm_memremap_pages: Fix shutdown handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Bjorn Helgaas <bhelgaas@google.com>, Stephen Bates <sbates@raithlin.com>

On Thu, Nov 29, 2018 at 9:07 AM Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
>
> On 2018-11-28 8:10 p.m., Dan Williams wrote:
> > Yes, please send a proper patch.
>
> Ok, I'll send one shortly.
>
> > Although, I'm still not sure I see
> > the problem with the order of the percpu-ref kill. It's likely more
> > efficient to put the kill after the put_page() loop because the
> > percpu-ref will still be in "fast" per-cpu mode, but the kernel panic
> > should not be possible as long as their is a wait_for_completion()
> > before the exit, unless something else is wrong.
>
> The series of events looks something like this:
>
> 1) Some p2pdma user calls pci_alloc_p2pmem() to get some memory to DMA
> to taking a reference to the pgmap.
> 2) Another process unbinds the underlying p2pdma driver and the devm
> chain starts to unwind.
> 3) devm_memremap_pages_release() is called and it kills the reference
> and drop's it's last reference.

Oh! Yes, nice find. We need to wait for the percpu-ref to be dead and
all outstanding references dropped before we can proceed to
arch_remove_memory(), and I think this problem has been there since
day one because the final exit was always after devm_memremap_pages()
release which means arch_remove_memory() was always racing any final
put_page(). I'll take a look, it seems the arch_remove_pages() call
needs to be moved out-of-line to its own context and wait for the
final exit of the percpu-ref.

> 4) arch_remove_memory() is called which will remove all the struct pages.
> 5) We eventually get to pci_p2pdma_release() where we wait for the
> completion indicating all the pages have been freed.
> 6) The user in (1) tries to use the page that has been removed,
> typically by calling pci_p2pdma_map_sg(), but the page doesn't exist so
> the kernel panics.
>
> So we really need the wait in (5) to occur before (4) but after (3) so
> that the pages continue to exist until the last reference is dropped.
>
> > Certainly you can't move the wait_for_completion() into your ->kill()
> > callback without switching the ordering, but I'm not on board with
> > that change until I understand a bit more about why you think
> > device-dax might be broken?
> >
> > I took a look at the p2pdma shutdown path and the:
> >
> >         if (percpu_ref_is_dying(ref))
> >                 return;
> > ...looks fishy. If multiple agents can overlap their requests for the
> > same range why not track that simply as additional refs? Could it be
> > the crash that you are seeing is a result of mis-accounting when it is
> > safe to assume the page allocation can be freed?
>
> Yeah, someone else mentioned the same thing during review but if I
> remove it, there can be a double kill() on a hypothetical driver that
> might call pci_p2pdma_add_resource() twice. The issue is we only have
> one percpu_ref per device not one per range/BAR.
>
> Though, now that I look at it, the current change in question will be
> wrong if there are two devm_memremap_pages_release()s to call. Both need
> to drop their references before we can wait_for_completion() ;(. I guess
> I need multiple percpu_refs or more complex changes to
> devm_memremap_pages_release().

Can you just have a normal device-level kref for this case? On final
device-level kref_put then kill the percpu_ref? I guess the problem is
devm semantics where p2pdma only gets one callback on a driver
->remove() event. I'm not sure how to support multiple references of
the same pages without creating a non-devm version of
devm_memremap_pages(). I'm not opposed to that, but afaiu I don't
think p2pdma is compatible with devm as long as it supports N>1:1
mappings of the same range.
