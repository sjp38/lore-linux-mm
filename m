Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB0EC6B028A
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 07:04:23 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id v21-v6so3869572oia.16
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:04:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s129-v6sor3773622oia.138.2018.10.25.04.04.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 04:04:22 -0700 (PDT)
Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com. [209.85.210.54])
        by smtp.gmail.com with ESMTPSA id c186-v6sm2616114oih.28.2018.10.25.04.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 04:04:20 -0700 (PDT)
Received: by mail-ot1-f54.google.com with SMTP id l1so8682758otj.5
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:04:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181025052901.GA17799@jagdpanzerIV>
References: <20181025012745.20884-1-rafael.tinoco@linaro.org> <20181025052901.GA17799@jagdpanzerIV>
From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Date: Thu, 25 Oct 2018 08:03:47 -0300
Message-ID: <CABdQkv-wPbgXh-QCJHChguvYsEhgom8M195G+H3GRgButSqMww@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: check encoded object value overflow
 for PAE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Rafael David Tinoco <rafael.tinoco@linaro.org>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Russell King <linux@armlinux.org.uk>, Mark Brown <broonie@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 25, 2018 at 2:29 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (10/24/18 22:27), Rafael David Tinoco wrote:
>>  static unsigned long location_to_obj(struct page *page, unsigned int obj_idx)
>>  {
>> -     unsigned long obj;
>> +     unsigned long obj, pfn;
>> +
>> +     pfn = page_to_pfn(page);
>> +
>> +     if (unlikely(OBJ_OVERFLOW(pfn)))
>> +             BUG();
>
> The trend these days is to have less BUG/BUG_ON-s in the kernel.
>
>         -ss

For this case, IMHO, it is worth.

It will avoid a investigation like:
https://bugs.linaro.org/show_bug.cgi?id=3765#c7 and and #c8, where I
had to poison slab allocation - to force both zs_handle and zspage
slabs not to be merged - and to make sure the zspage slab had a good
magic number AND to identify why the bad paging request happened.

If this happens again, for any other arch supporting PAE that does not
declare MAX_POSSIBLE_PHYSMEM_BITS or MAX_PHYSMEM_BITS appropriately,
the kernel will panic, no matter what, by the time it reaches
obj_to_location(). Things can be more complicated about declarations
for PAE if we consider ARM can declare MAX_PHYSMEM_BITS differently in
arch/arm/mach-XXX and/or, for this case, when having, or not SPARSEMEM
set (if I had SPARSEMEM set I would not face this, for example).

If this occurs, the kernel will panic, no matter what, by the time it
reaches obj_to_location()... so why not to BUG() here and let user to
know exactly where it panic-ed and why ? Other option would be to
WARN() here and let it panic naturally because of bad paging request
in a very near future... please advise.

Thanks,
Best Rgds
-Rafael
