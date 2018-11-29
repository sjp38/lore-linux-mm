Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 66C4A6B53CE
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:50:55 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id d63so2714360iog.4
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:50:55 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id b17si1564697ioc.42.2018.11.29.09.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Nov 2018 09:50:54 -0800 (PST)
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275558526.76910.7535251937849268605.stgit@dwillia2-desk3.amr.corp.intel.com>
 <6875ca04-a36a-89ae-825b-f629ab011d47@deltatee.com>
 <CAPcyv4i9QXsX9Rjz9E3gi643LQbSzaO_+iFLqLS+QO-GmrS0Eg@mail.gmail.com>
 <14d6413c-b002-c152-5016-7ed659c08c24@deltatee.com>
 <CAPcyv4gZisOAE8VJPJChNXrWv0NhUevWuutsPdvNORBTOBXJfA@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <43778343-6d43-eb43-0de0-3db6828902d0@deltatee.com>
Date: Thu, 29 Nov 2018 10:50:46 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gZisOAE8VJPJChNXrWv0NhUevWuutsPdvNORBTOBXJfA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v8 3/7] mm, devm_memremap_pages: Fix shutdown handling
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Bjorn Helgaas <bhelgaas@google.com>, Stephen Bates <sbates@raithlin.com>



On 2018-11-29 10:30 a.m., Dan Williams wrote:
> Oh! Yes, nice find. We need to wait for the percpu-ref to be dead and
> all outstanding references dropped before we can proceed to
> arch_remove_memory(), and I think this problem has been there since
> day one because the final exit was always after devm_memremap_pages()
> release which means arch_remove_memory() was always racing any final
> put_page(). I'll take a look, it seems the arch_remove_pages() call
> needs to be moved out-of-line to its own context and wait for the
> final exit of the percpu-ref.

Ok, well I thought moving the wait_for_completion() into the kill() call
was a pretty good solution to this. Though, if we move the
arch_remove_pages() into a different context, it *may* help with the
problem below...

>> Though, now that I look at it, the current change in question will be
>> wrong if there are two devm_memremap_pages_release()s to call. Both need
>> to drop their references before we can wait_for_completion() ;(. I guess
>> I need multiple percpu_refs or more complex changes to
>> devm_memremap_pages_release().
> 
> Can you just have a normal device-level kref for this case? On final
> device-level kref_put then kill the percpu_ref? I guess the problem is
> devm semantics where p2pdma only gets one callback on a driver
> ->remove() event. I'm not sure how to support multiple references of
> the same pages without creating a non-devm version of
> devm_memremap_pages(). I'm not opposed to that, but afaiu I don't
> think p2pdma is compatible with devm as long as it supports N>1:1
> mappings of the same range.

Hmm, no I think you misunderstood what I said. I'm saying I need to have
exactly one percpu_ref per call to devm_memremap_pages() and this is
doable, just slightly annoying. Right now I have one percpu_ref for
multiple calls to devm_memremap_pages() which doesn't work with the
above fix because there will always be a wait_for_completion() before
the last references are dropped in this way:

1) First devm_memremap_pages_release() is called which drops it's
reference and waits_for_completion().

2) The second devm_memremap_pages_release() needs to be called to drop
it's reference, but can't seeing the first is waiting, and therefore the
percpu_ref never goes to zero and the wait_for_completion() never returns.

Logan
