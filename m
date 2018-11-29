Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06A156B53F1
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:51:20 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id v34so1432619ote.7
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:51:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q13sor1274665otm.98.2018.11.29.10.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 10:51:18 -0800 (PST)
MIME-Version: 1.0
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275558526.76910.7535251937849268605.stgit@dwillia2-desk3.amr.corp.intel.com>
 <6875ca04-a36a-89ae-825b-f629ab011d47@deltatee.com> <CAPcyv4i9QXsX9Rjz9E3gi643LQbSzaO_+iFLqLS+QO-GmrS0Eg@mail.gmail.com>
 <14d6413c-b002-c152-5016-7ed659c08c24@deltatee.com> <CAPcyv4gZisOAE8VJPJChNXrWv0NhUevWuutsPdvNORBTOBXJfA@mail.gmail.com>
 <43778343-6d43-eb43-0de0-3db6828902d0@deltatee.com>
In-Reply-To: <43778343-6d43-eb43-0de0-3db6828902d0@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 29 Nov 2018 10:51:06 -0800
Message-ID: <CAPcyv4hJV71RLhBCKgqc=nQ_D_upySD=ZZk0y=5Qk69kKPHFog@mail.gmail.com>
Subject: Re: [PATCH v8 3/7] mm, devm_memremap_pages: Fix shutdown handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Bjorn Helgaas <bhelgaas@google.com>, Stephen Bates <sbates@raithlin.com>

On Thu, Nov 29, 2018 at 9:51 AM Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
>
> On 2018-11-29 10:30 a.m., Dan Williams wrote:
> > Oh! Yes, nice find. We need to wait for the percpu-ref to be dead and
> > all outstanding references dropped before we can proceed to
> > arch_remove_memory(), and I think this problem has been there since
> > day one because the final exit was always after devm_memremap_pages()
> > release which means arch_remove_memory() was always racing any final
> > put_page(). I'll take a look, it seems the arch_remove_pages() call
> > needs to be moved out-of-line to its own context and wait for the
> > final exit of the percpu-ref.
>
> Ok, well I thought moving the wait_for_completion() into the kill() call
> was a pretty good solution to this.

True, it is...

> Though, if we move the
> arch_remove_pages() into a different context, it *may* help with the
> problem below...

Glad to see my over-engineered proposal in this case might be good for
something...

>
> >> Though, now that I look at it, the current change in question will be
> >> wrong if there are two devm_memremap_pages_release()s to call. Both need
> >> to drop their references before we can wait_for_completion() ;(. I guess
> >> I need multiple percpu_refs or more complex changes to
> >> devm_memremap_pages_release().
> >
> > Can you just have a normal device-level kref for this case? On final
> > device-level kref_put then kill the percpu_ref? I guess the problem is
> > devm semantics where p2pdma only gets one callback on a driver
> > ->remove() event. I'm not sure how to support multiple references of
> > the same pages without creating a non-devm version of
> > devm_memremap_pages(). I'm not opposed to that, but afaiu I don't
> > think p2pdma is compatible with devm as long as it supports N>1:1
> > mappings of the same range.
>
> Hmm, no I think you misunderstood what I said. I'm saying I need to have
> exactly one percpu_ref per call to devm_memremap_pages() and this is
> doable, just slightly annoying. Right now I have one percpu_ref for
> multiple calls to devm_memremap_pages() which doesn't work with the
> above fix because there will always be a wait_for_completion() before
> the last references are dropped in this way:
>
> 1) First devm_memremap_pages_release() is called which drops it's
> reference and waits_for_completion().
>
> 2) The second devm_memremap_pages_release() needs to be called to drop
> it's reference, but can't seeing the first is waiting, and therefore the
> percpu_ref never goes to zero and the wait_for_completion() never returns.
>

Got it, let me see how bad moving arch_remove_memory() turns out,
sounds like a decent approach to coordinate multiple users of a single
ref.
