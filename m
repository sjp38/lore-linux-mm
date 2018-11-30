Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9696B5A73
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 17:28:48 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id s140so3804543oih.4
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 14:28:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor3418600otn.42.2018.11.30.14.28.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 14:28:47 -0800 (PST)
MIME-Version: 1.0
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275558526.76910.7535251937849268605.stgit@dwillia2-desk3.amr.corp.intel.com>
 <6875ca04-a36a-89ae-825b-f629ab011d47@deltatee.com> <CAPcyv4i9QXsX9Rjz9E3gi643LQbSzaO_+iFLqLS+QO-GmrS0Eg@mail.gmail.com>
 <14d6413c-b002-c152-5016-7ed659c08c24@deltatee.com> <CAPcyv4gZisOAE8VJPJChNXrWv0NhUevWuutsPdvNORBTOBXJfA@mail.gmail.com>
 <43778343-6d43-eb43-0de0-3db6828902d0@deltatee.com> <CAPcyv4hJV71RLhBCKgqc=nQ_D_upySD=ZZk0y=5Qk69kKPHFog@mail.gmail.com>
 <b8ae55a4-7c1a-cc35-beea-badf35a69b06@deltatee.com>
In-Reply-To: <b8ae55a4-7c1a-cc35-beea-badf35a69b06@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 30 Nov 2018 14:28:36 -0800
Message-ID: <CAPcyv4iVCMo29SWM2jhnNTZ5ugYaqjeW_LKe9O2YmeNohwQG3A@mail.gmail.com>
Subject: Re: [PATCH v8 3/7] mm, devm_memremap_pages: Fix shutdown handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Bjorn Helgaas <bhelgaas@google.com>, Stephen Bates <sbates@raithlin.com>

On Fri, Nov 30, 2018 at 2:19 PM Logan Gunthorpe <logang@deltatee.com> wrote:
>
> Hey,
>
> On 2018-11-29 11:51 a.m., Dan Williams wrote:
> > Got it, let me see how bad moving arch_remove_memory() turns out,
> > sounds like a decent approach to coordinate multiple users of a single
> > ref.
>
> I've put together a patch set[1] that fixes all the users of
> devm_memremap_pages() without moving arch_remove_memory(). It's pretty
> clean except for the p2pdma case which is fairly tricky but I don't
> think there's an easy way around that.

The solution I'm trying is to introduce a devm_memremap_pages_remove()
that each user can call after they have called percpu_ref_exit(), it's
just crashing for me currently...

> If you come up with a better solution that's great, otherwise let me
> know and I'll do some clean up and more testing and send this set to the
> lists. Though, we might need to wait for your patch to land before we
> can properly send the fix to it (the first patch in my series)...

I'd say go ahead and send it. We can fix p2pdma as a follow-on. Send
it to Andrew as a patch relative to the current -next tree.
