Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A43E8C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 18:36:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27CC32146F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 18:36:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jRjwVcrQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27CC32146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9754C6B0003; Mon,  1 Jul 2019 14:36:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 927858E0003; Mon,  1 Jul 2019 14:36:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EE0C8E0002; Mon,  1 Jul 2019 14:36:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f77.google.com (mail-ua1-f77.google.com [209.85.222.77])
	by kanga.kvack.org (Postfix) with ESMTP id 581026B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 14:36:16 -0400 (EDT)
Received: by mail-ua1-f77.google.com with SMTP id j22so2490651uaq.5
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 11:36:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ME/BMFz6NjZC07J0/XWrhiS+OPbFaTEtUu/72plFOIs=;
        b=T3cFQHUFwzypaXB7ZropiXEkAhU8lTugNO69P7cl5hIa7D1KAcmcVS+m6QfbHZuE7K
         oI+OcuaSqhOgYW8BD23wY5KXCa4xXlGnArw1th/WsvzcegWD4fVs9+a3IrwVQIsIXB1v
         99loRyysBPcRO5+SNXvZStsFV7LKYdpGKiw0Y5/9nZ24GPziJRlSqYi82PxvFB+LlemU
         f/XQBayowhBp2V9BQYuQxD/CEehIcyzjoevQgQsKGWTqnuZdrz9KrcAQblo1s4469yxn
         69OzBknLSAID8D2GFm7Xo9vYteq3zZ4+j3mq+UfDJHq/vxNbWzwhPZsp7wWzmRsT2FIk
         VlzQ==
X-Gm-Message-State: APjAAAWLUaw2uAnZ1DB6oW8z6QgdyqCAxC+v+LXgnV3nekjalFP3gPPR
	Xoyc8/YUFhuII1lXdZhDhsDd9AOUxfIO2DPbUYOr67nKATgDXfvE98RONXuv8gyZrffR7ihTMLr
	vOzRh1iKQeCwMshdFSDmu+8BIi61MmAPvGNGSnyD3v7V3lZ97H6Cj5Q2cBN2ICkh+qA==
X-Received: by 2002:a67:db02:: with SMTP id z2mr13973581vsj.211.1562006175992;
        Mon, 01 Jul 2019 11:36:15 -0700 (PDT)
X-Received: by 2002:a67:db02:: with SMTP id z2mr13973538vsj.211.1562006175115;
        Mon, 01 Jul 2019 11:36:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562006175; cv=none;
        d=google.com; s=arc-20160816;
        b=myzdRq3eYyj7n3L0uDfsz7baQJkNZewdDJpoe+Ym7tHV2uUPWVHUB1eGlZ+Wy6YOz/
         b8dmoaX3rwNYHePYyS3BkEpMhkt46vjR5uYIW8FdxuSUDAJGInmQLomADB6PDdR8VHtd
         xkI44QcQWmdhhserb1sFezQTaFJa0IeoTR6I9keJWrCHOxi1O614Y/YDqR9AoB3+2yjI
         p6TZ3yoALMmSpUE8wZENK5xdLew2nGUj4UmUQ8oq2ita6jyDcUeMml21Q6nN+DLQFdjs
         FjxFhRAnjDkH0UxzycGToFLHtc6c0haZMndBYKfoMbrkwjWdSrKw+ukakz0jpiUWvOyp
         Sr0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ME/BMFz6NjZC07J0/XWrhiS+OPbFaTEtUu/72plFOIs=;
        b=W3jTS1iOcP8bpGjjcDmHlft0BlRRTpOecTXPOfBwNn28zBHtNN52B/sF/pE62PiWNp
         gckI81KBu/BaI02Fg1QrSleQuWMAanHLo4a9b5ELIkqcEGzUl98RT0H9cnsru4Bax8+K
         h3m2ntWm5CeGayrbEu3mUN9rSkFbau2GTIHH+tPYwJtcgJ90lVkKwyzpfS60MewXd3cS
         MIKbB00lm4uQAOjgZszdzNa2A51FNVPoV6CuhC0s7+MXClNq42WkM0d93yjoUl5f9TDQ
         iiF1ZZZMnsDMRW0aYEfX3uPEBU8XNxLfRws4N/lO70py3aFhbLnT0dVYMjrREQVEeTcA
         tu4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jRjwVcrQ;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d64sor3202624vkd.40.2019.07.01.11.36.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 11:36:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jRjwVcrQ;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ME/BMFz6NjZC07J0/XWrhiS+OPbFaTEtUu/72plFOIs=;
        b=jRjwVcrQqXZNLpn3VqHQ3MNa85+tUsohQg8XyZGRfIVSN9Dg4ifRAkBUmZRDluUndU
         DwyOoDiibj9Hqm0vxcf9whB4JTjNMbHhRhF7Zt3xAQE4EnxfNeP0slrYel8Kh8TdNCDz
         3rakNvIy/gyaTwUK+L28P6T36xww+8w7c/VJsP9Bui57GEXN9W0EhTeMdYCN+SKfFczz
         Ij3FEA4vevsqUeueZwJSjsQW8vQ6TBmGJAiGYuy6ZJXP3KS0BByhUboKXHO6jxGNMem+
         hSOrrt0L509dYmb6kxlKdzNf4AqXAurpg39HNaSvBIW8+ccaColJ3RJauD3Uru+EK5kC
         4RvQ==
X-Google-Smtp-Source: APXvYqxHi98I0sWxmIGmh3jNQhZD68UapxsiPklkNgaXVkZVV94WssxNS+ZXvzcSmlI/hWtXHMrtuNrf4wiVPtP41OQ=
X-Received: by 2002:a1f:2896:: with SMTP id o144mr3294269vko.73.1562006174652;
 Mon, 01 Jul 2019 11:36:14 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
 <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
 <20190626175131.GA17250@infradead.org> <CACDBo56fNVxVyNEGtKM+2R0X7DyZrrHMQr6Yw4NwJ6USjD5Png@mail.gmail.com>
 <c9fe4253-5698-a226-c643-32a21df8520a@arm.com> <CACDBo57CcYQmNrsTdMbax27nbLyeMQu4kfKZOzNczNcnde9g3Q@mail.gmail.com>
In-Reply-To: <CACDBo57CcYQmNrsTdMbax27nbLyeMQu4kfKZOzNczNcnde9g3Q@mail.gmail.com>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Tue, 2 Jul 2019 00:06:03 +0530
Message-ID: <CACDBo54TUut15pr0pJ_6TcQxu-wc5uo5vEJ+bsU6L=abBoN80Q@mail.gmail.com>
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, 
	linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 1, 2019 at 11:17 PM Pankaj Suryawanshi
<pankajssuryawanshi@gmail.com> wrote:
>
>
>
>
> On Mon, Jul 1, 2019 at 7:39 PM Robin Murphy <robin.murphy@arm.com> wrote:
>>
>> On 28/06/2019 17:29, Pankaj Suryawanshi wrote:
>> > On Wed, Jun 26, 2019 at 11:21 PM Christoph Hellwig <hch@infradead.org> wrote:
>> >>
>> >> On Wed, Jun 26, 2019 at 10:12:45PM +0530, Pankaj Suryawanshi wrote:
>> >>> [CC: linux kernel and Vlastimil Babka]
>> >>
>> >> The right list is the list for the DMA mapping subsystem, which is
>> >> iommu@lists.linux-foundation.org.  I've also added that.
>> >>
>> >>>> I am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING attribute
>> >>>> for cma allocation using dma_alloc_attr(), as per kernel docs
>> >>>> https://www.kernel.org/doc/Documentation/DMA-attributes.txt  buffers
>> >>>> allocated with this attribute can be only passed to user space by calling
>> >>>> dma_mmap_attrs().
>> >>>>
>> >>>> how can I mapped in kernel space (after dma_alloc_attr with
>> >>>> DMA_ATTR_NO_KERNEL_MAPPING ) ?
>> >>
>> >> You can't.  And that is the whole point of that API.
>> >
>> > 1. We can again mapped in kernel space using dma_remap() api , because
>> > when we are using  DMA_ATTR_NO_KERNEL_MAPPING for dma_alloc_attr it
>> > returns the page as virtual address(in case of CMA) so we can mapped
>> > it again using dma_remap().
>>
>> No, you really can't. A caller of dma_alloc_attrs(...,
>> DMA_ATTR_NO_KERNEL_MAPPING) cannot make any assumptions about the void*
>> it returns, other than that it must be handed back to dma_free_attrs()
>> later. The implementation is free to ignore the flag and give back a
>> virtual mapping anyway. Any driver which depends on how one particular
>> implementation on one particular platform happens to behave today is,
>> essentially, wrong.
>
>
> Here is the example that i have tried in my driver.
> ///////////////code snippet/////////////////////////////////////////////////////////////////////////
>
> For CMA allocation using DMA API with DMA_ATTR_NO_KERNEL_MAPPING  :-
>
> if(strcmp("video",info->name) == 0)
>         {
>         printk("Testing CMA Alloc %s\n", info->name);
>         info->dma_virt = dma_alloc_attrs(pmap_device, info->size, &phys, GFP_KERNEL,
>                         DMA_ATTR_WRITE_COMBINE | DMA_ATTR_FORCE_CONTIGUOUS | DMA_ATTR_NO_KERNEL_MAPPING);
>         if (!info->dma_virt) {
>                 pr_err("\x1b[31m" "pmap: cma: failed to alloc %s" "\x1b[0m\n",
>                                 info->name);
>                 return 0;
>         }
>                 __dma_remap(info->dma_virt, info->size, PAGE_KERNEL); // /*TO DO pgprot we will be taken from attr */  // we will use this only when virtual mapping is required.
>                 virt = page_address(info->dma_virt); // will use this virtual when kernel mapping needed.
>         }
>
> For CMA free using DMA api with DMA_ATTR_NO_KERNEL_MAPPING:-
>
> if(strcmp("video",info->name) == 0)
>         {
>         printk("Testing CMA Release\n");
>         __dma_remap(info->dma_virt, info->size, PAGE_KERNEL);
>         dma_free_attrs(pmap_device, info->size, info->dma_virt, phys,
>                         DMA_ATTR_WRITE_COMBINE | DMA_ATTR_FORCE_CONTIGUOUS | DMA_ATTR_NO_KERNEL_MAPPING);
>         }
>
> Flow of Function calls :-
>
> 1. static void *__dma_alloc() // .want_vaddr = ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) == 0)
>
> 2.cma_allocator :-
>                             i.  static void *cma_allocator_alloc ()
>                             ii. static void *__alloc_from_contiguous()  // file name :- ./arch/arm/mm/dma-mapping.c
>                                                                      if (!want_vaddr)
>                                                                                     goto out; // condition true for DMA_ATTR_NO_KERNEL_MAPPING
>
>                                                                      if (PageHighMem(page)) {
>                                                                      ptr = __dma_alloc_remap(page, size, GFP_KERNEL, prot, caller);
>                                                                      if (!ptr) {
>                                                                                 dma_release_from_contiguous(dev, page, count);
>                                                                                 return NULL;
>                                                                       }
>                                                                      } else {
>                                                                      __dma_remap(page, size, prot);
>                                                                     ptr = page_address(page);
>                                                                      }
>
>                                                                    out:
>                                                                   *ret_page = page; // return  page
>                                                                    return ptr;  // nothing in ptr
>                                                                   }
>                             iii. struct page *dma_alloc_from_contiguous()
>                             iv. cma_alloc()
> 3. dma_alloc () // returns
> return args.want_vaddr ? addr : page; // returns page which is return by alloc_from_contiguous().
>
> What wrong with this if we already know page is returning dma_alloc_attr().
> we can use dma_remap in our driver and free as freed in static void __free_from_contiguous ().
> Please let me know if i missing anything.
>
>> > 2. We can mapped in kernel space using vmap() as used for ion-cma
>> > https://github.com/torvalds/linux/tree/master/drivers/staging/android/ion
>> >   as used in function ion_heap_map_kernel().
>> >
>> > Please let me know if i am missing anything.
>>
>> If you want a kernel mapping, *don't* explicitly request not to have a
>> kernel mapping in the first place. It's that simple.
>
>
> Do you mean do not use dma-api ? because if i used dma-api it will give you mapped virtual address.
> or i have to use directly cma_alloc() in my driver. // if i used this approach i need to reserved more vmalloc area.
>
> Any help would be appreciated.
>>
>>
>> Robin.

