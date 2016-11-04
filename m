Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D24A280269
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 23:58:11 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 20so48399352uak.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 20:58:11 -0700 (PDT)
Received: from mail-vk0-x234.google.com (mail-vk0-x234.google.com. [2607:f8b0:400c:c05::234])
        by mx.google.com with ESMTPS id a93si3798089uaa.116.2016.11.03.20.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 20:58:10 -0700 (PDT)
Received: by mail-vk0-x234.google.com with SMTP id w194so57429383vkw.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 20:58:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161103231018.GA85121@google.com>
References: <20161103181624.GA63852@google.com> <CALCETrUPuunBT1Zo25wyOwqaWJ=rm9R-WMZGN-7u4-dsdokAnQ@mail.gmail.com>
 <20161103211207.GB63852@google.com> <20161103231018.GA85121@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 3 Nov 2016 20:57:49 -0700
Message-ID: <CALCETrV=9vXDyQ5F5-bFD4YCn5P_j7jmYj2Tv+DXWH43m31NzA@mail.gmail.com>
Subject: Re: vmalloced stacks and scatterwalk_map_and_copy()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers@google.com>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Lutomirski <luto@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Nov 3, 2016 at 4:10 PM, Eric Biggers <ebiggers@google.com> wrote:
> On Thu, Nov 03, 2016 at 02:12:07PM -0700, Eric Biggers wrote:
>> On Thu, Nov 03, 2016 at 01:30:49PM -0700, Andy Lutomirski wrote:
>> >
>> > Also, Herbert, it seems like the considerable majority of the crypto
>> > code is acting on kernel virtual memory addresses and does software
>> > processing.  Would it perhaps make sense to add a kvec-based or
>> > iov_iter-based interface to the crypto code?  I bet it would be quite
>> > a bit faster and it would make crypto on stack buffers work directly.
>>
>> I'd like to hear Herbert's opinion on this too, but as I understand it, if a
>> symmetric cipher API operating on virtual addresses was added, similar to the
>> existing "shash" API it would only allow software processing.  Whereas with the
>> current API you can request a transform and use it the same way regardless of
>> whether the crypto framework has chosen a software or hardware implementation,
>> or a combination thereof.  If this wasn't a concern then I expect using virtual
>> addresses would indeed simplify things a lot, at least for users not already
>> working with physical memory (struct page).
>>
>> Either way, in the near term it looks like 4.9 will be released with the new
>> behavior that encryption/decryption is not supported on stack buffers.
>> Separately from the scatterwalk_map_and_copy() issue, today I've found two
>> places in the filesystem-level encryption code that do encryption on stack
>> buffers and therefore hit the 'BUG_ON(!virt_addr_valid(buf));' in sg_set_buf().
>> I will be sending patches to fix these, but I suspect there may be more crypto
>> API users elsewhere that have this same problem.
>>
>> Eric
>
> [Added linux-mm to Cc]
>
> For what it's worth, grsecurity has a special case to allow a scatterlist entry
> to be created from a stack buffer:
>
>         static inline void sg_set_buf(struct scatterlist *sg, const void *buf,
>                                       unsigned int buflen)
>         {
>                 const void *realbuf = buf;
>
>         #ifdef CONFIG_GRKERNSEC_KSTACKOVERFLOW
>                 if (object_starts_on_stack(buf))
>                         realbuf = buf - current->stack + current->lowmem_stack;
>         #endif
>
>         #ifdef CONFIG_DEBUG_SG
>                 BUG_ON(!virt_addr_valid(realbuf));
>         #endif
>                 sg_set_page(sg, virt_to_page(realbuf), buflen, offset_in_page(realbuf));
>         }

Yes, that's how grsecurity works.  The upstream version is going to do
it right instead of hacking around it.

> I don't know about all the relative merits of the two approaches.  But one of
> the things that will need to be done with the currently upstream approach is
> that all callers of sg_set_buf() will need to be checked to make sure they
> aren't using stack addresses, and any that are will need to be updated to do
> otherwise, e.g. by using heap-allocated memory.

I tried to do this, but I may have missed a couple example.

>  I suppose this is already
> happening, but in the case of the crypto API it will probably take a while for
> all the users to be identified and updated.  (And it's not always clear from the
> local context whether something can be stack memory or not, e.g. the memory for
> crypto request objects may be either.)

The crypto request objects can live on the stack just fine.  It's the
request buffers that need to live elsewhere (or the alternative
interfaces can be used, or the crypto core code can start using
something other than scatterlists).

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
